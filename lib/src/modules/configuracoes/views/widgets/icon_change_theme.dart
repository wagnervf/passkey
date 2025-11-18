import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keezy/src/core/theme/controller/theme_controller.dart';
import 'package:provider/provider.dart';

class IconChangeTheme extends StatelessWidget {
  const IconChangeTheme({super.key});

  @override
  Widget build(BuildContext context) {
    final themeConfig = context.watch<ThemeController>();

    return SwitchListTile(
      title: Text(
        'Tema Escuro',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        'Ative o modo escuro',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      secondary: Icon(
        themeConfig.isDark
            ? Icons.dark_mode_outlined
            : Icons.light_mode_outlined,
      ),
      value: themeConfig.isDark,
      onChanged: (_) => themeConfig.toggleTheme(),
      activeThumbColor: themeConfig.isDark
            ? Theme.of(context).colorScheme.secondary

            : Theme.of(context).colorScheme.primary,
      
    );
  }
}
