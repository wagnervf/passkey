import 'package:flutter/material.dart';
import 'package:keezy/src/modules/home/home_page.dart';
import 'package:keezy/src/modules/profile/profile_page.dart';

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
        height: 65,
        indicatorColor: Theme.of(context).colorScheme.tertiary,
        backgroundColor: Theme.of(context).colorScheme.onTertiary,
        labelPadding: EdgeInsets.only(bottom: 0),
        elevation: 5,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.house),
            label: 'Início',
            selectedIcon: Icon(Icons.house),
            tooltip: 'Início',
          ),        
          const NavigationDestination(
            icon: Icon(Icons.account_circle_outlined),
            label: 'Perfil',
            selectedIcon: Icon(Icons.account_circle),
            tooltip: 'Meu Perfil',
          ),
        ],
      ),
    );
  }
}
