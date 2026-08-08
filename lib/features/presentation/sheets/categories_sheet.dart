import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/constants/app_enums.dart';
import 'package:woolet/core/di/service_locator.dart';
import 'package:woolet/core/extensions/category_type_x.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/features/domain/entities/category_entity.dart';
import 'package:woolet/features/presentation/blocs/category/category_bloc.dart';
import 'package:woolet/features/presentation/widgets/category_card.dart';
import 'package:woolet/features/presentation/widgets/custom_bottom_sheet.dart';
import 'package:woolet/features/presentation/widgets/type_toggle.dart';

class CategoriesSheet extends StatelessWidget {
  final VoidCallback? onAddCategory;
  final ValueChanged<CategoryEntity>? onCategoryTap;

  const CategoriesSheet({super.key, this.onAddCategory, this.onCategoryTap});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CategoryBloc>()..add(const CategoryLoadRequested()),
      child: _CategoriesSheetView(
        onAddCategory: onAddCategory,
        onCategoryTap: onCategoryTap,
      ),
    );
  }
}

class _CategoriesSheetView extends StatefulWidget {
  final VoidCallback? onAddCategory;
  final ValueChanged<CategoryEntity>? onCategoryTap;

  const _CategoriesSheetView({
    required this.onAddCategory,
    required this.onCategoryTap,
  });

  @override
  State<_CategoriesSheetView> createState() => _CategoriesSheetViewState();
}

class _CategoriesSheetViewState extends State<_CategoriesSheetView> {
  CategoryType _selectedType = CategoryType.expense;

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      height: MediaQuery.sizeOf(context).height * 0.78,
      actions: [
        IconButton.filled(
          onPressed: widget.onAddCategory,
          tooltip: 'Add category',
          icon: const Icon(LucideIcons.plus),
        ),
      ],
      title: const Text('Categories'),
      child: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          final categories = state.categories
              .where((category) => category.type == _selectedType)
              .toList(growable: false);

          return SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TypeToggle<CategoryType>(
                  items: CategoryType.values
                      .map(
                        (type) => TypeToggleItem(
                          value: type,
                          label: type.label,
                          icon: type.icon,
                          selectedBackgroundColor: type.backgroundColor,
                        ),
                      )
                      .toList(growable: false),
                  selected: _selectedType,
                  onChanged: (type) => setState(() => _selectedType = type),
                ),
                const SizedBox(height: 20),
                if (state.isProcessing)
                  const LinearProgressIndicator(minHeight: 2),
                if (state.status == CategoryStatus.loading &&
                    state.categories.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: CircularProgressIndicator(),
                  )
                else if (state.status == CategoryStatus.failure &&
                    state.categories.isEmpty)
                  _CategoryLoadError(message: state.errorMessage)
                else if (categories.isEmpty)
                  const _EmptyCategories()
                else
                  ...categories.map(
                    (category) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: CategoryCard(
                        category: category,
                        onTap: widget.onCategoryTap == null
                            ? null
                            : () => widget.onCategoryTap!(category),
                      ),
                    ),
                  ),
                if (state.errorMessage != null && state.categories.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      state.errorMessage!,
                      style: context.t.bodySmall?.copyWith(
                        color: context.c.error,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CategoryLoadError extends StatelessWidget {
  final String? message;

  const _CategoryLoadError({this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(LucideIcons.circle_alert, color: context.c.error),
          const SizedBox(height: 8),
          Text(
            message ?? 'Could not load categories',
            textAlign: TextAlign.center,
            style: context.t.bodyMedium?.copyWith(color: context.c.error),
          ),
          const SizedBox(height: 12),
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

class _EmptyCategories extends StatelessWidget {
  const _EmptyCategories();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(LucideIcons.tags, size: 32, color: context.c.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(
            'No categories yet',
            style: context.t.bodyMedium?.copyWith(
              color: context.c.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
