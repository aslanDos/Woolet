import 'package:flutter/material.dart';
import 'package:woolet/core/constants/app_enums.dart';
import 'package:woolet/core/constants/app_icons.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/extensions/transaction_type_x.dart';
import 'package:woolet/core/settings/currency_controller.dart';
import 'package:woolet/core/widgets/pressable.dart';
import 'package:woolet/features/domain/entities/account_entity.dart';
import 'package:woolet/features/domain/entities/category_entity.dart';
import 'package:woolet/features/domain/entities/transaction_entity.dart';

class TransactionCard extends StatelessWidget {
  const TransactionCard({
    super.key,
    required this.transaction,
    required this.account,
    required this.currencyController,
    this.toAccount,
    this.category,
    this.onTap,
  });

  final TransactionEntity transaction;
  final AccountEntity? account;
  final AccountEntity? toAccount;
  final CategoryEntity? category;
  final CurrencyController currencyController;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = category?.colorValue == null
        ? transaction.type.backgroundColor
        : Color(category!.colorValue!);
    final icon = transaction.type == TransactionType.transfer
        ? transaction.type.icon
        : AppIcon.fromCode(category?.iconCode ?? AppIcon.wallet.code).icon;
    final title = transaction.type == TransactionType.transfer
        ? 'Transfer'
        : category?.name ?? transaction.type.label;
    final subtitle = transaction.note.isNotEmpty
        ? transaction.note
        : transaction.type == TransactionType.transfer
        ? '${account?.name ?? 'Account'}   →   ${toAccount?.name ?? 'Account'}'
        : account?.name ?? 'Account';
    final symbol = account == null
        ? currencyController.value.symbol
        : currencyController.symbolForCode(account!.currencyCode);
    final sign = switch (transaction.type) {
      TransactionType.income => '+',
      TransactionType.expense => '−',
      TransactionType.transfer => '',
    };
    final amount = transaction.amountMinor / 100;
    final formatted = amount == amount.truncateToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);

    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: context.c.surfaceContainer,
          borderRadius: .circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accent, size: 24),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.t.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.t.titleSmall?.copyWith(
                      color: context.c.outline,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$sign $formatted $symbol',
              style: context.t.titleMedium?.copyWith(
                color: switch (transaction.type) {
                  TransactionType.income => context.appColors.income,
                  TransactionType.expense => context.appColors.expense,
                  TransactionType.transfer => context.c.primary,
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
