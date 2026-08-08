import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/constants/app_enums.dart';
import 'package:woolet/core/constants/app_icons.dart';
import 'package:woolet/core/di/service_locator.dart';
import 'package:woolet/core/extensions/category_type_x.dart';
import 'package:woolet/core/extensions/pop_up_x.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/widgets/pressable.dart';
import 'package:woolet/features/domain/entities/category_entity.dart';
import 'package:woolet/features/presentation/blocs/category/category_bloc.dart';
import 'package:woolet/features/presentation/sheets/categories_sheet.dart';

class CategorySelector extends StatelessWidget {
  final CategoryType type;
  final CategoryEntity? selected;
  final ValueChanged<CategoryEntity> onChanged;

  const CategorySelector({
    super.key,
    required this.type,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CategoryBloc>()..add(const CategoryLoadRequested()),
      child: _CategorySelectorContent(
        type: type,
        selected: selected,
        onChanged: onChanged,
      ),
    );
  }
}

class _CategorySelectorContent extends StatelessWidget {
  final CategoryType type;
  final CategoryEntity? selected;
  final ValueChanged<CategoryEntity> onChanged;

  const _CategorySelectorContent({
    required this.type,
    required this.selected,
    required this.onChanged,
  });

  Future<void> _openSettings(BuildContext context) async {
    final bloc = context.read<CategoryBloc>();
    await context.openBottomSheet(child: const CategoriesSheet());

    if (context.mounted) {
      bloc.add(const CategoryLoadRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Select category', style: context.t.titleLarge),
            IconButton(
              onPressed: () => _openSettings(context),
              tooltip: 'Manage categories',
              icon: const Icon(LucideIcons.settings),
              iconSize: 18,
              style: IconButton.styleFrom(backgroundColor: Colors.transparent),
            ),
          ],
        ),
        const SizedBox(height: 12),
        BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            final categories = state.categories
                .where((category) => category.type == type && category.visible)
                .toList(growable: false);

            if (state.status == CategoryStatus.loading &&
                state.categories.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (state.status == CategoryStatus.failure &&
                state.categories.isEmpty) {
              return _LoadError(message: state.errorMessage);
            }

            if (categories.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'No ${type.label.toLowerCase()} categories',
                    style: context.t.bodyMedium?.copyWith(
                      color: context.c.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            }

            return GridView.builder(
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
                  isSelected: category.uuid == selected?.uuid,
                  onTap: () => onChanged(category),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final CategoryEntity category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appIcon = AppIcon.fromCode(category.iconCode);
    final accentColor = category.colorValue == null
        ? category.type.backgroundColor
        : Color(category.colorValue!);

    return Semantics(
      button: true,
      selected: isSelected,
      label: category.name,
      child: Pressable(
        onTap: onTap,
        child: Column(
          children: [
            SizedBox.square(
              dimension: 64,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: accentColor.withValues(
                    alpha: isSelected ? 0.28 : 0.16,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: accentColor, width: 1.5)
                      : null,
                ),
                child: Icon(appIcon.icon, size: 24, color: accentColor),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              category.name,
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

class _LoadError extends StatelessWidget {
  final String? message;

  const _LoadError({this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            message ?? 'Could not load categories',
            textAlign: TextAlign.center,
            style: context.t.bodySmall?.copyWith(color: context.c.error),
          ),
          TextButton(
            onPressed: () =>
                context.read<CategoryBloc>().add(const CategoryLoadRequested()),
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
