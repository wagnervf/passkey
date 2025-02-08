import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  MyTextField(
      {super.key,
      required this.fieldName,
      required this.myController,
      this.myIcon});
  final TextEditingController myController;
  String fieldName;
  IconData? myIcon;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: myController,
      decoration: InputDecoration(
        labelText: fieldName,
        suffixIcon: myIcon == null ? SizedBox.shrink() : Icon(myIcon),
        border:  UnderlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.onPrimary)),

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
      ),
    );
  }
}
