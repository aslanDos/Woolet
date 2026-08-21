import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/constants/app_icons.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/widgets/pressable.dart';
import 'package:woolet/features/domain/entities/account_entity.dart';

class AccountSelector extends StatelessWidget {
  const AccountSelector({
    super.key,
    required this.account,
    this.onTap,
    this.background = false,
    this.allAccounts = false,
  });

  final AccountEntity? account;
  final VoidCallback? onTap;
  final bool background;
  final bool allAccounts;

  @override
  Widget build(BuildContext context) {
    final selectedAccount = account;

    final Color iconColor = selectedAccount?.colorValue == null
        ? context.c.onSurfaceVariant
        : Color(selectedAccount!.colorValue!);
    final icon = allAccounts
        ? LucideIcons.check_check
        : selectedAccount == null
        ? LucideIcons.building_2
        : AppIcon.fromCode(selectedAccount.iconCode).icon;

    final String text = allAccounts
        ? 'All accounts'
        : selectedAccount?.name ?? 'Select Account';
    final Color textColor = context.c.onSurface;

    return Pressable(
      onTap: onTap,
      child: Container(
        padding: background
            ? EdgeInsets.symmetric(horizontal: 12, vertical: 8)
            : .zero,
        decoration: BoxDecoration(
          color: background ? context.c.surfaceContainer : null,
          borderRadius: background ? .circular(12) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Icon(icon, color: iconColor, size: 20),
            Flexible(
              child: Text(
                text,
                style: context.t.titleMedium?.copyWith(color: textColor),
              ),
            ),
            // Icon(LucideIcons.chevron_up, color: textColor, size: 20),
          ],
        ),
      ),
    );
  }
}
