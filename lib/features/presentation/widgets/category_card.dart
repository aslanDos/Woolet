import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/constants/app_icons.dart';
import 'package:woolet/core/extensions/category_type_x.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/features/domain/entities/category_entity.dart';
import 'package:woolet/features/presentation/widgets/base_card.dart';
import 'package:woolet/features/presentation/widgets/icon_preview.dart';

class CategoryCard extends StatelessWidget {
  final CategoryEntity category;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final bool? selected;

  const CategoryCard({
    super.key,
    required this.category,
    this.onTap,
    this.onEdit,
    this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final appIcon = AppIcon.fromCode(category.iconCode);
    final accentColor = category.colorValue == null
        ? category.type.backgroundColor
        : Color(category.colorValue!);

    return BaseCard(
      onTap: onTap,
      semanticLabel: category.name,
      leading: IconPreview.card(icon: appIcon.icon, color: accentColor),
      title: Text(
        category.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.t.titleMedium,
      ),
      trailingSpacing: selected == null ? 0 : 8,
      trailing: selected != null
          ? Icon(selected! ? LucideIcons.check : LucideIcons.plus, size: 18)
          : onEdit != null
          ? IconButton(
              onPressed: onEdit,
              icon: const Icon(LucideIcons.pen, size: 19),
            )
          : null,
    );
  }
}
