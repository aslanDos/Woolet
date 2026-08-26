import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/constants/app_enums.dart';
import 'package:woolet/core/constants/app_icons.dart';
import 'package:woolet/core/extensions/category_type_x.dart';
import 'package:woolet/core/extensions/pop_up_x.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/features/domain/entities/category_entity.dart';
import 'package:woolet/features/presentation/sheets/categories_sheet.dart';
import 'package:woolet/features/presentation/widgets/form_tile.dart';

class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.type,
    required this.selected,
    required this.onChanged,
  });

  final CategoryType type;
  final CategoryEntity? selected;
  final ValueChanged<CategoryEntity> onChanged;

  Future<void> _selectCategory(BuildContext context) async {
    final category = await context.openBottomSheet<CategoryEntity>(
      child: CategoriesSheet(
        categoryType: type,
        onCategoryTap: (category) => Navigator.pop(context, category),
      ),
    );
    if (category != null && context.mounted) onChanged(category);
  }

  @override
  Widget build(BuildContext context) {
    final category = selected;
    final icon = category == null
        ? LucideIcons.tags
        : AppIcon.fromCode(category.iconCode).icon;
    final color = category?.colorValue == null
        ? type.backgroundColor
        : Color(category!.colorValue!);
    final value = category?.name ?? 'Select category';

    return Semantics(
      button: true,
      label: 'Category: $value',
      child: FormTile(
        icon: icon,
        iconColor: color,
        label: 'Category',
        onTap: () => _selectCategory(context),
        trailing: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.45,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.t.bodyMedium?.copyWith(
                    color: context.c.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                LucideIcons.chevron_right,
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
