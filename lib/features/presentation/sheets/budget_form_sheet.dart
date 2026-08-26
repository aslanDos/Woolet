import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/constants/app_enums.dart';
import 'package:woolet/core/constants/app_icons.dart';
import 'package:woolet/core/di/service_locator.dart';
import 'package:woolet/core/extensions/budget_period_x.dart';
import 'package:woolet/core/extensions/pop_up_x.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/theme/app_colors.dart';
import 'package:woolet/core/utils/amount_formatter.dart';
import 'package:woolet/core/utils/amount_utils.dart';
import 'package:woolet/core/widgets/error_toast.dart';
import 'package:woolet/features/domain/entities/account_entity.dart';
import 'package:woolet/features/domain/entities/budget_entity.dart';
import 'package:woolet/features/domain/entities/category_entity.dart';
import 'package:woolet/features/domain/repositories/category_repository.dart';
import 'package:woolet/features/presentation/sheets/accounts_sheet.dart';
import 'package:woolet/features/presentation/sheets/categories_sheet.dart';
import 'package:woolet/features/presentation/widgets/account_selector.dart';
import 'package:woolet/features/presentation/widgets/button.dart';
import 'package:woolet/features/presentation/widgets/custom_bottom_sheet.dart';
import 'package:woolet/features/presentation/widgets/form_tile.dart';
import 'package:woolet/features/presentation/widgets/icon_color_selector.dart';

@immutable
class BudgetFormData {
  const BudgetFormData({
    required this.name,
    required this.amountMinor,
    required this.categories,
    required this.period,
    required this.startDay,
    required this.iconCode,
    required this.colorValue,
    this.account,
  });

  final String name;
  final int amountMinor;
  final List<CategoryEntity> categories;
  final BudgetPeriod period;
  final int startDay;
  final String iconCode;
  final int colorValue;
  final AccountEntity? account;
}

class BudgetFormSheet extends StatefulWidget {
  const BudgetFormSheet({super.key, this.initialValue, this.onSaved});

  final BudgetFormData? initialValue;
  final ValueChanged<BudgetFormData>? onSaved;

  @override
  State<BudgetFormSheet> createState() => _BudgetFormSheetState();
}

