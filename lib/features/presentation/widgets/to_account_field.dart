import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/constants/app_icons.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/features/domain/entities/account_entity.dart';
import 'package:woolet/features/presentation/widgets/form_tile.dart';

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

    return Semantics(
      button: onTap != null,
      label: 'To account: $accountName',
      child: FormTile(
        icon: icon,
        iconColor: color,
        label: 'To account',
        onTap: onTap,
        trailing: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.45,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  accountName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.t.bodyMedium?.copyWith(
                    color: context.c.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                LucideIcons.chevron_down,
                size: 18,
                color: context.c.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
