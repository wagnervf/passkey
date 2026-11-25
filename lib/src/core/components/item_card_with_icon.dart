import 'package:flutter/material.dart';

class ItemCardWithIcon extends StatelessWidget {
  const ItemCardWithIcon({
    super.key,
    required this.text,
    required this.subtTitle,
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  final String text;
  final String subtTitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: enabled ? onTap : null,
      leading: Icon(icon, color: enabled ? null : Colors.grey),
      title: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium
            ?.copyWith(color: enabled ? null : Colors.grey),
      ),
      subtitle: Text(
        subtTitle,
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: enabled ? null : Colors.grey),
      ),
    );
  }
}
