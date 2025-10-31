import 'package:flutter/material.dart';
import 'package:keezy/src/core/utils/utils.dart';

// ignore: must_be_immutable
class MyTextField extends StatelessWidget {
  MyTextField({
    super.key,
    required this.description,
    required this.myController,
    this.icon,
  });

  final TextEditingController myController;
  String description;
  IconData? icon;
  
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: myController,
      decoration: Utils.decorationField(description, icon)
    );
  }


  
}
