import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

enum IconGroup {
  finance('Finance'),
  food('Food'),
  emoji('Emoji'),
  buildings('Buildings'),
  education('Education'),
  beauty('Beauty'),
  home('home'),
  sport('sport'),
  transport('Transport'),
  other('Other');

  const IconGroup(this.label);

  final String label;
}

enum AppIcon {
  banknote(LucideIcons.banknote, .finance),
  creditCard(LucideIcons.credit_card, .finance);

  const AppIcon(this.icon, this.group);

  final IconData icon;
  final IconGroup group;
}
