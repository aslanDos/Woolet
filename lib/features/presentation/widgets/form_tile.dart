import 'package:flutter/material.dart';
import 'package:woolet/core/extensions/theme_x.dart';

class FormTile extends StatelessWidget {
  const FormTile({
    super.key,
    required this.icon,
    required this.label,
    this.trailing,
    this.field,
    this.onTap,
    this.background = true,
    this.iconColor,
  }) : assert(trailing == null || field == null);

  final IconData icon;
  final String label;
  final Widget? trailing;
  final Widget? field;
  final VoidCallback? onTap;
  final bool background;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final content = SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 12),
            if (field == null)
              Expanded(child: Text(label, style: context.t.titleMedium))
            else ...[
              Text(label, style: context.t.titleMedium),
              const SizedBox(width: 12),
              Expanded(child: field!),
            ],
            ?trailing,
          ],
        ),
      ),
    );

    if (!background) {
      return onTap == null
          ? content
          : InkWell(
              splashFactory: NoSplash.splashFactory,
              onTap: onTap,
              child: content,
            );
    }

    return Material(
      color: context.c.surfaceContainer,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? content
          : InkWell(
              splashFactory: NoSplash.splashFactory,
              onTap: onTap,
              child: content,
            ),
    );
  }
}
