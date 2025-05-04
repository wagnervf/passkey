
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:keezy/src/core/router/routes.dart';
import 'package:keezy/src/modules/configuracoes/views/widgets/icon_change_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CardPage extends StatefulWidget {

  const CardPage({super.key});

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
 

   List<Map<String, String>> _savedCards = [];

  @override
  void initState() {
    super.initState();
    _loadSavedCards();
  }

  Future<void> _loadSavedCards() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCardsJson = prefs.getStringList('savedCards');
    if (savedCardsJson != null) {
      setState(() {
        _savedCards = savedCardsJson
            .map((json) => Map<String, String>.from(jsonDecode(json)))
            .toList();
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      drawer: const Drawer(),
      appBar: AppBar(
        title: const SizedBox.shrink(),
        centerTitle: false,
        actions: const [IconChangeTheme()],
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Meus Cartões',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: listView()
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () => context.push(RoutesPaths.formCard),
        child: const Icon(Icons.add_card),
      ),
    );
  }

  listView(){
 return ListView.separated(

      shrinkWrap: true,
      itemCount: _savedCards.length,
      separatorBuilder: (BuildContext context, int index) =>
      
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Divider(height: 0),
          ),
      itemBuilder: (BuildContext context, int index) {
         final card = _savedCards[index];
        return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
         // Borda arredondada
        color: Colors.white, // Cor de fundo
      ),

          child: ListTile(            
            leading:  CircleAvatar(
              backgroundColor: Colors.deepPurple[100],
              foregroundColor: Colors.deepPurple,
              child: const Icon(Icons.person),
            ),
            title: Text(
              card['cardNumber']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(card['cardHolderName'] ?? ''),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_outline),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
                ),
              ],
            ),
            onTap: () {
              // Implementar ação ao tocar no card se necessário
            },
          ),
        );
      },
    );

    //  ListView.builder(
    //               shrinkWrap: true,
    //               itemCount: _savedCards.length,
    //               itemBuilder: (context, index) {
    //                 final card = _savedCards[index];
    //                 return Card(
    //                   margin: const EdgeInsets.symmetric(vertical: 8.0),
    //                   child: ListTile(
    //                     title: Text(card['cardNumber']!),
    //                     subtitle: Text(card['cardHolderName']!),
    //                     trailing: IconButton(
    //                       icon: const Icon(Icons.edit),
    //                       onPressed: () => _editCard(index),
    //                     ),
    //                     onLongPress: () => _confirmDeleteCard(index),
    //                   ),
    //                 );
    //               },
    //             )
  }

  Padding fieldPesquisar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                    hintText: 'Pesquisar',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(8),
                    hintStyle: TextStyle(fontWeight: FontWeight.normal)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // Adicione ação ao botão de pesquisa aqui
              },
            ),
          ],
        ),
      ),
    );
  }
}
