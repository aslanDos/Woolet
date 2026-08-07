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
  creditCard(LucideIcons.credit_card, .finance),
  circleDollarSign(LucideIcons.circle_dollar_sign, .finance),
  landmark(LucideIcons.landmark, .finance),
  trendingUp(LucideIcons.trending_up, .finance),
  wallet(LucideIcons.wallet, .finance),
  briefcase(LucideIcons.briefcase_business, .finance),
  gift(LucideIcons.gift, .other),
  groceries(LucideIcons.shopping_cart, .food),
  cafe(LucideIcons.utensils, .food),
  entertainment(LucideIcons.gamepad_2, .other),
  fuel(LucideIcons.fuel, .transport),
  shopping(LucideIcons.shopping_bag, .other),
  taxi(LucideIcons.car_taxi_front, .transport),
  home(LucideIcons.house, .home),
  car(LucideIcons.car_front, .transport),
  pharmacy(LucideIcons.pill, .beauty);

  const AppIcon(this.icon, this.group);

  final IconData icon;
  final IconGroup group;
}
