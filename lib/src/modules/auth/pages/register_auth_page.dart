// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:go_router/go_router.dart';
import 'package:passkey/src/core/components/form_field_input_password.dart';
import 'package:passkey/src/core/components/help/help_view.dart';
import 'package:passkey/src/core/router/routes.dart';
import 'package:passkey/src/core/utils/utils.dart';
import 'package:passkey/src/core/components/show_sucess.dart';
import 'package:passkey/src/modules/auth/controllers/auth_controller.dart';
import 'package:passkey/src/modules/auth/controllers/auth_state.dart';
import 'package:passkey/src/modules/auth/model/auth_user_model.dart';

class RegisterAuthPage extends StatefulWidget {
  const RegisterAuthPage({super.key});

  @override
  State<RegisterAuthPage> createState() => _RegisterAuthPageState();
}

class _RegisterAuthPageState extends State<RegisterAuthPage> {
  final _nameController = TextEditingController();

  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  final _formKeyAuth = GlobalKey<FormState>();

  bool edit = false;

  @override
  void initState() {
    super.initState();
    // final String? data = ModalRoute.of(context)?.settings.arguments as String?;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AuthUserModel user = GoRouterState.of(context).extra as AuthUserModel;
      if (user.name != "") {
        loadEditUser(user);
      }
    });
  }

  loadEditUser(AuthUserModel user) {
    setState(() {
      edit = true;
      _nameController.text = user.name;
      _emailController.text = user.email;
      _passwordController.text = user.password;
    });
  }

  void _register(BuildContext context) async {
    if (_formKeyAuth.currentState!.validate()) {
      final user = AuthUserModel(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      try {
        await context.read<AuthController>().limparContaAntesDeCriarUser();

        await context.read<AuthController>().registerUser(user);

      } catch (e) {
        DialogUtils.showSuccessDialog(
          context,
          'Erro ao realizar cadastro: ${e.toString()}',
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  final emailValidator = MultiValidator([
    RequiredValidator(errorText: 'E-mail obrigatório'),
    EmailValidator(errorText: 'Insira um e-mail válido'),
  ]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        excludeHeaderSemantics: true,
        // title: Padding(
        //   padding: const EdgeInsets.all(8.0),
        //   child: Text(
        //     edit ? 'Editar perfil' : 'Criar conta',
        //   ),
        // ),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.all(8.0),
        //     child: edit
        //         ? TextButton(
        //             onPressed: () => Navigator.of(context).pop(),
        //             child: const Text('Cancelar'))
        //         : const SizedBox.shrink(),
        //   )
        // ],
      ),
      body: SafeArea(
        child: blocConsumer(context),
      ),
    );
  }

  BlocConsumer<AuthController, AuthState> blocConsumer(BuildContext context) {
    return BlocConsumer<AuthController, AuthState>(
      listener: (context, state) async {
        if (state is AuthSuccessState) {
          await _authSuccess(context);
        } else if (state is AuthErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is AuthLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }
        return _formAuthRegister(context);
      },
    );
  }

  Future<void> _authSuccess(BuildContext context) async {
    DialogUtils.showSuccessDialog(
      context,
      'Tudo certo!',
    );
    await Future.delayed(const Duration(milliseconds: 500));

    edit
        ? GoRouter.of(context).pop()
        : GoRouter.of(context).pushReplacement(RoutesPaths.home);
  }

  _formAuthRegister(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Form(
      key: _formKeyAuth,
      child: LayoutBuilder(
        builder: (context, constraint) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraint.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        edit ? 'Editar perfil' : 'Criar Conta',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Armazenamento criptografado e acesso fácil quando precisar",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const Spacer(),
                      formField(
                        controller: _nameController,
                        hintText: 'Nome',
                        icon: Icons.person,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Por favor, insira o seu nome'
                            : null,
                      ),
                      SizedBox(height: size.height * 0.03),
                      formField(
                        controller: _emailController,
                        hintText: 'E-mail',
                        icon: Icons.email_outlined,
                        validator: emailValidator.call,
                      ),
                      SizedBox(height: size.height * 0.03),
                      FormFieldInputPassword(
                        passwordController: _passwordController,
                        copy: true,
                      ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text(
                          'Senha mestra, a única senha que você precisará lembrar.',
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: size.width * .9,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => _register(context),
                          style: Utils.styleButtonElevated(),
                          child: Text(
                            edit ? 'Salvar' : "Criar Conta",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: size.width * .9,
                        height: 50,
                        child: TextButton(
                          child: Text(
                            "Já possuo uma conta",
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          onPressed: () => _acessar(context),
                        ),
                      ),
                      const Spacer(),

                      OutlinedButton.icon(
                        icon: const Icon(
                          Icons.help,
                          size: 16,
                        ),
                        label: Text('Porque devo criar uma conta?'),
                        onPressed: () => HelpView.mostrarDialogCriarConta(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _acessar(BuildContext context) {
    GoRouter.of(context).pushReplacement(RoutesPaths.auth);
  }

  Widget formField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: Utils.decorationField(hintText, icon),
      validator: validator,
    );
  }

  InkWell buttonSalvarContinuar(BuildContext context) {
    return InkWell(
      onTap: () => _register(context),
      child: Card(
        elevation: 3,
        color: Theme.of(context).colorScheme.primary,
        child: ListTile(
          minTileHeight: 60,
          title: Text(edit ? 'Salvar' : 'Criar',
              style:
                  TextStyle(color: Theme.of(context).colorScheme.onSecondary)),
          leading: Icon(Icons.save,
              color: Theme.of(context).colorScheme.onSecondary),
          trailing: Icon(
            Icons.keyboard_arrow_right_outlined,
            color: Theme.of(context).colorScheme.onSecondary,
            //  size: 32,
          ),
        ),
      ),
    );
  }
}
