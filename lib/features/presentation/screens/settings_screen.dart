import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/di/service_locator.dart';
import 'package:woolet/core/extensions/pop_up_x.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/models/currency_info.dart';
import 'package:woolet/core/settings/currency_controller.dart';
import 'package:woolet/core/theme/theme_controller.dart';
import 'package:woolet/features/presentation/sheets/categories_sheet.dart';
import 'package:woolet/features/presentation/sheets/currency_picker_sheet.dart';
import 'package:woolet/features/presentation/sheets/theme_picker_sheet.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeController get _themeController => sl<ThemeController>();
  CurrencyController get _currencyController => sl<CurrencyController>();

  Future<void> _selectTheme() async {
    final selected = await context.openBottomSheet<ThemeMode>(
      child: ThemePickerSheet(selected: _themeController.value),
    );
    if (selected == null || !mounted) return;
    await _themeController.setThemeMode(selected);
  }

  Future<void> _selectCurrency() async {
    final selected = await context.openBottomSheet<CurrencyInfo>(
      child: CurrencyPickerSheet(
        currencies: _currencyController.currencies,
        selected: _currencyController.value,
      ),
    );
    if (selected == null || !mounted) return;
    await _currencyController.setCurrency(selected);
  }

  Future<void> _openCategories() async {
    await context.openBottomSheet(child: const CategoriesSheet());
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeController,
      builder: (context, themeMode, _) => ValueListenableBuilder<CurrencyInfo>(
        valueListenable: _currencyController,
        builder: (context, currency, _) => SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            children: [
              _SettingsGroup(
                title: 'General',
                items: [
                  _SettingsItem(
                    icon: LucideIcons.sun_moon,
                    title: 'Theme',
                    value: themeMode.label,
                    onTap: _selectTheme,
                  ),
                  _SettingsItem(
                    icon: LucideIcons.badge_dollar_sign,
                    title: 'Currency',
                    value: '${currency.name} (${currency.symbol})',
                    onTap: _selectCurrency,
                  ),
                  _SettingsItem(
                    icon: LucideIcons.tags,
                    title: 'Categories',
                    onTap: _openCategories,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.items});

  final String title;
  final List<_SettingsItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(title, style: context.t.titleLarge),
        ),
        Material(
          color: context.c.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var index = 0; index < items.length; index++) ...[
                items[index],
                if (index < items.length - 1)
                  Padding(
                    padding: const EdgeInsets.only(left: 64),
                    child: Divider(color: context.c.outlineVariant),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.icon,
    required this.title,
    this.value,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashFactory: NoSplash.splashFactory,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.c.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: context.t.titleMedium)),
            if (value != null) ...[
              Text(
                value!,
                style: context.t.bodyMedium?.copyWith(
                  color: context.c.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Icon(
              LucideIcons.chevron_right,
              size: 18,
              color: context.c.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
