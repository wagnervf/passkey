import 'package:flutter/material.dart';

class ShowMessager {
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(
    BuildContext context,
    String message,
  ) {
    return ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(message),
    duration: const Duration(seconds: 3),
    elevation: 5,

   
    // action: SnackBarAction(
    //   label: 'Desfazer',
    //   onPressed: () {
    //   },
    // ),
  ),
);

  }
}
