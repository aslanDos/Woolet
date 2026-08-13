import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/constants/app_icons.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/widgets/pressable.dart';
import 'package:woolet/features/domain/entities/account_entity.dart';

class AccountSelector extends StatelessWidget {
  const AccountSelector({super.key, required this.account, this.onTap});

  final AccountEntity? account;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final selectedAccount = account;

    final Color iconColor = selectedAccount?.colorValue == null
        ? context.c.onSurfaceVariant
        : Color(selectedAccount!.colorValue!);
    final icon = selectedAccount == null
        ? LucideIcons.building_2
        : AppIcon.fromCode(selectedAccount.iconCode).icon;

    final String text = selectedAccount?.name ?? 'Select Account';
    final Color textColor = selectedAccount == null
        ? context.c.onSurfaceVariant
        : context.c.onSurface;

    return Pressable(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Icon(icon, color: iconColor, size: 20),
          Flexible(
            child: Text(text, style: TextStyle(color: textColor)),
          ),
          Icon(LucideIcons.chevron_up, color: textColor, size: 20),
        ],
      ),
    );
  }
}
