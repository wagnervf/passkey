import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:passkey/src/core/backup_restore/text_field_import_register.dart';
import 'package:passkey/src/core/components/my_text_field.dart';
import 'package:passkey/src/core/components/show_messeger.dart';
import 'package:passkey/src/core/router/routes.dart';
import 'package:passkey/src/core/utils/utils.dart';
import 'package:passkey/src/modules/register/controller/register_controller.dart';
import 'package:passkey/src/modules/register/model/registro_model.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  //final _controller = RegistersController();
  final _formularioKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _siteController = TextEditingController();

  //TipoRegisterModel? _typeSelecionado;

  late RegisterModel? register;
  bool _obscureText = true;
  bool edit = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (GoRouterState.of(context).extra != null) {
        register = GoRouterState.of(context).extra! as RegisterModel;
        loadEdits(register!);
      }
    });

    // _typeSelecionado = TipoRegisterModel(
    //   id: 7,
    //   name: 'Amazon',
    //   icon: 'amazon',
    //   color: const Color(0xFFFF9900),
    // );
  }

  loadEdits(RegisterModel register) {
    setState(() {
      edit = true;
      _titleController.text = register.title;
      _loginController.text = register.login ?? '';
      _passwordController.text = register.password ?? '';
      _descriptionController.text = register.description ?? '';
      _siteController.text = register.site ?? '';
      // _typeSelecionado = register.type;
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
    //final textTema = Theme.of(context).textTheme;
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(edit ? 'Editar registro' : 'Novo registro'),
        actions: [
          TextFieldImportRegister()
         
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            botaoFechar(context),
            botaoSalvar(context),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formularioKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  //   child: Text(
                  //     'Tipo',
                  //     style: Theme.of(context).textTheme.labelSmall,
                  //   ),
                  // ),
                  // selecionarTipo(context),
                  SizedBox(height: size.height * 0.02),
                  MyTextField(
                    myController: _titleController,
                    fieldName: "Título",
                  ),
                  SizedBox(height: size.height * 0.02),
                  MyTextField(
                    myController: _loginController,
                    fieldName: "Login",
                  ),
                  SizedBox(height: size.height * 0.02),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    decoration: decorationField(
                      'Senha',
                      const Icon(
                        Icons.key,
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  MyTextField(
                    myController: _siteController,
                    fieldName: "Endereço Web",
                    myIcon: Icons.language,
                  ),
                  SizedBox(height: size.height * 0.02),
                  MyTextField(
                    myController: _descriptionController,
                    fieldName: "Observação",
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Padding botaoSalvar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: Utils.width(context) * 0.35,
        height: 50,
        child: FilledButton(
          onPressed: () async {
            await acaoSalvarRegistro(context);
          },
          // },
          child: Text(
            'Salvar',
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  botaoFechar(BuildContext context) {
    return SizedBox(
      width: Utils.width(context) * 0.3,
      height: 50,
      child: OutlinedButton(
          onPressed: () => _clearInputs(),
          child: Text('Cancelar',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ))),
    );
  }

  Future<void> acaoSalvarRegistro(BuildContext context) async {
    RegisterModel formQuery = RegisterModel(
      id: edit ? register!.id : const Uuid().v4(),
      title: _titleController.text,
      login: _loginController.text,
      password: _passwordController.text,
      description: _descriptionController.text,
      site: _siteController.text,
      //  type: _typeSelecionado!,
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

    if (result == true) {
      ShowMessager.show(
          context, edit ? 'Registro atualizado!' : 'Registro salvo!');
      GoRouter.of(context).pushReplacement(RoutesPaths.home);
    }
  }

  InputDecoration decorationField(String description, Widget icon) {
    return InputDecoration(
      contentPadding: const EdgeInsets.all(20),
      suffixIcon: SizedBox(
        width: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
            IconButton(
              onPressed: () =>
                  Utils.copyToClipboard(_passwordController.text, context),
              icon: Icon(
                Icons.copy,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
      labelText: description,
      border: UnderlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).colorScheme.onPrimary)),
      filled: true,
      fillColor: Colors.grey[50],
      hintStyle: TextStyle(
        color: Colors.grey[500],
        fontSize: 12,
      ),
      labelStyle: TextStyle(
        color: Colors.grey[700],
        fontSize: 16,
      ),
    );
  }

/*  Container selecionarTipo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () async {
          final result = await _showBottomSheet(context);
          setState(
            () {
              _typeSelecionado = result;
            },
          );
        },
        child: ListTile(
          title: _typeSelecionado == null
              ? Text(
                  'Tipo',
                  style: Theme.of(context).textTheme.displayMedium,
                )
              : Text(
                  _typeSelecionado!.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
          leading: _typeSelecionado == null
              ? const SizedBox.shrink()
              : FaIcon(Utils.getIcon(_typeSelecionado!.icon),
                  color: _typeSelecionado!.color),
          trailing: const Padding(
            padding: EdgeInsets.all(4.0),
            child: Icon(
              Icons.arrow_drop_down,
            ),
          ),
        ),
      ),
    );
  }
*/

  void _clearInputs() {
    _titleController.clear();
    _loginController.clear();
    _passwordController.clear();
    _descriptionController.clear();
    Navigator.of(context).pop();

    // setState(() {
    //   //   _typeSelecionado = TipoRegisterModel(icon: null);
    // });
  }
}
