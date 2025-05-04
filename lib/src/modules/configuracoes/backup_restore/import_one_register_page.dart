import 'package:flutter/material.dart';
import 'package:keezy/src/core/components/show_messeger.dart';
import 'package:keezy/src/modules/register/controller/register_controller.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class ImportOneRegisterPage extends StatefulWidget {
  const ImportOneRegisterPage({super.key});

  @override
  State<ImportOneRegisterPage> createState() => _ImportOneRegisterPageState();
}

class _ImportOneRegisterPageState extends State<ImportOneRegisterPage> {
  TextEditingController jsonController = TextEditingController();

  importarRegistro(String jsonContent) async {
    await context.read<RegisterController>().importarUmRegistro(jsonContent);
  }

  Future<void> pickJsonFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.single.path != null) {
      final fileContent = await File(result.files.single.path!).readAsString();
      setState(() {
        jsonController.text = fileContent;
      });
    } else {
      showMessage('Nenhum arquivo selecionado.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Importar registro'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ListTile(
                    dense: true,
                    title: Text(
                      'Selecione um arquivo JSON para importar o registro.',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Divider(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: pickJsonFile,
                      child: Text('Selecionar arquivo JSON'),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  textFlield(context),
                  Spacer(),
                  buttonImport(context),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      child: const Text("Fechar"),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
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
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Preview do Registro'),
                  content: SingleChildScrollView(
                    child: Text(jsonContent),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        var registroImportado = await importarRegistro(jsonContent);

                        if (registroImportado != null) {
                          showMessage('Registro importado com sucesso!');
                        } else {
                          showMessage('Falha ao importar o registro!');
                        }
                      },
                      child: Text('Confirmar'),
                    ),
                  ],
                );
              },
            );
          } else {
            showMessage('O campo JSON está vazio!');
          }
        },
        child: Text(
          'Importar Registro',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  showMessage(String texto) {
    if (context.mounted) {
      ShowMessager.show(context, texto);
    }
  }

  SizedBox textFlield(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * .35,
      width: MediaQuery.of(context).size.width * .9,
      child: Column(
        children: [
          Card(
            elevation: 5,
            borderOnForeground: true,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: Colors.teal,
                  width: 1,
                )),
            child: TextFormField(
              onChanged: (value) {
                setState(() {
                  jsonController.text = value;
                });
              },
              controller: jsonController,
              focusNode: FocusNode(),
              maxLines: (MediaQuery.of(context).size.height / 90).toInt(),
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
              scrollPadding: const EdgeInsets.all(10),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                hintText: 'Conteúdo do arquivo JSON aparecerá aqui',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
