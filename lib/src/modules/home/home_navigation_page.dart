import 'package:flutter/material.dart';
import 'package:passkey/src/modules/home/home_page.dart';
import 'package:passkey/src/modules/profile/Profile.dart';

class HomeNavigationPage extends StatefulWidget {
  const HomeNavigationPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeNavigationPageState createState() => _HomeNavigationPageState();
}

class _HomeNavigationPageState extends State<HomeNavigationPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    //final color = Theme.of(context).colorScheme;
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: Theme.of(context).colorScheme.onTertiary,
        elevation: 0,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: <NavigationDestination>[
          NavigationDestination(
            icon:
                Icon(_selectedIndex == 0 ? Icons.house : Icons.house_outlined),
            label: 'Início',
          ),
          // const NavigationDestination(
          //   icon: Icon(Icons.credit_card),
          //   label: 'Cartão',
          // ),
          const NavigationDestination(
            icon: Icon(Icons.account_circle),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
