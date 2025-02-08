import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:go_router/go_router.dart';
import 'package:passkey/src/core/components/expand_buttons_actions.dart';
import 'package:passkey/src/core/utils/utils.dart';
import 'package:passkey/src/modules/register/model/registro_model.dart';

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

  late RegisterModel register = RegisterModel();

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
      _title.text = register.title;
      _password.text = register.password!;
      _description.text = register.description!;
      //  _type.text = register.type.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final textTema = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Registro'),
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandButtonsActions(
        registro: register,
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
                children: [
                  atribute('Título', register.title),
                  const Divider(),
                  atribute('Login', register.login ?? ''),
                  const Divider(),
                  inputPassword(),
                  const Divider(),
                  atribute('Endereço Web', register.site ?? ''),
                  const Divider(),
                  atribute('Observação', register.description ?? ''),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  atribute(String label, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    title.toString(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                )
              ],
            ),
          ))
        ],
      ),
    );
  }

  Row inputPassword() {
    String senha = register.password ?? '';
    return Row(
      children: [
        Expanded(
          child: atribute('Senha', _obscureText ? obscureText(senha) : senha),
        ),
        IconButton(
          icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
        IconButton(
          onPressed: () => Utils.copyToClipboard(senha, context),
          icon: const Icon(Icons.copy),
        ),
      ],
    );
  }

  String obscureText(String text) {
    return text.replaceAll(
        RegExp(r'.'), '•'); // Substitui cada caractere por "•"
  }
}
