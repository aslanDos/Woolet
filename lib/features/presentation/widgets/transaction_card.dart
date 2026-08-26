import 'package:flutter/material.dart';
import 'package:woolet/core/constants/app_enums.dart';
import 'package:woolet/core/constants/app_icons.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/extensions/transaction_type_x.dart';
import 'package:woolet/core/settings/currency_controller.dart';
import 'package:woolet/core/utils/amount_utils.dart';
import 'package:woolet/features/domain/entities/account_entity.dart';
import 'package:woolet/features/domain/entities/category_entity.dart';
import 'package:woolet/features/domain/entities/transaction_entity.dart';
import 'package:woolet/features/presentation/widgets/base_card.dart';
import 'package:woolet/features/presentation/widgets/icon_preview.dart';

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
    final formatted = AmountUtils.formatMinor(transaction.amountMinor);

    return BaseCard(
      onTap: onTap,
      semanticLabel: title,
      contentSpacing: 10,
      subtitleSpacing: 4,
      leading: IconPreview.card(icon: icon, color: accent),
      title: Text(title, style: context.t.titleLarge),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.t.titleSmall?.copyWith(color: context.c.outline),
      ),
      trailing: Text(
        '${transaction.type.sign} $formatted $symbol',
        style: context.t.titleMedium?.copyWith(
          color: switch (transaction.type) {
            TransactionType.income => context.appColors.income,
            TransactionType.expense => context.appColors.expense,
            TransactionType.transfer => context.c.primary,
          },
        ),
      ),
    );
  }
}
