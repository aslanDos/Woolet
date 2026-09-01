import 'package:flutter/material.dart';
import 'package:woolet/core/constants/app_icons.dart';

class IconPreview extends StatelessWidget {
  const IconPreview({super.key, required AppIcon icon, required this.color})
    : _icon = icon,
      size = 72,
      iconSize = 32,
      borderRadius = 20,
      centered = true;

  const IconPreview.card({
    super.key,
    required IconData icon,
    required this.color,
    this.iconSize = 22,
  }) : _icon = icon,
       size = 44,
       borderRadius = 12,
       centered = false;

  const IconPreview.compact({
    super.key,
    required IconData icon,
    required this.color,
  }) : _icon = icon,
       size = 32,
       iconSize = 18,
       borderRadius = 9,
       centered = false;

  final Object _icon;
  final Color color;
  final double size;
  final double iconSize;
  final double borderRadius;
  final bool centered;

  IconData get _iconData => switch (_icon) {
    final AppIcon icon => icon.icon,
    final IconData icon => icon,
    _ => throw StateError('Unsupported icon type'),
  };

  @override
  Widget build(BuildContext context) {
    final preview = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(_iconData, color: color, size: iconSize),
    );

    return centered ? Center(child: preview) : preview;
  }
}
