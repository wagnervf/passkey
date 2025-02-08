// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:go_router/go_router.dart';
import 'package:passkey/src/core/components/show_messeger.dart';
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
  bool _obscureText = true;

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
        await context.read<AuthController>().register(user);
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

  final passwordValidator = MultiValidator([
    RequiredValidator(errorText: 'Senha obrigatória'),
    MinLengthValidator(6,
        errorText: 'Sua senha deve possuir pelo menos 6 dígitos'),
  ]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        excludeHeaderSemantics: true,        
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            edit ? 'Editar perfil' : 'Criar conta',
          ),
        ),
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
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Align(alignment: Alignment.center, child: _imgPasskey(size, context)),

                      Utils.titleCard(context, 'Nome'),
                      _buildTextField(
                        controller: _nameController,
                        hintText: 'Insira o seu Nome',
                        icon: Icons.person,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Por favor, insira o seu nome'
                            : null,
                      ),
                      SizedBox(height: size.height * 0.02),
                      Utils.titleCard(context, 'E-mail'),
                      _buildTextField(
                        controller: _emailController,
                        hintText: 'Insira o endereço de E-mail',
                        icon: Icons.email_outlined,
                        validator: emailValidator.call,
                      ),
                      SizedBox(height: size.height * 0.02),
                  
                      Utils.titleCard(context, 'Senha mestra'),
                      inputPassword(),
                  
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          'Senha mestra, a única senha que você precisará lembrar.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      //const Spacer(),
                     
                      const Spacer(),
                  
                      buttonSalvarContinuar(context),
                  
                  
                  
                      ListTile(
                        dense: true,
                        leading: const Icon(
                          Icons.info_outline,
                          size: 16,
                          //color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(
                            'Seus dados serão criptografados e salvos em seu dispositivo.',
                            style: Theme.of(context).textTheme.labelSmall),
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

  Padding _imgPasskey(Size size, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        height: size.height * .1,
        child: Image.asset(
          'assets/images/passkey.png',
          fit: BoxFit.contain,
          color: Colors.teal,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        hintText: hintText,
        filled: true,
        fillColor: Theme.of(context).colorScheme.onPrimary,
        hintStyle: TextStyle(
          color: Colors.grey[700],
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
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
          title: Text(edit ? 'Salvar' : 'Continuar',
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

  Row inputPassword() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            child: TextFormField(
              //   style: const TextStyle(color: Colors.black),
              controller: _passwordController,
              obscureText: _obscureText,
              decoration: decoration('Insira sua senha mestra'),
              validator: passwordValidator.call,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration decoration(String description) {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
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
      hintText: description,
      filled: true,
      fillColor: Theme.of(context).colorScheme.onPrimary,
      hintStyle: TextStyle(
        color: Colors.grey[700],
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      errorStyle: const TextStyle(color: Colors.amber),
    );
  }
}
