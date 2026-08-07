import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/constants/transaction_category.dart';
import 'package:woolet/core/extensions/pop_up_x.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/widgets/pressable.dart';
import 'package:woolet/features/presentation/sheets/categories_sheet.dart';

class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.categories,
    required this.selected,
    required this.onChanged,
    required this.foregroundColor,
  });

  final List<TransactionCategory> categories;
  final TransactionCategory? selected;
  final ValueChanged<TransactionCategory> onChanged;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Text('Select category', style: context.t.titleLarge),
            IconButton(
              onPressed: () =>
                  context.openBottomSheet(child: CategoriesSheet()),
              icon: Icon(LucideIcons.settings),
              iconSize: 18,
              style: IconButton.styleFrom(
                backgroundColor: Colors.transparent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          primary: false,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.76,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];

            return _CategoryItem(
              category: category,
              isSelected: category == selected,
              foregroundColor: foregroundColor,
              onTap: () => onChanged(category),
            );
          },
        ),
      ],
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.category,
    required this.isSelected,
    required this.foregroundColor,
    required this.onTap,
  });

  final TransactionCategory category;
  final bool isSelected;
  final Color foregroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: category.label,
      child: Pressable(
        onTap: onTap,
        child: Column(
          children: [
            SizedBox.square(
              dimension: 64,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: foregroundColor.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: foregroundColor, width: 1)
                      : null,
                ),
                child: Icon(
                  category.appIcon.icon,
                  size: 24,
                  color: foregroundColor,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              category.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.t.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
