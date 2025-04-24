import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:passkey/src/core/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreditCardForm extends StatefulWidget {
  const CreditCardForm({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CreditCardFormPageState createState() => _CreditCardFormPageState();
}

class _CreditCardFormPageState extends State<CreditCardForm> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderNameController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final bool _showCardNumber = false;
  final bool _showExpiryDate = false;
  final bool _showCVV = false;
  final List<Map<String, String>> _savedCards = [];
  String _selectedCardType = '';
  final ScrollController scroll = ScrollController();

  @override
  Widget build(BuildContext context) {
    const inputDecoration = InputDecoration(
        border: InputBorder.none,
        prefixIcon: Icon(Icons.email, color: Color(0xFF8700C3)),
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        contentPadding:
            EdgeInsets.only(left: 20, bottom: 11, top: 11, right: 15),
        hintText: "Email");
    const inputDecoration2 = InputDecoration(
        prefixIcon: Icon(Icons.lock, color: Color(0xFF8700C3)),
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        contentPadding:
            EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
        hintText: "Password");

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Cartão'),
      ),
      body: SingleChildScrollView(
        controller: scroll,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                numberCard(),
                const SizedBox(height: 16.0),
                nameCard(),
                const SizedBox(height: 16.0),
                dateAndCvvCard(),
                const SizedBox(height: 16.0),
                typeCard(),
                TextField(
                  onChanged: (text) {
                    setState(() {});
                  },
                  obscureText: true,
                  obscuringCharacter: "*",
                  decoration: inputDecoration2,
                  //controller: passwordController,
                  style: const TextStyle(fontSize: 16),
                ),
                TextField(
                  onChanged: (text) {
                    setState(() {});
                  },
                  decoration: inputDecoration,
                  style: const TextStyle(fontSize: 16),
                  // controller: usernameController
                ),
                const SizedBox(height: 16.0),
                saveCard(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  saveCard(BuildContext context) {
    return SizedBox(
      width: Utils.width(context),
      child: FilledButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            final cardData = {
              'cardNumber': _cardNumberController.text,
              'cardHolderName': _cardHolderNameController.text,
              'expiryDate': _expiryDateController.text,
              'cvv': _cvvController.text,
              'cardType': _selectedCardType,
            };
            await saveCardData(cardData);
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cartão Salvo com Sucesso!')),
            );
            _clearForm();
          }
        },
        child: const Text('Salvar Cartão',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Container typeCard() {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(2.0),
      child: DropdownButtonFormField<String>(
        value: _selectedCardType.isNotEmpty ? _selectedCardType : null,
        onChanged: (value) {
          setState(() {
            _selectedCardType = value!;
          });
        },
        borderRadius: BorderRadius.circular(15),
        padding: const EdgeInsets.all(2),
        items: ['Visa', 'Master', 'Cielo']
            .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                ))
            .toList(),
        decoration: decorationField('Bandeira'),
      ),
    );
  }

  Row dateAndCvvCard() {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(0),
            decoration: borderField(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                headerField('Data de Expiração', Icons.numbers),
                const Divider(),
                TextFormField(
                  controller: _expiryDateController,
                  obscureText: !_showExpiryDate,
                  decoration: inputDecorationForm(_showExpiryDate),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter expiry date';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(0),
            decoration: borderField(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                headerField('Código', Icons.numbers),
                const Divider(),
                TextFormField(
                  controller: _cvvController,
                  obscureText: !_showCVV,
                  decoration: inputDecorationForm(_showCVV),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter CVV';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Container nameCard() {
    return Container(
      margin: const EdgeInsets.all(0),
      decoration: borderField(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          headerField('Nome do Cartão', Icons.numbers),
          const Divider(),
          TextFormField(
            controller: _cardHolderNameController,
            decoration: decorationField('Digite aqui'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter cardholder name';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Container numberCard() {
    return Container(
      margin: const EdgeInsets.all(0),
      decoration: borderField(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          headerField('Número do Cartão', Icons.numbers),
          const Divider(),
          TextFormField(
            controller: _cardNumberController,
            obscureText: !_showCardNumber,
            decoration: inputDecorationForm(_showCardNumber),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter card number';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  BoxDecoration borderField() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      color: Colors.white,
    );
  }

  Padding headerField(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
    );
  }

  InputDecoration inputDecorationForm(bool show) {
    return InputDecoration(
      labelText: 'Clique aqui',
      contentPadding: const EdgeInsets.all(12),
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: Colors.grey),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(15),
      ),
      suffixIcon: IconButton(
        icon: Icon(show ? Icons.visibility : Icons.visibility_off),
        onPressed: () {
          setState(() {
            show = !show;
          });
        },
      ),
    );
  }

  InputDecoration decorationField(String description) {
    return InputDecoration(
      contentPadding: const EdgeInsets.all(12),
      hintText: description,
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: Colors.grey),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }

  Future<void> saveCardData(Map<String, String> cardData) async {
    final prefs = await SharedPreferences.getInstance();
    final savedCardsJson = prefs.getStringList('savedCards') ?? [];
    savedCardsJson.add(jsonEncode(cardData));
    await prefs.setStringList('savedCards', savedCardsJson);
    setState(() {
      _savedCards.add(cardData);
    });
  }

  void _editCard(int index) {
    final card = _savedCards[index];
    _cardNumberController.text = card['cardNumber']!;
    _cardHolderNameController.text = card['cardHolderName']!;
    _expiryDateController.text = card['expiryDate']!;
    _cvvController.text = card['cvv']!;
    setState(() {
      _selectedCardType = card['cardType']!;
    });
  }

  Future<void> _confirmDeleteCard(int index) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this card?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirmDelete == true) {
      _deleteCard(index);
    }
  }

  void _deleteCard(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final savedCardsJson = prefs.getStringList('savedCards');
    if (savedCardsJson != null) {
      savedCardsJson.removeAt(index);
      await prefs.setStringList('savedCards', savedCardsJson);
      setState(() {
        _savedCards.removeAt(index);
      });
    }
  }

  void _clearForm() {
    _cardNumberController.clear();
    _cardHolderNameController.clear();
    _expiryDateController.clear();
    _cvvController.clear();
    _selectedCardType = '';
  }
}
