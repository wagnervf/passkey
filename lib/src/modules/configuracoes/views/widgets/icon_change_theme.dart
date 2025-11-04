import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keezy/src/core/theme/controller/theme_controller.dart';
import 'package:provider/provider.dart';

class IconChangeTheme extends StatelessWidget {
  const IconChangeTheme({super.key});

  @override
  Widget build(BuildContext context) {
    final themeConfig = context.watch<ThemeController>();

    return Card(
      child: SwitchListTile(
        title: const Text(
          'Tema Escuro',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: const Text(
          'Ative o modo escuro para uma melhor experiência visual.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        secondary: Icon(
          themeConfig.isDark
              ? Icons.dark_mode_outlined
              : Icons.light_mode_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
        value: themeConfig.isDark,
        onChanged: (_) => themeConfig.toggleTheme(),
        activeColor: Theme.of(context).colorScheme.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      ),
    );
  }
}
