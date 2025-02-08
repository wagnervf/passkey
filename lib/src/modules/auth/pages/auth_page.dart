// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:go_router/go_router.dart';
import 'package:passkey/src/core/components/show_messeger.dart';
import 'package:passkey/src/core/router/routes.dart';
import 'package:passkey/src/modules/auth/controllers/auth_controller.dart';
import 'package:passkey/src/modules/auth/controllers/auth_state.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  AuthPageState createState() => AuthPageState();
}

class AuthPageState extends State<AuthPage> {
  final _passwordController = TextEditingController();
  final _formKeyAuth = GlobalKey<FormState>();

  bool _obscureText = true;

  final passwordValidator = MultiValidator([
    RequiredValidator(errorText: 'Senha obrigatória'),
    MinLengthValidator(6,
        errorText: 'Sua senha deve possuir pelo menos 6 dígitos'),
  ]);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticateWithBiometrics(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        toolbarHeight: 10,
      ),
      body: LayoutBuilder(builder: (contextB, constraint) {
        return _buildBody(contextB, constraint);
      }),
    );
  }

  SingleChildScrollView _buildBody(
      BuildContext contextB, BoxConstraints constraint) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraint.maxHeight),
        child: IntrinsicHeight(
          child: _blocCosumer(),
        ),
      ),
    );
  }

  BlocConsumer<AuthController, AuthState> _blocCosumer() {
    return BlocConsumer<AuthController, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccessState) {
          Future.delayed(const Duration(milliseconds: 500)).then(
            (value) => GoRouter.of(context).pushReplacement(
              RoutesPaths.home,
              extra: state.user,
            ),
          );
        } else if (state is AuthErrorState) {
          ShowMessager.show(
            context,
            state.message,
          );
        }
      },
      builder: (context, state) {
        if (state is AuthLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }
        return _formLogin(context);
      },
    );
  }

  Form _formLogin(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Form(
      key: _formKeyAuth,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: size.height * .1),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4.0),
                  margin: const EdgeInsets.all(2.0),
                  height: size.height * .15,
                  child: Image.asset(
                    'assets/images/passkey.png',
                    fit: BoxFit.contain,
                    color: Colors.teal,
                  ),
                ),
                // Text(
                //   'PASSKEY',
                //   style: TextStyle(
                //     color: Theme.of(context).colorScheme.primary,
                //     fontSize: 30,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
              ],
            ),
            //SizedBox(height: size.height * .05),
            const Spacer(),
            SizedBox(
              height: 60,
              width: double.infinity,
              child: Card(
                elevation: 3,
                color: Theme.of(context).colorScheme.primary,
                child: TextButton.icon(
                  onPressed: () => _authenticateWithBiometrics(context),
                  icon: Icon(
                    Icons.fingerprint,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  label: Text(
                    'Acessar com Biometria',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
            const Spacer(),
            const Center(
              child: Text(
                ' ou ',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 60),
            inputPassword(),
            const SizedBox(height: 10),
            SizedBox(
              height: 60,
              width: double.infinity,
              child: Card(
                elevation: 3,
                color: Theme.of(context).colorScheme.primary,
                child: TextButton.icon(
                  onPressed: () => _login(context),
                  icon: Icon(
                    Icons.key,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  label: Text(
                    'Entrar',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
            SizedBox(height: size.height * .1),
          ],
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
              controller: _passwordController,
              obscureText: _obscureText,
              decoration: decoration('Senha Mestra (6 dígitos)'),
              validator: passwordValidator.call,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration decoration(String description) {
    return InputDecoration(
      //counterText: _passwordController.text.length.toString(),
      contentPadding: const EdgeInsets.all(18),
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
          ],
        ),
      ),
      hintText: description,
      filled: true,
      //   fillColor: Colors.black,
      //  hoverColor: Colors.black,
      //  focusColor: Colors.black,
      hintStyle: TextStyle(
        //  color: Colors.grey[700],
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(15),
      ),
      errorStyle: const TextStyle(color: Colors.amber),
    );
  }

  Future<void> _login(BuildContext context) async {
    final password = _passwordController.text;
    if (password.isEmpty) {
      ShowMessager.show(context, 'Por favor, insira sua senha');
    }
    context.read<AuthController>().login(password);
  }

  Future<void> _authenticateWithBiometrics(BuildContext context) async {
    //  try {
    return context.read<AuthController>().loginWithBiometrics();
  }

  Center loading() {
    return const Center(
        child: CircularProgressIndicator(
      backgroundColor: Colors.white,
    ));
  }
}
