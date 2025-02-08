import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:passkey/src/core/router/routes.dart';
import 'package:passkey/src/modules/register/controller/register_controller.dart';
import 'package:passkey/src/modules/register/controller/register_state.dart';
import 'package:passkey/src/modules/register/model/registro_model.dart';

class ListRegisters extends StatefulWidget {
  const ListRegisters({super.key});

  @override
  State<ListRegisters> createState() => _ListRegistersState();
}

class _ListRegistersState extends State<ListRegisters> {
  @override
  void initState() {
    super.initState();
    getAllRegister();
  }

  getAllRegister() async {
    await context.read<RegisterController>().getRegisterController();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterController, RegisterState>(
      builder: (context, state) {
        switch (state) {
          case RegisterLoading():
            return const Center(
              child: SizedBox(
                height: 300,
                child: CircularProgressIndicator(),
              ),
            );
          case RegisterError():
            return const Text('Erro');
          case RegisterLoaded():
            final informacoes = state.register;
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                fieldPesquisar(),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text('Meus Registros',
                      style: Theme.of(context).textTheme.titleSmall),
                ),
                const SizedBox(height: 10),
                listRegistros(informacoes),
                const SizedBox(height: 10),
              ],
            );
        }
        return Column(
          children: [
            Card(
              child: TextButton.icon(
                  onPressed: () =>
                      GoRouter.of(context).push(RoutesPaths.register),
                  label: const Text(
                    'Adicionar Registro',
                  ),
                  icon: const Icon(Icons.add)),
            ),
            const SizedBox(height: 10),
          ],
        );
        // : SizedBox.shrink();
      },
    );
  }

  final List<Color> cores = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.brown
  ];

  ListView listRegistros(List<RegisterModel> registers) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: registers.length,
      itemBuilder: (BuildContext context, int index) {
        RegisterModel register = registers[index];
        Color corDeFundo = cores[index % cores.length];
        return Card(
          elevation: 1,
          margin: const EdgeInsets.all(1),
          child: ListTile(
            onTap: () => _goToView(register),
            shape: const Border(),
            leading: iconDay(register, context, corDeFundo),
            dense: false,
            title: Text(
              register.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(register.title,
                    style: Theme.of(context).textTheme.bodySmall),
                // Text(register.id.toString(),
                //     style: Theme.of(context).textTheme.bodySmall)
              ],
            ),
            trailing: const Icon(Icons.remove_red_eye),
          ),
        );
      },
    );
  }

  _goToView(RegisterModel registers) async {
    await GoRouter.of(context).push(RoutesPaths.registerView, extra: registers);
  }

  _goToEdit(RegisterModel register) async {
    await GoRouter.of(context).push(RoutesPaths.register, extra: register);
  }

  CircleAvatar iconDay(RegisterModel register, context, Color cor) {
    return CircleAvatar(
      backgroundColor: cor,
      radius: 25,
      child: Center(
        child: Text(
          register.title[0]
              .toUpperCase(), // Pega a primeira letra e coloca maiúscula
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Container fieldPesquisar() {
    var borderSide = const BorderSide(color: Colors.transparent);
    var borderRadius = const BorderRadius.all(Radius.circular(16.0));
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.surface,

      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              decoration: InputDecoration(
                  hintText: 'Pesquisar',
                  border: OutlineInputBorder(
                    borderSide: borderSide, 
                    borderRadius: borderRadius,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: borderSide, 
                    borderRadius: borderRadius,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: borderSide, 
                    borderRadius: borderRadius,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  contentPadding: const EdgeInsets.all(8),
                  hintStyle: const TextStyle(fontWeight: FontWeight.normal)),
            ),
          ),
          // const SizedBox(
          //   width: 10,
          // ),
          // const Icon(Icons.filter_alt_outlined)
        ],
      ),
    );
  }
}
