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
  banknote('banknote', LucideIcons.banknote, .finance),
  creditCard('credit_card', LucideIcons.credit_card, .finance),
  circleDollarSign(
    'circle_dollar_sign',
    LucideIcons.circle_dollar_sign,
    .finance,
  ),
  landmark('landmark', LucideIcons.landmark, .finance),
  trendingUp('trending_up', LucideIcons.trending_up, .finance),
  wallet('wallet', LucideIcons.wallet, .finance),
  briefcase('briefcase', LucideIcons.briefcase_business, .finance),
  gift('gift', LucideIcons.gift, .other),
  groceries('groceries', LucideIcons.shopping_cart, .food),
  cafe('cafe', LucideIcons.utensils, .food),
  entertainment('entertainment', LucideIcons.gamepad_2, .other),
  fuel('fuel', LucideIcons.fuel, .transport),
  shopping('shopping', LucideIcons.shopping_bag, .other),
  taxi('taxi', LucideIcons.car_taxi_front, .transport),
  home('home', LucideIcons.house, .home),
  car('car', LucideIcons.car_front, .transport),
  pharmacy('pharmacy', LucideIcons.pill, .beauty);

  const AppIcon(this.code, this.icon, this.group);

  final String code;
  final IconData icon;
  final IconGroup group;

  static AppIcon fromCode(String code) {
    return values.firstWhere(
      (appIcon) => appIcon.code == code,
      orElse: () => AppIcon.wallet,
    );
  }
}
