import 'package:flutter/material.dart';

class ItemCardWithIcon extends StatelessWidget {
  const ItemCardWithIcon({
    super.key,
    required this.text,
    required this.subtTitle,
    required this.icon,
    required this.onTap,
  });

  final String text;
  final String subtTitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Color corIcon = Theme.of(context).colorScheme.primary;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.only(right: 8, left: 8),
      leading: Icon(icon),
      title: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        subtTitle,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );

    // Card(
    //   child: ListTile(
    //     minTileHeight: 60,
    //     enabled: true,
    //     onTap: onTap,
    //     leading: Icon(icon, color: corIcon),
    //     trailing: Icon(Icons.keyboard_arrow_right, color: corIcon),
    //     title: Text(
    //       text,
    //       style: Theme.of(context).textTheme.displaySmall,
    //     ),
    //   ),
    // );
  }
}
