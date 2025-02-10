import 'package:flutter/material.dart';
import 'package:passkey/src/core/utils/utils.dart';
import 'package:passkey/src/modules/register/controller/register_controller.dart';
import 'package:passkey/src/modules/register/model/registro_model.dart';
import 'package:provider/provider.dart';

class TextFieldImportRegister extends StatefulWidget {
  TextFieldImportRegister({super.key});

  @override
  State<TextFieldImportRegister> createState() =>
      _TextFieldImportRegisterState();
}

class _TextFieldImportRegisterState extends State<TextFieldImportRegister> {
  TextEditingController jsonController = TextEditingController();

  importarRegistro(String jsonContent) async {
    await context.read<RegisterController>().importarUmRegistro(jsonContent);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: TextButton.icon(
        onPressed: () => _mostrarModal(context),
        label: const Text('Importar Registro'),
        icon: const Icon(Icons.restart_alt_outlined),
      ),
    );
  }

  void _mostrarModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsPadding: EdgeInsets.all(0),
          title: const Text("Importar Registro", style: TextStyle(fontSize: 18),),
          titleTextStyle: Theme.of(context).textTheme.titleMedium,
          content: textFlield(context),
          actionsAlignment: MainAxisAlignment.center,

          actions: [
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buttonImport(context),
                  SizedBox(height: 10,),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      child: const Text("Fechar"),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  SizedBox buttonImport(BuildContext context) {
    String jsonContent = jsonController.text;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () async {
          if (jsonContent.isNotEmpty) {
            var registroImportado = await importarRegistro(jsonContent);

            if (registroImportado != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: const Text('Registro importado com sucesso!')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Erro ao importar registro! Verifique o JSON.')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('O campo JSON está vazio!')),
            );
          }
        },
        child: Text('Importar Registro', style: TextStyle(fontSize: 18),),
      ),
    );
  }

  SizedBox textFlield(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * .4,
      width: MediaQuery.of(context).size.width * .9,
      child: Column(
        children: [
          TextField(
            controller: jsonController,
            maxLines: (MediaQuery.of(context).size.height / 100).toInt(),
            decoration: const InputDecoration(
              labelText: 'Cole o JSON do registro aqui',
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey)),
            ),
          ),
        ],
      ),
    );
  }
}
