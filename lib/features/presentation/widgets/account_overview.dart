import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/widgets/pressable.dart';
import 'package:woolet/features/domain/entities/account_entity.dart';
import 'package:woolet/features/presentation/sheets/periods_sheet.dart';
import 'package:woolet/features/presentation/widgets/account_selector.dart';

class AccountOverview extends StatelessWidget {
  const AccountOverview({
    super.key,
    required this.account,
    required this.period,
    required this.onAccountTap,
    required this.onPeriodTap,
    required this.onPreviousPeriod,
    required this.onNextPeriod,
    required this.currencySymbol,
    this.allAccounts = false,
    this.totalBalanceMinor,
    this.totalCurrencySymbol,
    this.incomeMinor = 0,
    this.expenseMinor = 0,
  });

  final AccountEntity? account;
  final PeriodSelection period;
  final VoidCallback onAccountTap;
  final VoidCallback onPeriodTap;
  final VoidCallback onPreviousPeriod;
  final VoidCallback onNextPeriod;
  final String currencySymbol;
  final bool allAccounts;
  final int? totalBalanceMinor;
  final String? totalCurrencySymbol;
  final int incomeMinor;
  final int expenseMinor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          AccountSelector(
            account: account,
            onTap: onAccountTap,
            background: true,
            allAccounts: allAccounts,
          ),
          const SizedBox(height: 32),
          Text(_formattedBalance, style: context.t.displayMedium),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _FlowAmount(
                icon: LucideIcons.arrow_down_right,
                amount: _formatFlowAmount(incomeMinor),
                color: context.appColors.income,
              ),
              const SizedBox(width: 24),
              _FlowAmount(
                icon: LucideIcons.arrow_up_left,
                amount: _formatFlowAmount(expenseMinor),
                color: context.appColors.expense,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _PeriodArrow(
                visible: period.canNavigate,
                onPressed: onPreviousPeriod,
                icon: LucideIcons.chevron_left,
              ),
              Pressable(
                onTap: onPeriodTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: context.c.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    period.label(context),
                    textAlign: TextAlign.center,
                    style: context.t.titleMedium,
                  ),
                ),
              ),
              _PeriodArrow(
                visible: period.canNavigate,
                onPressed: onNextPeriod,
                icon: LucideIcons.chevron_right,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String get _formattedBalance {
    final balanceMinor = allAccounts
        ? totalBalanceMinor ?? 0
        : account?.balanceMinor ?? 0;
    final balance = balanceMinor / 100;
    final amount = balance == balance.truncateToDouble()
        ? balance.toStringAsFixed(0)
        : balance.toStringAsFixed(2);
    final symbol = allAccounts ? totalCurrencySymbol : currencySymbol;
    return symbol == null ? amount : '$amount $symbol';
  }

  String _formatFlowAmount(int amountMinor) {
    final value = amountMinor / 100;
    final amount = value == value.truncateToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
    final symbol = allAccounts ? totalCurrencySymbol : currencySymbol;
    return symbol == null ? amount : '$amount $symbol';
  }
}

class _FlowAmount extends StatelessWidget {
  const _FlowAmount({
    required this.icon,
    required this.amount,
    required this.color,
  });

  final IconData icon;
  final String amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 8),
        Text(amount, style: context.t.titleMedium?.copyWith(color: color)),
      ],
    );
  }
}

class _PeriodArrow extends StatelessWidget {
  const _PeriodArrow({
    required this.visible,
    required this.onPressed,
    required this.icon,
  });

  final bool visible;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      child: IconButton(onPressed: onPressed, icon: Icon(icon, size: 16)),
    );
  }
}
