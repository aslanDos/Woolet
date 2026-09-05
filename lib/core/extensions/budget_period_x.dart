import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/constants/app_enums.dart';
import 'package:woolet/core/extensions/localization_x.dart';

extension BudgetPeriodX on BudgetPeriod {
  String get label => switch (this) {
    BudgetPeriod.daily => 'Daily',
    BudgetPeriod.weekly => 'Weekly',
    BudgetPeriod.monthly => 'Monthly',
    BudgetPeriod.yearly => 'Yearly',
  };

  String localizedLabel(BuildContext context) => switch (this) {
    BudgetPeriod.daily => context.l10n.daily,
    BudgetPeriod.weekly => context.l10n.weekly,
    BudgetPeriod.monthly => context.l10n.monthly,
    BudgetPeriod.yearly => context.l10n.yearly,
  };

  IconData get icon => switch (this) {
    BudgetPeriod.daily => LucideIcons.calendar_heart,
    BudgetPeriod.weekly => LucideIcons.calendar_days,
    BudgetPeriod.monthly => LucideIcons.calendar_range,
    BudgetPeriod.yearly => LucideIcons.calendar_1,
  };
}
