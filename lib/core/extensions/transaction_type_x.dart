import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/constants/app_enums.dart';
import 'package:woolet/core/theme/app_colors.dart';
import 'package:woolet/core/extensions/localization_x.dart';

extension TransactionTypeUI on TransactionType {
  String get label => switch (this) {
    TransactionType.income => 'Income',
    TransactionType.expense => 'Expense',
    TransactionType.transfer => 'Transfer',
  };

  String localizedLabel(BuildContext context) => switch (this) {
    TransactionType.income => context.l10n.income,
    TransactionType.expense => context.l10n.expense,
    TransactionType.transfer => context.l10n.transfer,
  };

  String get sign => switch (this) {
    TransactionType.income => '+',
    TransactionType.expense => '−',
    TransactionType.transfer => '',
  };

  IconData get icon => switch (this) {
    TransactionType.income => LucideIcons.arrow_down_right,
    TransactionType.expense => LucideIcons.arrow_up_left,
    TransactionType.transfer => LucideIcons.arrow_up_down,
  };

  Color get backgroundColor => switch (this) {
    TransactionType.income => AppColors.green0,
    TransactionType.expense => AppColors.red0,
    TransactionType.transfer => AppColors.blue0,
  };
}
