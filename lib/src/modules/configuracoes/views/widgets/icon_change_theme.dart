import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passkey/src/core/components/item_card_with_icon.dart';
import 'package:passkey/src/core/theme/controller/theme_controller.dart';

class IconChangeTheme extends StatelessWidget {
  const IconChangeTheme({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final themeConfig = context.watch<ThemeController>();
    return ItemCardWithIcon(
      text: 'Mudar Tema',
      subtTitle: 'Mude o tema do aplicativo',
      icon: themeConfig.isDark
          ? Icons.light_mode_outlined
          : Icons.dark_mode_outlined,
      onTap: () => themeConfig.toggleTheme(),
    );
  }
}
