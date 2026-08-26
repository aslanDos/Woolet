import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/constants/app_icons.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/utils/amount_utils.dart';
import 'package:woolet/features/domain/entities/account_entity.dart';
import 'package:woolet/features/presentation/widgets/base_card.dart';
import 'package:woolet/features/presentation/widgets/icon_preview.dart';

class AccountCard extends StatelessWidget {
  const AccountCard({
    super.key,
    required this.account,
    required this.currencySymbol,
    this.onTap,
    this.onEdit,
  });

  final AccountEntity account;
  final String currencySymbol;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final accentColor = account.colorValue == null
        ? context.c.primary
        : Color(account.colorValue!);
    final icon = AppIcon.fromCode(account.iconCode).icon;

    return BaseCard(
      onTap: onTap,
      semanticLabel: account.name,
      leading: IconPreview.card(icon: icon, color: accentColor),
      title: Text(
        account.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.t.titleMedium,
      ),
      subtitle: Text(
        '${AmountUtils.formatMinor(account.balanceMinor)} $currencySymbol',
        style: context.t.bodyMedium?.copyWith(
          color: context.c.onSurfaceVariant,
        ),
      ),
      trailing: IconButton(
        onPressed: onEdit,
        icon: const Icon(LucideIcons.pen, size: 19),
      ),
    );
  }
}
