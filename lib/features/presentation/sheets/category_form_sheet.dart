import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/constants/app_enums.dart';
import 'package:woolet/core/constants/app_icons.dart';
import 'package:woolet/core/di/service_locator.dart';
import 'package:woolet/core/extensions/category_type_x.dart';
import 'package:woolet/core/extensions/pop_up_x.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/theme/app_colors.dart';
import 'package:woolet/core/utils/uuid.dart';
import 'package:woolet/core/widgets/alert_dialog.dart';
import 'package:woolet/features/domain/entities/category_entity.dart';
import 'package:woolet/features/presentation/blocs/category/category_bloc.dart';
import 'package:woolet/features/presentation/sheets/icon_picker_sheet.dart';
import 'package:woolet/features/presentation/widgets/button.dart';
import 'package:woolet/features/presentation/widgets/color_picker.dart';
import 'package:woolet/features/presentation/widgets/custom_bottom_sheet.dart';
import 'package:woolet/features/presentation/widgets/icon_picker.dart';
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

class _CategoryFormViewState extends State<_CategoryFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late CategoryType _type;
  late AppIcon _icon;
  late Color _color;
  CategoryEntity? _submittedCategory;
  bool _deleting = false;

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
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CategoryBloc, CategoryState>(
      listenWhen: (previous, current) =>
          previous.isProcessing && !current.isProcessing,
      listener: (context, state) {
        if (state.status == CategoryStatus.failure) return;

        if (_deleting) {
          Navigator.pop(context);
          return;
        }

        final category = _submittedCategory;
        if (category != null) widget.onSaved?.call(category);
        Navigator.pop(context, category);
      },
      builder: (context, state) {
        final fieldBorder = OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        );

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
          child: Form(
            key: _formKey,
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
                  onChanged: (type) => setState(() => _type = type),
                ),
                const SizedBox(height: 24),
                IconPreview(icon: _icon, color: _color),
                const SizedBox(height: 24),
                Text('Name', style: context.t.titleLarge),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _nameController,
                  autofocus: !_isEditing,
                  maxLength: CategoryEntity.maxNameLength,
                  textCapitalization: TextCapitalization.sentences,
                  style: context.t.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Category name',
                    counterText: '',
                    filled: true,
                    fillColor: context.c.surfaceContainer,
                    contentPadding: const EdgeInsets.all(12),
                    border: fieldBorder,
                    enabledBorder: fieldBorder,
                    focusedBorder: fieldBorder,
                    errorBorder: fieldBorder,
                    focusedErrorBorder: fieldBorder,
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter a category name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                IconPickerField(
                  selected: _icon,
                  color: _color,
                  onSeeAll: _openIconPicker,
                  onChanged: (icon) => setState(() => _icon = icon),
                ),
                const SizedBox(height: 24),
                Text('Color', style: context.t.titleLarge),
                const SizedBox(height: 10),
                ColorPicker(
                  colors: AppColors.pickerColors,
                  selected: _color,
                  onChanged: (color) => setState(() => _color = color),
                ),
                if (state.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage!,
                    style: context.t.bodyMedium?.copyWith(
                      color: context.c.error,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final original = widget.category;
    final category = CategoryEntity(
      uuid: original?.uuid ?? createUuidV4(),
      name: _nameController.text.trim(),
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

  Future<void> _openIconPicker() async {
    final selected = await context.openBottomSheet<AppIcon>(
      showDragHandle: true,
      child: IconPickerSheet(selected: _icon, color: _color),
    );
    if (selected == null || !mounted) return;
    setState(() => _icon = selected);
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
