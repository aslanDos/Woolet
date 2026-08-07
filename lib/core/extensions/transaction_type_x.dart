import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/constants/app_enums.dart';
import 'package:woolet/core/theme/app_colors.dart';

extension TransactionTypeUI on TransactionType {
  String get label => switch (this) {
    TransactionType.income => 'Income',
    TransactionType.expense => 'Expense',
    TransactionType.transfer => 'Transfer',
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
