// welcome_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:keezy/src/core/router/routes.dart'; // Required for Timer

class WelcomeScreenOne extends StatefulWidget {
  const WelcomeScreenOne({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WelcomeScreenOneState createState() => _WelcomeScreenOneState();
}

class _WelcomeScreenOneState extends State<WelcomeScreenOne> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel(); 
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      // Change slide every 5 seconds
      if (_currentPage < 3) {
        // Assuming 3 pages (0, 1, 2)
        _currentPage++;
      } else {
        _currentPage = 0; // Loop back to the first page
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 10,
        automaticallyImplyLeading: false,
        leading: SizedBox.shrink(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              'Bem-vindo ao Keezy!',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: 4,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  switch (index) {
                    case 0:
                      return _buildCarouselPage(
                        context,
                        icon: Icons.lock_outline,
                        title: 'Proteja Seus Dados',
                        description:
                            'Armazenamento criptografado e acesso fácil quando precisar',
                      );
                    case 1:
                      return _buildCarouselPage(
                        context,
                        icon: Icons.cloud_queue,
                        title: 'Acesso Onde Estiver',
                        description:
                            'Seus dados sempre disponíveis, com ou sem conta na nuvem, como preferir.',
                      );
                    case 2:
                      return _buildCarouselPage(
                        context,
                        icon: Icons.security,
                        title: 'Sua Privacidade em Primeiro Lugar',
                        description:
                            'Com criptografia de ponta a ponta, só você tem acesso ao seu cofre digital.',
                      );
                    case 3:
                      return _buildCarouselPage(
                        context,
                        icon: Icons.wb_cloudy_outlined,
                        title: 'Importe suas Senhas do Google Chrome',
                        description:
                            'Com criptografia de ponta a ponta, só você tem acesso ao seu cofre digital.',
                      );
                    default:
                      return Container(); // Should not happen
                  }
                },
              ),
            ),
            // Page indicators
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 150),
                    margin: EdgeInsets.symmetric(horizontal: 4.0),
                    height: 8.0,
                    width: _currentPage == index ? 24.0 : 8.0,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Theme.of(context).primaryColor
                          : Colors.grey[400],
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  );
                }),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: ElevatedButton(
                onPressed: () {
                  context.push(RoutesPaths.createMasterPassword);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize:
                      Size(double.infinity, 50), // Make button full width
                ),
                child: Text(
                  'Começar',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselPage(BuildContext context,
      {required IconData icon,
      required String title,
      required String description}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 100,
             color: Theme.of(context).primaryColor,
        ),
        SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
