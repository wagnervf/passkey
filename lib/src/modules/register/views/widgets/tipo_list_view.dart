import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:keezy/src/core/utils/utils.dart';

import '../../../type_register/type_register_model.dart';

class TipoListView extends StatefulWidget {
  const TipoListView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TipoListViewState createState() => _TipoListViewState();
}

class _TipoListViewState extends State<TipoListView> {

late List<TypeRegiterModel> displayedAccounts;

  @override
  void initState() {
    super.initState();
    displayedAccounts = tipoRegisterList;
  }

  // ✅ Método de filtro
  void filterAccounts(String query) {
    final results = tipoRegisterList.where((account) {
      final nameLower = account.name.toLowerCase();
      final queryLower = query.toLowerCase();
      return nameLower.contains(queryLower);
    }).toList();

    setState(() {
      displayedAccounts = results;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecine um Tipo'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: filterAccounts,
              autofocus: true,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(                
                hintText: 'Filtrar',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: displayedAccounts.length,
              itemBuilder: (context, index) {
                final account = displayedAccounts[index];
                return Card.filled(
                  margin: const EdgeInsets.all(2),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    leading: FaIcon(Utils.getIcon(account.icon), color: account.color),
                    title: Text(account.name),
                    onTap: () {
                      Navigator.pop(context, account);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

 

}

