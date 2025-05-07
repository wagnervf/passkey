
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:keezy/src/core/installed_apps/installed_app_model.dart';
import 'package:keezy/src/core/components/show_messeger.dart';
import 'package:keezy/src/core/router/routes.dart';
import 'package:keezy/src/modules/configuracoes/backup_restore/controllers/backup_restore_controller.dart';
import 'package:keezy/src/modules/register/controller/register_controller.dart';
import 'package:keezy/src/modules/register/model/register_model.dart';
import 'package:provider/provider.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
//  final TextEditingController _type = TextEditingController();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _description = TextEditingController();

  late RegisterModel register;
  InstalledAppModel? selectedApp;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    // final String? data = ModalRoute.of(context)?.settings.arguments as String?;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      register = GoRouterState.of(context).extra! as RegisterModel;
      loadEdits(register);
    });
  }

  loadEdits(RegisterModel register) {
    setState(() {
      _title.text = register.name ?? '';
      _password.text = register.password!;
      _description.text = register.note!;
      //  _type.text = register.type.name;
      selectedApp = register.selectedApp;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final textTema = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text('Meu Registro'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.red,
                        child: Text("C", style: TextStyle(color: Colors.white)),
                      ),
                      SizedBox(width: 12),
                      Text(
                        register.name ?? '',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  if (selectedApp != null)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: selectedApp!.iconBytes != null
                          ? Image.memory((selectedApp!.iconBytes!),
                              width: 40, height: 40)
                          : const Icon(Icons.apps),
                      title: Text(selectedApp!.name),
                      subtitle: const Text("App selecionado"),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => selectedApp = null),
                      ),
                    ) else SizedBox.shrink(),


                  const SizedBox(height: 32),

                  label('Login'),
                  _buildInfoField(
                    value: register.username ?? '',
                    icon: Icons.copy,
                    onIconPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: register.username ?? ''));
                    },
                  ),

                  const SizedBox(height: 12),

                  inputPassword(),

                  const SizedBox(height: 12),
                  label('Url'),
                  _buildInfoField(
                    value: register.url ?? '',
                    icon: Icons.copy,
                    onIconPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: register.url ?? ''));
                    },
                  ),
                  const SizedBox(height: 12),

                  label('Observação'),
                  _buildInfoField(
                    value: register.note ?? '',
                    icon: Icons.copy,
                    onIconPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: register.note ?? ''));
                    },
                  ),

                  const SizedBox(height: 10),

                  // Botões
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () => _compartilharRegistro(register),
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => _goToEdit(register),
                            child: const Text('Editar'),
                          ),
                          const SizedBox(width: 12),
                          TextButton(
                            onPressed: () => _excluirRegistro(register),
                            child: const Text(
                              'Excluir',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          // OutlinedButton(
                          //   onPressed: () => _excluirRegistro(register),
                          //   style: OutlinedButton.styleFrom(
                          //       side: const BorderSide(
                          //           width: 1,
                          //           color: Colors.red), // Cor da borda
                          //       foregroundColor: Colors.red),
                          //   child: const Text('Excluir'),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Text label(String titulo) {
    return Text(
      titulo,
      style: Theme.of(context).textTheme.labelSmall,
    );
  }

  TextField inputPassword() {
    String senha = register.password ?? '';
    return TextField(
      readOnly: true,
      obscureText: _obscureText,
      controller: TextEditingController(text: senha),
      decoration: InputDecoration(
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon:
                  Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
            IconButton(
                icon: Icon(
                  Icons.copy,
                ),
                onPressed: () => Clipboard.setData(ClipboardData(text: senha))),
          ],
        ),
      
      ),
    );
  }

  String obscureText(String text) {
    return text.replaceAll(RegExp(r'.'), '•');
  }

  Widget _buildInfoField({
    required String value,
    bool obscureText = false,
    required IconData icon,
    required VoidCallback onIconPressed,
  }) {
    return TextField(
      readOnly: true,
      obscureText: obscureText,
      controller: TextEditingController(text: value),
      decoration: InputDecoration(
        suffixIcon: IconButton(icon: Icon(icon), onPressed: onIconPressed),
        
      ),
    );
  }

  _compartilharRegistro(RegisterModel register) async {
    final exportarImportarService =
        Provider.of<BackupRestoreController>(context, listen: false);

    exportarImportarService.exportarUmRegistro(register);

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registro compartilhado com sucesso!')),
    );
  }

  _goToEdit(RegisterModel register) async {
    await GoRouter.of(context).push(RoutesPaths.register, extra: register);
  }

  Future<void> _excluirRegistro(RegisterModel register) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text('Tem certeza que deseja excluir este registro?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                bool result = true;

                result = await context
                    .read<RegisterController>()
                    .deleteRegisterController(register);

                if (context.mounted) {
                  if (result == true) {
                    ShowMessager.show(context, 'Registro removido');
                  }
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }
}
