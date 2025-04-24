import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:installed_apps/app_info.dart';
import 'package:passkey/src/core/components/installed_apps/installed_app_model.dart';
import 'package:passkey/src/core/components/installed_apps/installed_apps_page.dart';
import 'package:passkey/src/core/components/show_messeger.dart';
import 'package:passkey/src/core/router/routes.dart';
import 'package:passkey/src/modules/register/controller/register_controller.dart';
import 'package:passkey/src/modules/register/model/registro_model.dart';
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
  

  bool _obscureText = true;
  bool edit = false;
  bool carregando = false;

  RegisterModel? register;
 // InstalledAppModel? _selectedApp;
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
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Adicionar senha'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Form(
        key: _formularioKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text("Site ou app"),
            const SizedBox(height: 6),
            _buildField(_siteController, "Site"),
            const SizedBox(height: 20),

            if (selectedApp != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: selectedApp!.iconBytes != null
                    ? Image.memory(selectedApp!.iconBytes!,
                        width: 40, height: 40)
                    : const Icon(Icons.apps),
                title: Text(selectedApp!.name),
                subtitle: const Text("App selecionado"),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => selectedApp = null),
                ),
              )
            else
              Row(
                children: [
                  Icon(Icons.apps),
                  TextButton(
                    onPressed: () => _showAppPicker(context),
                    child: const Text("Selecionar app"),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            Divider(
              thickness: 4,
              color: Colors.grey[200],
            ),
            const SizedBox(height: 20),
            const Text("Salve a senha atual"),
            const SizedBox(height: 8),
            _buildField(_loginController, "Nome de usuário"),
            const SizedBox(height: 12),
            _buildPasswordField(),
            const SizedBox(height: 12),
            _buildField(_descriptionController, "Observação"),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _clearInputs,
                  child: const Text(
                    'Cancelar',
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => acaoSalvarRegistro(context),
                  child: const Text(
                    'Salvar',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFE0E6E8),
        border: const OutlineInputBorder(borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscureText,
      decoration: InputDecoration(
        hintText: "Senha",
        filled: true,
        fillColor: const Color(0xFFE0E6E8),
        border: const OutlineInputBorder(borderSide: BorderSide.none),
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
      ),
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



  Future<void> _showAppPicker(BuildContext context) async {
    final AppInfo? selected = await showModalBottomSheet<AppInfo>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          builder: (context, scrollController) {
            return InstalledAppsPage(scrollController: scrollController);
          },
        );
      },
    );

    if (selected != null) {
      setState(() {
        selectedApp = InstalledAppModel(
            name: selected.name, iconPath: "", iconBytes: selected.icon);
      });
    }
  }

    Future<void> acaoSalvarRegistro(BuildContext context) async {
    setState(() {
      carregando = true;
    });

    RegisterModel formQuery = RegisterModel(
      id: edit ? register!.id : const Uuid().v4(),
      name: _titleController.text,
      username: _loginController.text,
      password: _passwordController.text,
      note: _descriptionController.text,
      url: _siteController.text,
      selectedApp: selectedApp
    );

    bool result;
    if (edit) {
      result = await context
          .read<RegisterController>()
          .updateRegisterController(formQuery);
    } else {
      result = await context
          .read<RegisterController>()
          .saveRegisterController(formQuery);
    }

    if (result) {
      ShowMessager.show(
          context, edit ? 'Registro atualizado!' : 'Registro salvo!');
      GoRouter.of(context).pushReplacement(RoutesPaths.home);
    }
  }
}
