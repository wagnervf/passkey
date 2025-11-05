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
    return ListTile(
      onTap: onTap,
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

  }
}
