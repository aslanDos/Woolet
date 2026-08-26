import 'package:flutter/material.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/widgets/pressable.dart';

class BaseCard extends StatelessWidget {
  const BaseCard({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.semanticLabel,
    this.contentSpacing = 12,
    this.subtitleSpacing = 2,
    this.trailingSpacing = 0,
  });

  final Widget leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final double contentSpacing;
  final double subtitleSpacing;
  final double trailingSpacing;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      child: Pressable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: context.c.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              leading,
              SizedBox(width: contentSpacing),
              Expanded(
                child: subtitle == null
                    ? title
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          title,
                          SizedBox(height: subtitleSpacing),
                          subtitle!,
                        ],
                      ),
              ),
              if (trailing != null) ...[
                SizedBox(width: trailingSpacing),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
