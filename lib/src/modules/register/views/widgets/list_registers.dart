import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:keezy/src/core/router/routes.dart';
import 'package:keezy/src/modules/register/controller/register_controller.dart';
import 'package:keezy/src/modules/register/controller/register_state.dart';
import 'package:keezy/src/modules/register/model/register_model.dart';

class ListRegisters extends StatefulWidget {
  const ListRegisters({super.key});
  //final AuthUserModel? user;
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
    //final tema = Theme.of(context).textTheme;
    return BlocBuilder<RegisterController, RegisterState>(
      builder: (context, state) {
        switch (state) {
          case RegisterLoading():
            return SizedBox(
              height: MediaQuery.of(context).size.height * .8,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          case RegisterError():
            return const Text('Erro');
          case RegisterLoaded():
            final informacoes = state.register;

            return informacoes.isEmpty
                ? emptyRegisters(context)
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        fieldPesquisar(),
                        const SizedBox(height: 10),
                        Text(
                          'Meus Registros',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        _barraDeAcoes(),
                        SizedBox(
                          height: 600,
                          child: listRegistros(informacoes),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  );
        }
        return SizedBox.shrink();
      },
    );
  }

  _barraDeAcoes() {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      leading: TextButton.icon(
        onPressed: () {},
        label: Text('Nome', style: Theme.of(context).textTheme.titleSmall),
        icon: Icon(
          Icons.arrow_circle_up_sharp,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }

  emptyRegisters(BuildContext context) {
    return Center(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * .8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Você ainda não possui nenhum Registro!'),
            const SizedBox(height: 10),
            Card(
              child: TextButton.icon(
                  onPressed: () =>
                      GoRouter.of(context).push(RoutesPaths.register),
                  label: const Text(
                    'Clique aqui para adicionar um Registro',
                  ),
                  icon: const Icon(Icons.add)),
            ),
          ],
        ),
      ),
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
      scrollDirection: Axis.vertical,
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
         //  leading: iconDay(register, context, corDeFundo),
             leading: register.selectedApp!.iconBytes != null
                                ? Image.memory((register.selectedApp!.iconBytes!),
                                    width: 40, height: 40)
                                : iconDay(register, context, corDeFundo),
            dense: false,
            title: Text(
              register.selectedApp?.name.toString() ?? '',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            // Text(
            //   register.name ?? '',
            //   style: Theme.of(context).textTheme.titleMedium,
            // ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(register.username ?? '',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            trailing: const Icon(Icons.remove_red_eye),
          ),
        );
      },
    );
  }

  _goToView(RegisterModel register) async {
    await GoRouter.of(context).push(RoutesPaths.register, extra: register);
  }

  CircleAvatar iconDay(RegisterModel register, context, Color cor) {
    final String? name =
        register.name != '' ? register.name : register.username;
    return CircleAvatar(
      backgroundColor: cor,
      radius: 25,
      child: Center(
        child: Text(
          " name",
          //name?[0] ?? 'R' .toUpperCase(),
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
      padding: const EdgeInsets.symmetric(horizontal: 6),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      child: TextFormField(
        decoration: InputDecoration(
            hintText: '   Pesquisar',
            prefixIcon: Icon(Icons.search),
            prefixIconConstraints: BoxConstraints.loose(const Size(20, 20)),
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
            fillColor: Theme.of(context).colorScheme.onPrimary,
            contentPadding: const EdgeInsets.all(8),
            hintStyle: const TextStyle(fontWeight: FontWeight.normal)),
      ),
    );
  }
}
