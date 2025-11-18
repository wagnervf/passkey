import 'package:flutter/material.dart';

class ShowLoading extends StatelessWidget {
  const ShowLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(''),
        ),
        body: SizedBox(
          child: _showLoading(context),
        ));
  }

  AlertDialog _showLoading(BuildContext context) {
    return AlertDialog(
      title: const Text('Carregando'),
      content: Column(
        children: [
          Center(
            child: CircularProgressIndicator(),
          )
        ],
      ),
      actions: [],
    );
  }
}
