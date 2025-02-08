// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class DialogUtils {
  static void showSuccessDialog(BuildContext context, String message) {
    showDialog(

      context: context,
      barrierDismissible: false,
      useSafeArea: true,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 60,
              child: CircleAvatar(
                foregroundColor: Colors.green,
                backgroundColor: Colors.green[100],
                child: const Center(
                  child: Icon(
                    Icons.check,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(28.0),
              child: LinearProgressIndicator(backgroundColor: Colors.green,),
            )
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
    //  GoRouter.of(context).pop();
      //GoRouter.of(context).pushReplacement(RoutesPaths.home);
    });
  }
}
