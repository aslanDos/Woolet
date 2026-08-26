import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/constants/app_enums.dart';
import 'package:woolet/core/constants/app_icons.dart';
import 'package:woolet/core/di/service_locator.dart';
import 'package:woolet/core/extensions/category_type_x.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/utils/uuid.dart';
import 'package:woolet/core/widgets/alert_dialog.dart';
import 'package:woolet/core/widgets/error_toast.dart';
import 'package:woolet/features/domain/entities/category_entity.dart';
import 'package:woolet/features/presentation/blocs/category/category_bloc.dart';
import 'package:woolet/features/presentation/widgets/button.dart';
import 'package:woolet/features/presentation/widgets/custom_bottom_sheet.dart';
import 'package:woolet/features/presentation/widgets/form_tile.dart';
import 'package:woolet/features/presentation/widgets/icon_color_selector.dart';
import 'package:woolet/features/presentation/widgets/type_toggle.dart';

class CategoryFormSheet extends StatelessWidget {
  const CategoryFormSheet({super.key, this.category, this.onSaved});

  final CategoryEntity? category;
  final ValueChanged<CategoryEntity>? onSaved;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CategoryBloc>(),
      child: _CategoryFormView(category: category, onSaved: onSaved),
    );
  }
}

class _CategoryFormView extends StatefulWidget {
  const _CategoryFormView({required this.category, required this.onSaved});

  final CategoryEntity? category;
  final ValueChanged<CategoryEntity>? onSaved;

  @override
  State<_CategoryFormView> createState() => _CategoryFormViewState();
}

class _CategoryFormViewState extends State<_CategoryFormView>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _nameController;
  late CategoryType _type;
  late AppIcon _icon;
  late Color _color;
  CategoryEntity? _submittedCategory;
  bool _deleting = false;
  late final ErrorToastController _errorToast;

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    final category = widget.category;
    _nameController = TextEditingController(text: category?.name ?? '');
    _type = category?.type ?? CategoryType.expense;
    _icon = AppIcon.fromCode(category?.iconCode ?? AppIcon.wallet.code);
    _color = category?.colorValue == null
        ? _type.backgroundColor
        : Color(category!.colorValue!);
    _errorToast = ErrorToastController(vsync: this);
  }

  @override
  void dispose() {
    _errorToast.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CategoryBloc, CategoryState>(
      listenWhen: (previous, current) =>
          previous.isProcessing && !current.isProcessing,
      listener: (context, state) {
        if (state.status == CategoryStatus.failure) {
          _errorToast.show(
            context,
            state.errorMessage ?? 'Could not save category',
          );
          return;
        }

        if (_deleting) {
          Navigator.pop(context);
          return;
        }

        final category = _submittedCategory;
        if (category != null) widget.onSaved?.call(category);
        Navigator.pop(context, category);
      },
      builder: (context, state) {
        return CustomBottomSheet(
          title: Text(_isEditing ? 'Edit category' : 'New category'),
          leading: IconButton.filled(
            onPressed: state.isProcessing ? null : () => Navigator.pop(context),
            icon: const Icon(LucideIcons.x),
          ),
          actions: [
            if (_isEditing)
              IconButton.filled(
                onPressed: state.isProcessing ? null : _delete,
                style: IconButton.styleFrom(
                  foregroundColor: context.c.error,
                  backgroundColor: context.c.error.withValues(alpha: 0.14),
                ),
                icon: const Icon(LucideIcons.trash_2),
              ),
          ],
          footer: ColoredBox(
            color: context.c.surface,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Button(
                label: _isEditing ? 'Save changes' : 'Create category',
                isLoading: state.isProcessing,
                onPressed: _submit,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                selected: _type,
                onChanged: (type) => setState(() {
                  _type = type;
                  _errorToast.hide();
                }),
              ),
              const SizedBox(height: 24),
              IconColorSelector(
                icon: _icon,
                color: _color,
                compact: true,
                onIconChanged: (icon) => setState(() => _icon = icon),
                onColorChanged: (color) => setState(() => _color = color),
              ),
              const SizedBox(height: 4),
              FormTile(
                icon: LucideIcons.a_large_small,
                label: 'Name',
                field: TextFormField(
                  controller: _nameController,
                  autofocus: !_isEditing,
                  maxLength: CategoryEntity.maxNameLength,
                  textCapitalization: TextCapitalization.sentences,
                  style: context.t.bodyMedium,
                  textAlign: TextAlign.end,
                  decoration: const InputDecoration(
                    hintText: 'Category name',
                    counterText: '',
                    isCollapsed: true,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                  ),
                  onChanged: (_) => _errorToast.hide(),
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _errorToast.show(context, 'Enter a category name');
      return;
    }

    final original = widget.category;
    final category = CategoryEntity(
      uuid: original?.uuid ?? createUuidV4(),
      name: name,
      sortOrder: original?.sortOrder ?? -1,
      iconCode: _icon.code,
      createdAt: original?.createdAt ?? DateTime.now().toUtc(),
      type: _type,
      colorValue: _color.toARGB32(),
      visible: original?.visible ?? true,
    );

    _deleting = false;
    _submittedCategory = category;
    context.read<CategoryBloc>().add(
      original == null
          ? CategoryCreateRequested(category)
          : CategoryUpdateRequested(category),
    );
  }

  Future<void> _delete() async {
    final category = widget.category;
    if (category == null) return;

    final confirmed = await AppAlertDialog.show(
      context,
      title: 'Delete category?',
      message: 'Are you sure you want to delete “${category.name}”?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;

    _deleting = true;
    context.read<CategoryBloc>().add(CategoryDeleteRequested(category.uuid));
  }
}
