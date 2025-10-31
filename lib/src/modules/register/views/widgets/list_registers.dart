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
  final TextEditingController _searchController = TextEditingController();
  List<RegisterModel> todosRegistros = [];
  List<RegisterModel> registrosFiltrados = [];

  OrdemRegistros _ordemAtual = OrdemRegistros.data;

  @override
  void initState() {
    super.initState();
    getAllRegister();
     WidgetsBinding.instance.addPostFrameCallback((_) { 
            _ordenarRegistros(OrdemRegistros.data);
          });
  }

  Future<void> getAllRegister() async {
    await context.read<RegisterController>().getRegisterController();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterController, RegisterState>(
      builder: (context, state) {
        if (state is RegisterLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is RegisterError) {
          return const Center(
            child: Text('Ocorreu um erro ao carregar os registros.'),
          );
        }

        if (state is RegisterLoaded) {
          todosRegistros = state.register;
          if (todosRegistros.isEmpty) {
            return emptyRegisters(context);
          }
         

          if (_searchController.text.isEmpty) {
            registrosFiltrados = todosRegistros;
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _filtrarRegistros(_searchController.text);
            });
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              fieldPesquisar(),
              const SizedBox(height: 12),
              _barraDeAcoes(),
              const SizedBox(height: 8),
              Expanded(
                child: listRegistros(registrosFiltrados),
              ),
              const SizedBox(height: 10),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget listRegistros(List<RegisterModel> registers) {
    return ListView.separated(
      itemCount: registers.length,
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (BuildContext context, int index) {
        final register = registers[index];
        final corDeFundo = cores[index % cores.length];
        final nome = register.selectedApp?.name ?? register.name ?? '';

        return ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          onTap: () => _goToView(register),
          leading: register.selectedApp?.iconBytes != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.memory(
                    register.selectedApp!.iconBytes!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                )
              : iconDay(register, context, corDeFundo),
          title: Text(
            nome,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: register.username?.isNotEmpty == true
              ? Text(
                  register.username!,
                  style: Theme.of(context).textTheme.bodySmall,
                )
              : null,
          trailing: Padding(
            padding: const EdgeInsets.symmetric( horizontal: 8.0),
            child: const Icon(Icons.remove_red_eye),
          ),
        );
      },
    );
  }

  _barraDeAcoes() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: 8.0,
        children: [
          SizedBox(
              //width: 100,
              height: 30,
              child: OutlinedButton.icon(
                // style: ButtonStyle(
                //     backgroundColor: WidgetStatePropertyAll(
                //   Theme.of(context).colorScheme.tertiary,
                // )),

                style: OutlinedButton.styleFrom(
                    backgroundColor: _ordemAtual == OrdemRegistros.nome
                        ? Theme.of(context).colorScheme.tertiary
                        : Colors.white,
                    foregroundColor: _ordemAtual == OrdemRegistros.nome
                        ? Colors.black
                        : Colors.grey.shade800,
                    side: BorderSide(
                        color: Theme.of(context).colorScheme.tertiary)),
                onPressed: () => _ordenarRegistros(OrdemRegistros.nome),
                label:
                    Text('Nome', style: Theme.of(context).textTheme.bodySmall),
                icon: Icon(
                  Icons.arrow_circle_up_sharp,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              )),
          SizedBox(
              //width: 100,
              height: 30,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                    backgroundColor: _ordemAtual == OrdemRegistros.data
                        ? Theme.of(context).colorScheme.tertiary
                        : Colors.white,
                    foregroundColor: _ordemAtual == OrdemRegistros.data
                        ? Colors.black
                        : Colors.grey.shade800,
                    side: BorderSide(
                        color: Theme.of(context).colorScheme.tertiary)),
                onPressed: () => _ordenarRegistros(OrdemRegistros.data),
                label: Text('Criação',
                    style: Theme.of(context).textTheme.bodySmall),
                icon: Icon(
                  Icons.arrow_circle_up_sharp,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              )),
        ],
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

  Future<void> _goToView(RegisterModel register) async {
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
          name?[0].toUpperCase() ?? 'R',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Padding fieldPesquisar() {
    var borderSide = const BorderSide(color: Colors.transparent);
    var borderRadius = const BorderRadius.all(Radius.circular(16.0));

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        onChanged: _filtrarRegistros,
        decoration: InputDecoration(
            hintText: '   Pesquisar',
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(
                Icons.search,
              ),
            ),
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
            //fillColor: Colors.grey[100],
            fillColor: Theme.of(context).colorScheme.onPrimary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            hintStyle: const TextStyle(fontWeight: FontWeight.normal)),
      ),
    );
  }

  void _filtrarRegistros(String query) {
    final queryLower = query.toLowerCase();

    setState(() {
      registrosFiltrados = todosRegistros.where((registro) {
        final username = registro.username?.toLowerCase() ?? '';
        final nome = registro.name?.toLowerCase() ?? '';
        final app = registro.selectedApp?.name.toLowerCase() ?? '';
        final login = registro.username?.toLowerCase() ?? '';
        return username.contains(queryLower) ||
            nome.contains(queryLower) ||
            app.contains(queryLower) ||
            login.contains(queryLower);
      }).toList();

      print(registrosFiltrados.toString());
    });
  }

  void _ordenarRegistros(OrdemRegistros ordem) {
    setState(() {
      _ordemAtual = ordem;

      registrosFiltrados.sort((a, b) {
        if (ordem == OrdemRegistros.nome) {
          final nomeA = a.name?.toLowerCase() ?? '';
          final nomeB = b.name?.toLowerCase() ?? '';
          return nomeA.compareTo(nomeB);
        } else {
          return b.id
              .compareTo(a.id); // Supondo que `id` seja crescente com o tempo
        }
      });
    });
  }
}

enum OrdemRegistros { nome, data }
