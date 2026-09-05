import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/constants/app_enums.dart';
import 'package:woolet/core/theme/app_colors.dart';
import 'package:woolet/core/extensions/localization_x.dart';

extension CategoryTypeUI on CategoryType {
  String get label => switch (this) {
    CategoryType.income => 'Income',
    CategoryType.expense => 'Expense',
  };

  String localizedLabel(BuildContext context) => switch (this) {
    CategoryType.income => context.l10n.income,
    CategoryType.expense => context.l10n.expense,
  };

  IconData get icon => switch (this) {
    CategoryType.income => LucideIcons.arrow_down_right,
    CategoryType.expense => LucideIcons.arrow_up_left,
  };

  Color get backgroundColor => switch (this) {
    CategoryType.income => AppColors.green0,
    CategoryType.expense => AppColors.red0,
  };
}
