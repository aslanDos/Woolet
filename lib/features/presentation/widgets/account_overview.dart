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
    this.allAccounts = false,
    this.totalBalanceMinor,
    this.totalCurrencyCode,
  });

  final AccountEntity? account;
  final PeriodSelection period;
  final VoidCallback onAccountTap;
  final VoidCallback onPeriodTap;
  final VoidCallback onPreviousPeriod;
  final VoidCallback onNextPeriod;
  final bool allAccounts;
  final int? totalBalanceMinor;
  final String? totalCurrencyCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
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
    final currencyCode = allAccounts
        ? totalCurrencyCode
        : account?.currencyCode ?? 'KZT';
    return currencyCode == null ? amount : '$amount $currencyCode';
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
