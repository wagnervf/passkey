import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:passkey/src/core/utils/utils.dart' show Utils;

// ignore: must_be_immutable
class FormFieldInputPassword extends StatefulWidget {
  FormFieldInputPassword(
      {super.key, required this.passwordController, required this.copy});

  final TextEditingController passwordController;
  bool copy = true;
  bool obscureText = true;

  @override
  State<FormFieldInputPassword> createState() => _FormFieldInputPasswordState();
}

class _FormFieldInputPasswordState extends State<FormFieldInputPassword> {
  final passwordValidator = MultiValidator([
    RequiredValidator(errorText: 'Senha obrigatória'),
    MinLengthValidator(6,
        errorText: 'Sua senha deve possuir pelo menos 6 dígitos'),
  ]);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.passwordController,
      obscureText: widget.obscureText,
      decoration: InputDecoration(
      //  prefixIcon: Icon(Icons.key),
        suffixIcon: SizedBox(
          width: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(
                  widget.obscureText ? Icons.visibility : Icons.visibility_off,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  setState(() {
                    widget.obscureText = !widget.obscureText;
                  });
                },
              ),
              widget.copy
                  ? IconButton(
                      onPressed: () => Utils.copyToClipboard(
                          widget.passwordController.text, context),
                      icon: Icon(
                        Icons.copy,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ),
        hintText: 'Senha',
        border: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.teal, width: 0.3),
            borderRadius: BorderRadius.circular(10)),
        contentPadding: EdgeInsets.all(18),
        filled: true,
        fillColor: const Color.fromARGB(255, 235, 253, 252),
        hintStyle: TextStyle(
          color: Colors.teal[700],
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        errorStyle: const TextStyle(color: Colors.red),
      ),
      validator: passwordValidator.call,
    );
  }
}
