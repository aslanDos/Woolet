import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/constants/app_icons.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/features/domain/entities/account_entity.dart';

class ToAccountField extends StatelessWidget {
  final AccountEntity? account;
  final VoidCallback? onTap;

  const ToAccountField({super.key, required this.account, this.onTap});

  @override
  Widget build(BuildContext context) {
    final selectedAccount = account;
    final color = selectedAccount?.colorValue == null
        ? context.c.onSurface
        : Color(selectedAccount!.colorValue!);
    final icon = selectedAccount == null
        ? LucideIcons.building_2
        : AppIcon.fromCode(selectedAccount.iconCode).icon;
    final accountName = selectedAccount?.name ?? 'Select account';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('To account', style: context.t.titleLarge),
        const SizedBox(height: 18),
        Semantics(
          button: true,
          label: 'To account: $accountName',
          child: Material(
            color: context.c.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              splashFactory: NoSplash.splashFactory,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(icon, size: 20, color: color),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(accountName, style: context.t.bodyMedium),
                    ),
                    Icon(
                      LucideIcons.chevron_down,
                      size: 18,
                      color: context.c.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
