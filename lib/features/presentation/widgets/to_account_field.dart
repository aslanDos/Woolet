import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/extensions/theme_x.dart';

class ToAccountField extends StatelessWidget {
  final String accountName;
  final VoidCallback? onTap;

  const ToAccountField({super.key, this.accountName = 'Freedom', this.onTap});

  @override
  Widget build(BuildContext context) {
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
                    const Icon(LucideIcons.building_2, size: 20),
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