class _BudgetFormSheetState extends State<BudgetFormSheet>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _limitController;
  late final TextEditingController _nameController;
  late BudgetPeriod _period;
  late int _startDay;
  AccountEntity? _account;
  List<CategoryEntity> _availableCategories = const [];
  List<CategoryEntity> _selectedCategories = const [];
  late AppIcon _icon;
  late Color _color;
  late final ErrorToastController _errorToast;

  @override
  void initState() {
    super.initState();
    final value = widget.initialValue;
    _nameController = TextEditingController(text: value?.name ?? '');
    _limitController = TextEditingController(
      text: AmountUtils.formatMinor(
        value?.amountMinor ?? 0,
        emptyWhenZero: true,
      ),
    );
    _period = value?.period ?? BudgetPeriod.monthly;
    _startDay = value?.startDay ?? DateTime.now().day;
    _account = value?.account;
    _selectedCategories = List.of(value?.categories ?? const []);
    _icon = AppIcon.fromCode(value?.iconCode ?? AppIcon.piggyBank.code);
    _color = value == null ? AppColors.blue0 : Color(value.colorValue);
    _errorToast = ErrorToastController(vsync: this);
    _loadCategories(selectAll: value == null);
  }

  @override
  void dispose() {
    _errorToast.dispose();
    _nameController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  Future<void> _selectAccount() async {
    await context.openBottomSheet(
      child: AccountsSheet(
        allowAllAccounts: true,
        onAccountTap: (account) {
          setState(() {
            _account = account;
            _errorToast.hide();
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _loadCategories({required bool selectAll}) async {
    final result = await sl<CategoryRepository>().getCategories();
    if (!mounted) return;
    result.fold((_) {}, (categories) {
      final expenses = categories
          .where(
            (category) =>
                category.type == CategoryType.expense && category.visible,
          )
          .toList(growable: false);
      setState(() {
        _availableCategories = expenses;
        if (selectAll) _selectedCategories = expenses;
      });
    });
  }

  Future<void> _selectCategories() async {
    final selected = await context.openBottomSheet<List<CategoryEntity>>(
      child: CategoriesSheet(
        categoryType: CategoryType.expense,
        multiSelect: true,
        showAllCategoriesButton: true,
        selectedCategoryUuids: _selectedCategories
            .map((category) => category.uuid)
            .toSet(),
      ),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _selectedCategories = selected;
      _errorToast.hide();
    });
    await _loadCategories(selectAll: false);
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      // height: MediaQuery.sizeOf(context).height * 0.9,
      title: AccountSelector(
        account: _account,
        allAccounts: _account == null,
        onTap: _selectAccount,
      ),
      leading: IconButton.filled(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(LucideIcons.x),
      ),
      footer: ColoredBox(
        color: context.c.surface,
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Button(label: 'Save', onPressed: _submit),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconColorSelector(
              icon: _icon,
              color: _color,
              compact: true,
              onIconChanged: (icon) => setState(() => _icon = icon),
              onColorChanged: (color) => setState(() => _color = color),
            ),
            const SizedBox(height: 4),
            FormTile(
              icon: LucideIcons.badge_dollar_sign,
              label: 'Limit',
              field: TextField(
                controller: _limitController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: const [AmountFormatter()],
                style: context.t.bodyMedium,
                textAlign: TextAlign.end,
                decoration: const InputDecoration(
                  hintText: '0',
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
            const SizedBox(height: 4),
            FormTile(
              icon: LucideIcons.text_cursor_input,
              label: 'Name',
              field: TextField(
                controller: _nameController,
                maxLength: BudgetEntity.maxNameLength,
                style: context.t.bodyMedium,
                textAlign: TextAlign.end,
                decoration: const InputDecoration(
                  hintText: 'Budget name',
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
            const SizedBox(height: 4),
            _BudgetCategorySelector(
              selected: _selectedCategories,
              allSelected:
                  _availableCategories.isNotEmpty &&
                  _selectedCategories.length == _availableCategories.length,
              onTap: _selectCategories,
            ),
            const SizedBox(height: 4),
            _BudgetPeriodSelector(
              selected: _period,
              startDay: _startDay,
              onChanged: (period) => setState(() {
                _period = period;
                _errorToast.hide();
              }),
              onStartDayChanged: (day) => setState(() => _startDay = day),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    final amount = AmountUtils.parse(_limitController.text);
    final name = _nameController.text.trim();
    String? error;
    if (name.isEmpty) {
      error = 'Enter a budget name';
    } else if (amount == null || amount <= 0) {
      error = 'Enter a budget limit greater than zero';
    }
    if (error == null && _selectedCategories.isEmpty) {
      error = 'Select at least one expense category';
    }
    if (error != null) {
      _errorToast.show(context, error);
      return;
    }

    final value = BudgetFormData(
      name: name,
      amountMinor: AmountUtils.toMinor(amount!),
      categories: List.unmodifiable(_selectedCategories),
      period: _period,
      startDay: _startDay,
      iconCode: _icon.code,
      colorValue: _color.toARGB32(),
      account: _account,
    );
    widget.onSaved?.call(value);
    Navigator.pop(context, value);
  }
}

class _BudgetCategorySelector extends StatelessWidget {
  const _BudgetCategorySelector({
    required this.selected,
    required this.allSelected,
    required this.onTap,
  });

  final List<CategoryEntity> selected;
  final bool allSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = allSelected ? 'All Categories' : '${selected.length}';
    return FormTile(
      icon: LucideIcons.tags,
      label: 'Categories',
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!allSelected) ...[
            Icon(
              LucideIcons.square_dashed,
              size: 16,
              color: context.c.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: context.t.bodyMedium?.copyWith(
              color: context.c.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            LucideIcons.chevron_right,
            size: 16,
            color: context.c.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _BudgetPeriodSelector extends StatelessWidget {
  const _BudgetPeriodSelector({
    required this.selected,
    required this.startDay,
    required this.onChanged,
    required this.onStartDayChanged,
  });

  final BudgetPeriod selected;
  final int startDay;
  final ValueChanged<BudgetPeriod> onChanged;
  final ValueChanged<int> onStartDayChanged;

  @override
  Widget build(BuildContext context) {
    final menuItems = BudgetPeriod.values
        .map(
          (period) => AdaptivePopupMenuItem<BudgetPeriod>(
            label: period.label,
            value: period,
          ),
        )
        .toList(growable: false);
    final dayItems = List.generate(
      31,
      (index) =>
          AdaptivePopupMenuItem<int>(label: '${index + 1}', value: index + 1),
    );
    final showStartDay = selected == BudgetPeriod.monthly;

    return Material(
      color: context.c.surfaceContainer,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FormTile(
              icon: LucideIcons.calendar_range,
              label: 'Period',
              background: false,
              trailing: _AdaptiveMenuTrigger<BudgetPeriod>(
                items: menuItems,
                onSelected: onChanged,
                label: selected.label,
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: showStartDay
                  ? Column(
                      key: const ValueKey('start-day'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Divider(color: context.c.outlineVariant),
                        ),
                        FormTile(
                          icon: LucideIcons.calendar_clock,
                          label: 'Starts on',
                          background: false,
                          trailing: _AdaptiveMenuTrigger<int>(
                            items: dayItems,
                            onSelected: onStartDayChanged,
                            label: '$startDay',
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(key: ValueKey('no-start-day')),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdaptiveMenuTrigger<T> extends StatelessWidget {
  const _AdaptiveMenuTrigger({
    required this.items,
    required this.onSelected,
    required this.label,
  });

  final List<AdaptivePopupMenuEntry> items;
  final ValueChanged<T> onSelected;
  final String label;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(platformBrightness: Theme.of(context).brightness),
      child: AdaptivePopupMenuButton.widget<T>(
        items: items,
        onSelected: (_, item) {
          final value = item.value;
          if (value != null) onSelected(value);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: context.t.bodyMedium?.copyWith(
                  color: context.c.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                LucideIcons.chevron_down,
                size: 16,
                color: context.c.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
