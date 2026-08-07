import 'package:flutter/material.dart';
import 'package:woolet/core/extensions/theme_x.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
    this.foregroundColor,
    this.iconSize = 24,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon),
      padding: .all(12),
      style: IconButton.styleFrom(
        fixedSize: const Size.square(48),
        iconSize: iconSize,
        backgroundColor: backgroundColor ?? context.c.surfaceContainer,
        foregroundColor: foregroundColor ?? context.c.onSurface,
        splashFactory: NoSplash.splashFactory,
      ),
    );
  }
}
