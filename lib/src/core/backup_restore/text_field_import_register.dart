import 'package:flutter/material.dart';
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
    return TextButton.icon(
      onPressed: () => _mostrarModal(context),
      label: const Text('Importar Registro'),
      icon: const Icon(Icons.restart_alt_outlined),
    );
  }

  void _mostrarModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Importar Registro"),
          titleTextStyle: Theme.of(context).textTheme.titleSmall,
          content: textFlield(context),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Fecha o modal
                  },
                  child: OutlinedButton(
                    child: const Text("Fechar"),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                buttonImport(context),
              ],
            ),
          ],
        );
      },
    );
  }

  ElevatedButton buttonImport(BuildContext context) {
    String jsonContent = jsonController.text;

    return ElevatedButton(
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
      child: const Text('Importar Registro'),
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
