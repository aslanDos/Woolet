import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/features/domain/entities/account_entity.dart';

class AccountBalanceSummary extends StatelessWidget {
  const AccountBalanceSummary({
    super.key,
    required this.account,
    required this.currencySymbol,
    this.allAccounts = false,
    this.totalBalanceMinor,
    this.totalCurrencySymbol,
    this.incomeMinor = 0,
    this.expenseMinor = 0,
  });

  final AccountEntity? account;
  final String currencySymbol;
  final bool allAccounts;
  final int? totalBalanceMinor;
  final String? totalCurrencySymbol;
  final int incomeMinor;
  final int expenseMinor;

  @override
  Widget build(BuildContext context) => Column(
    children: [
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
    ],
  );

  String get _formattedBalance {
    final balanceMinor = allAccounts
        ? totalBalanceMinor ?? 0
        : account?.balanceMinor ?? 0;
    final symbol = allAccounts ? totalCurrencySymbol : currencySymbol;
    return _formatAmount(balanceMinor, symbol);
  }

  String _formatFlowAmount(int amountMinor) {
    final symbol = allAccounts ? totalCurrencySymbol : currencySymbol;
    return _formatAmount(amountMinor, symbol);
  }

  String _formatAmount(int amountMinor, String? symbol) {
    final value = amountMinor / 100;
    final amount = value == value.truncateToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
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
  Widget build(BuildContext context) => Row(
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
