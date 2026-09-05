import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/constants/app_enums.dart';
import 'package:woolet/core/di/service_locator.dart';
import 'package:woolet/core/extensions/category_type_x.dart';
import 'package:woolet/core/extensions/pop_up_x.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/extensions/localization_x.dart';
import 'package:woolet/core/widgets/app_empty_state.dart';
import 'package:woolet/features/domain/entities/category_entity.dart';
import 'package:woolet/features/presentation/blocs/category/category_bloc.dart';
import 'package:woolet/features/presentation/sheets/category_form_sheet.dart';
import 'package:woolet/features/presentation/widgets/category_card.dart';
import 'package:woolet/features/presentation/widgets/button.dart';
import 'package:woolet/features/presentation/widgets/custom_bottom_sheet.dart';
import 'package:woolet/features/presentation/widgets/type_toggle.dart';

class CategoriesSheet extends StatelessWidget {
  final VoidCallback? onAddCategory;
  final ValueChanged<CategoryEntity>? onCategoryTap;
  final bool showAllCategoriesButton;
  final bool multiSelect;
  final CategoryType? categoryType;
  final Set<String> selectedCategoryUuids;
  final bool bottomSafeArea;

  const CategoriesSheet({
    super.key,
    this.onAddCategory,
    this.onCategoryTap,
    this.showAllCategoriesButton = false,
    this.multiSelect = false,
    this.categoryType,
    this.selectedCategoryUuids = const {},
    this.bottomSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CategoryBloc>()..add(const CategoryLoadRequested()),
      child: _CategoriesSheetView(
        onAddCategory: onAddCategory,
        onCategoryTap: onCategoryTap,
        showAllCategoriesButton: showAllCategoriesButton,
        multiSelect: multiSelect,
        categoryType: categoryType,
        selectedCategoryUuids: selectedCategoryUuids,
        bottomSafeArea: bottomSafeArea,
      ),
    );
  }
}

class _CategoriesSheetView extends StatefulWidget {
  final VoidCallback? onAddCategory;
  final ValueChanged<CategoryEntity>? onCategoryTap;
  final bool showAllCategoriesButton;
  final bool multiSelect;
  final CategoryType? categoryType;
  final Set<String> selectedCategoryUuids;
  final bool bottomSafeArea;

  const _CategoriesSheetView({
    required this.onAddCategory,
    required this.onCategoryTap,
    required this.showAllCategoriesButton,
    required this.multiSelect,
    required this.categoryType,
    required this.selectedCategoryUuids,
    required this.bottomSafeArea,
  });

  @override
  State<_CategoriesSheetView> createState() => _CategoriesSheetViewState();
}

class _CategoriesSheetViewState extends State<_CategoriesSheetView> {
  late CategoryType _selectedType;
  late Set<String> _selectedCategoryUuids;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.categoryType ?? CategoryType.expense;
    _selectedCategoryUuids = Set.of(widget.selectedCategoryUuids);
  }

  Future<void> _openCategoryForm({CategoryEntity? category}) async {
    final bloc = context.read<CategoryBloc>();
    await context.openBottomSheet(child: CategoryFormSheet(category: category));
    if (mounted) bloc.add(const CategoryLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      safeAreaBottom: false,
      height: MediaQuery.sizeOf(context).height * 0.677,
      leading: IconButton.filled(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(LucideIcons.x),
      ),
      actions: widget.multiSelect
          ? const []
          : [
              IconButton.filled(
                onPressed: widget.onAddCategory ?? () => _openCategoryForm(),
                icon: const Icon(LucideIcons.plus),
              ),
            ],
      title: Text(context.l10n.categories),
      footer: widget.multiSelect
          ? Button(
              label: context.l10n.save,
              onPressed: _selectedCategoryUuids.isEmpty ? null : _save,
            )
          : null,
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
                if (widget.categoryType == null) ...[
                  TypeToggle<CategoryType>(
                    items: CategoryType.values
                        .map(
                          (type) => TypeToggleItem(
                            value: type,
                            label: type.localizedLabel(context),
                            icon: type.icon,
                            selectedBackgroundColor: type.backgroundColor,
                          ),
                        )
                        .toList(growable: false),
                    selected: _selectedType,
                    onChanged: (type) => setState(() => _selectedType = type),
                  ),
                  const SizedBox(height: 20),
                ],
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
                  _EmptyCategories(onAction: _openCategoryForm)
                else ...[
                  if (widget.showAllCategoriesButton)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _AllCategoriesCard(
                        selected: categories.every(
                          (category) =>
                              _selectedCategoryUuids.contains(category.uuid),
                        ),
                        onTap: () => _selectAll(categories),
                      ),
                    ),
                  ...categories.map(
                    (category) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: CategoryCard(
                        category: category,
                        selected: widget.multiSelect
                            ? _selectedCategoryUuids.contains(category.uuid)
                            : null,
                        onEdit: widget.multiSelect
                            ? null
                            : () => _openCategoryForm(category: category),
                        onTap: widget.multiSelect
                            ? () => _toggleCategory(category)
                            : widget.onCategoryTap == null
                            ? () => _openCategoryForm(category: category)
                            : () => widget.onCategoryTap!(category),
                      ),
                    ),
                  ),
                ],
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

  void _toggleCategory(CategoryEntity category) {
    setState(() {
      if (!_selectedCategoryUuids.add(category.uuid)) {
        _selectedCategoryUuids.remove(category.uuid);
      }
    });
  }

  void _selectAll(List<CategoryEntity> categories) {
    setState(() {
      _selectedCategoryUuids = categories
          .map((category) => category.uuid)
          .toSet();
    });
  }

  void _save() {
    final categories = context
        .read<CategoryBloc>()
        .state
        .categories
        .where(
          (category) =>
              category.type == _selectedType &&
              _selectedCategoryUuids.contains(category.uuid),
        )
        .toList(growable: false);
    Navigator.pop(context, categories);
  }
}

class _AllCategoriesCard extends StatelessWidget {
  const _AllCategoriesCard({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.c.surfaceContainer,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        splashFactory: NoSplash.splashFactory,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(LucideIcons.tags, color: context.c.primary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.l10n.allCategories,
                  style: context.t.titleMedium,
                ),
              ),
              Icon(
                selected ? LucideIcons.check : LucideIcons.plus,
                size: 18,
                color: selected
                    ? context.c.primary
                    : context.c.onSurfaceVariant,
              ),
            ],
          ),
        ),
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
            message ?? context.l10n.couldNotLoadCategories,
            textAlign: TextAlign.center,
            style: context.t.bodyMedium?.copyWith(color: context.c.error),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () =>
                context.read<CategoryBloc>().add(const CategoryLoadRequested()),
            child: Text(context.l10n.tryAgain),
          ),
        ],
      ),
    );
  }
}

class _EmptyCategories extends StatelessWidget {
  const _EmptyCategories({required this.onAction});

  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: LucideIcons.tags,
      title: context.l10n.noCategoriesYet,
      actionLabel: context.l10n.createCategory,
      onAction: onAction,
      compact: true,
    );
  }
}
