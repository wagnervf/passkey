// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:installed_apps/app_info.dart';
import 'package:keezy/src/core/components/button_copiar.dart';
import 'package:keezy/src/core/components/show_messeger.dart';
import 'package:keezy/src/core/installed_apps/installed_app_model.dart';
import 'package:keezy/src/core/installed_apps/installed_apps_page.dart';
import 'package:keezy/src/core/utils/password_field_with_generator.dart';
import 'package:keezy/src/core/utils/utils.dart';
import 'package:keezy/src/modules/export_registers_csv/controllers/export_register_csv_controller.dart';
import 'package:keezy/src/modules/register/controller/register_controller.dart';
import 'package:keezy/src/modules/register/model/register_model.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formularioKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _siteController = TextEditingController();

  bool edit = false;
  bool carregando = false;
  bool buscandoApps = false;

  RegisterModel? register;
  InstalledAppModel? selectedApp;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (GoRouterState.of(context).extra != null) {
        register = GoRouterState.of(context).extra as RegisterModel;
        loadEdits(register!);
      }
    });
  }

  void loadEdits(RegisterModel register) {
    setState(() {
      edit = true;
      _titleController.text = register.name ?? '';
      _loginController.text = register.username ?? '';
      _passwordController.text = register.password ?? '';
      _descriptionController.text = register.note ?? '';
      _siteController.text = register.url ?? '';
      selectedApp = register.selectedApp;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    _descriptionController.dispose();
    _siteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ExportRegisterCsvController>(
      context,
      listen: false,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _clearInputs();
          },
        ),
        actions: [
          IconButton(
            onPressed: () => _confirmarExportacao(context, controller),
            tooltip: 'Compartilhar Registro',
            icon: Icon(Icons.share_outlined, fontWeight: FontWeight.bold),
          ),
          edit
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: IconButton(
                    onPressed: () => _excluirRegistro(),
                    icon: Icon(Icons.delete, color: Colors.red),
                  ),
                )
              : const SizedBox.shrink(),
        ],
        title: Text(edit ? 'Editar Registro' : 'Adicionar Registro'),
        elevation: 0,
        // backgroundColor: Colors.transparent,
        // foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: carregando
                      ? CircularProgressIndicator()
                      : Form(
                          key: _formularioKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 15),

                              (selectedApp == null)
                                  ? selecionarApp()
                                  : appSelecionado(),

                              const SizedBox(height: 24),

                              const Text("Nome, app ou site"),
                              const SizedBox(height: 8),
                              _buildTextField(
                                _titleController,
                                "Nome do app ou site",
                              ),
                              const SizedBox(height: 24),
                              const Text("Usuário e senha"),
                              const SizedBox(height: 8),

                              _buildLoginField(),
                              const SizedBox(height: 12),
                              PasswordFieldWithGenerator(
                                controller: _passwordController,
                                labelText: "Senha do Cofre",
                                maxLength: 16,
                                onChanged: (value) {
                                },
                              ),
                              const SizedBox(height: 24),
                              const Text("Observação"),
                              _buildTextField(
                                _descriptionController,
                                "Observação",
                              ),
                              const Spacer(),

                              _buttonSalvar(context),
                            ],
                          ),
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Padding _buttonSalvar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 24),
      child: SizedBox(
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Utils.isDarkMode(context)
                ? Theme.of(context).colorScheme.surface
                : Theme.of(context).colorScheme.primary,
          ),
          onPressed: () => acaoSalvarRegistro(context),
          child: Text(
            "Salvar",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmarExportacao(
    BuildContext context,
    ExportRegisterCsvController controller,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Compartilhar Registro'),
        content: const Text(
          'Deseja exportar e compartilhar este registro em formato CSV? '
          'O arquivo poderá ser importado por outro usuário posteriormente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Compartilhar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await controller.exportSingleRegister(register!);
    }
  }

  Column selecionarApp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Selecionar um App do celular"),
        const SizedBox(height: 8),
        SizedBox(
          width: double.maxFinite,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
            icon: const Icon(Icons.apps),
            onPressed: () async {
              setState(() {
                buscandoApps = true;
              });
              await _showAppDialog(context);
            },
            label: const Text("Buscar app"),
          ),
        ),
      ],
    );
  }

  ColoredBox appSelecionado() {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 4),
        leading: selectedApp!.iconBytes != null
            ? Image.memory((selectedApp!.iconBytes!), width: 40, height: 40)
            : const Icon(Icons.apps),
        title: Text(selectedApp!.name),
        subtitle: const Text("App selecionado"),
        trailing: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => setState(() => selectedApp = null),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(hintText: hint),
    );
  }

  Widget _buildLoginField() {
    return TextField(
      controller: _loginController,
      decoration: InputDecoration(
        hintText: "Usuário/Login",
        suffixIcon: ButtonCopiar(
          controller: _loginController,
          context: context,
          message: 'Usuário copiada para a área de transferência',
        ),
      ),
    );
  }

  // Widget _buildPasswordField() {

  //

  // return TextField(
  //   controller: _passwordController,
  //   obscureText: _obscureText,
  //   decoration: InputDecoration(
  //     hintText: "Senha",
  //     suffixIcon: SizedBox(
  //       width: 96,
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.end,
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           ButtonCopiar(
  //             controller: _passwordController,
  //             context: context,
  //             message: 'Senha copiada para a área de transferência',
  //           ),
  //           IconButton(
  //             icon: Icon(
  //               _obscureText ? Icons.visibility : Icons.visibility_off,
  //             ),
  //             tooltip: _obscureText ? 'Mostrar senha' : 'Ocultar senha',
  //             onPressed: () => setState(() {
  //               _obscureText = !_obscureText;
  //             }),
  //           ),
  //         ],
  //       ),
  //     ),
  //   ),
  // );
  // }

  Future<void> _showAppDialog(BuildContext context) async {
    final AppInfo? selected = await showDialog<AppInfo>(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(2),
          title: const Text("Selecionar App"),
          titlePadding: const EdgeInsets.all(16),
          titleTextStyle: Theme.of(context).textTheme.titleSmall,
          content: SizedBox(
            width: double.maxFinite,
            child: InstalledAppsPage(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancelar"),
            ),
          ],
        );
      },
    );

    if (selected != null) {
      setState(() {
        selectedApp = InstalledAppModel(
          name: selected.name,
          iconPath: "",
          iconBytes: selected.icon,
          id: 4,
        );
        _titleController.text = selected.name;
      });
    }
  }

  Future<bool> acaoSalvarRegistro(BuildContext context) async {
    setState(() => carregando = true);
    final controller = context.read<RegisterController>();

    final formQuery = RegisterModel(
      id: edit ? register!.id : const Uuid().v4(),
      name: _titleController.text.trim(),
      username: _loginController.text.trim(),
      password: _passwordController.text.trim(),
      note: _descriptionController.text.trim(),
      url: _siteController.text.trim(),
      selectedApp: selectedApp,
    );

    final success = await controller.saveAndUpdateRegisterController(formQuery);

    setState(() => carregando = false);

    if (success) {
      ShowMessager.show(
        context,
        edit ? 'Registro Atualizado!' : 'Registro Salvo!',
      );
      Navigator.of(context).pop();
    } else {
      ShowMessager.show(context, 'Erro ao salvar Registro, tente novamente.');
    }

    return success;
  }

  Future<void> _excluirRegistro() async {
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
                    .deleteRegisterController(register!);

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

  void _clearInputs() {
    _titleController.clear();
    _loginController.clear();
    _passwordController.clear();
    _descriptionController.clear();
    _siteController.clear();
    Navigator.of(context).pop();
  }
}
