import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class AccountSelector extends StatelessWidget {
  const AccountSelector({super.key, required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [Icon(icon), Text(title), Icon(LucideIcons.chevron_down)],
      ),
    );
  }
}
