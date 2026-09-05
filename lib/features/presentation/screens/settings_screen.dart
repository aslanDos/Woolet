import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:woolet/core/database/app_database.dart';
import 'package:woolet/core/di/service_locator.dart';
import 'package:woolet/core/extensions/pop_up_x.dart';
import 'package:woolet/core/extensions/localization_x.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/models/currency_info.dart';
import 'package:woolet/core/settings/currency_controller.dart';
import 'package:woolet/core/settings/app_settings_controller.dart';
import 'package:woolet/core/settings/locale_controller.dart';
import 'package:woolet/core/theme/theme_controller.dart';
import 'package:woolet/core/usecases/usecase.dart';
import 'package:woolet/core/widgets/alert_dialog.dart';
import 'package:woolet/features/domain/usecases/account/account_usecases.dart';
import 'package:woolet/features/domain/usecases/category/category_usecases.dart';
import 'package:woolet/features/presentation/sheets/about_sheet.dart';
import 'package:woolet/features/presentation/sheets/accounts_sheet.dart';
import 'package:woolet/features/presentation/sheets/categories_sheet.dart';
import 'package:woolet/features/presentation/sheets/currency_picker_sheet.dart';
import 'package:woolet/features/presentation/sheets/language_picker_sheet.dart';
import 'package:woolet/features/presentation/sheets/periods_sheet.dart';
import 'package:woolet/features/presentation/sheets/settings_choice_sheet.dart';
import 'package:woolet/features/presentation/sheets/theme_picker_sheet.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeController get _themeController => sl<ThemeController>();
  CurrencyController get _currencyController => sl<CurrencyController>();
  LocaleController get _localeController => sl<LocaleController>();
  AppSettingsController get _settingsController => sl<AppSettingsController>();

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

  Future<void> _openAccounts() => context.openBottomSheet(
    child: const AccountsSheet(allowAllAccounts: false),
  );

  Future<T?> _choose<T>(
    String title,
    T selected,
    List<SettingsChoice<T>> choices,
  ) => context.openBottomSheet<T>(
    child: SettingsChoiceSheet(
      title: title,
      selected: selected,
      choices: choices,
    ),
  );

  Future<void> _selectWeekStart() async {
    final selected = await _choose(
      context.l10n.weekStartsOn,
      _settingsController.value.weekStart,
      [
        SettingsChoice(value: WeekStart.monday, label: context.l10n.monday),
        SettingsChoice(value: WeekStart.sunday, label: context.l10n.sunday),
      ],
    );
    if (selected != null) await _settingsController.setWeekStart(selected);
  }

  Future<void> _selectStartTab() async {
    final selected = await _choose(
      context.l10n.startScreen,
      _settingsController.value.startTab,
      [
        SettingsChoice(
          value: StartTab.transactions,
          label: context.l10n.transactions,
        ),
        SettingsChoice(value: StartTab.budgets, label: context.l10n.budgets),
      ],
    );
    if (selected != null) await _settingsController.setStartTab(selected);
  }

  Future<void> _selectDefaultPeriod({required bool analytics}) async {
    final settings = _settingsController.value;
    final selected = await _choose(
      analytics
          ? context.l10n.defaultAnalyticsPeriod
          : context.l10n.defaultHomePeriod,
      analytics ? settings.analyticsPeriod : settings.homePeriod,
      [
        for (final type in const [
          PeriodType.day,
          PeriodType.week,
          PeriodType.month,
          PeriodType.year,
        ])
          SettingsChoice(value: type, label: type.localizedLabel(context)),
      ],
    );
    if (selected == null) return;
    if (analytics) {
      await _settingsController.setAnalyticsPeriod(selected);
    } else {
      await _settingsController.setHomePeriod(selected);
    }
  }

  Future<void> _toggleBiometrics() async {
    final enabled = _settingsController.value.biometricLock;
    if (!enabled) {
      final auth = LocalAuthentication();
      final available =
          await auth.isDeviceSupported() && await auth.canCheckBiometrics;
      if (!available || !mounted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.biometricUnavailable)),
          );
        }
        return;
      }
      bool authenticated;
      try {
        authenticated = await auth.authenticate(
          localizedReason: context.l10n.biometricReason,
          options: const AuthenticationOptions(biometricOnly: true),
        );
      } catch (_) {
        authenticated = false;
      }
      if (!authenticated) return;
    }
    await _settingsController.setBiometricLock(!enabled);
  }

  Future<void> _clearData() async {
    final confirmed = await AppAlertDialog.show(
      context,
      title: context.l10n.clearDataQuestion,
      message: context.l10n.clearDataMessage,
      confirmLabel: context.l10n.clear,
      cancelLabel: context.l10n.cancel,
      isDestructive: true,
    );
    if (!confirmed) return;
    await sl<AppDatabase>().clearAllData();
    await sl<SeedDefaultAccounts>()(const NoParams());
    await sl<SeedDefaultCategories>()(const NoParams());
    if (mounted) context.go('/main');
  }

  Future<void> _openAbout() =>
      context.openBottomSheet(child: const AboutSheet());

  Future<void> _selectLanguage() async {
    final selected = await context.openBottomSheet<Locale>(
      child: LanguagePickerSheet(selected: _localeController.value),
    );
    if (selected == null || !mounted) return;
    await _localeController.setLocale(selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(LucideIcons.chevron_left),
        ),
        title: Text(context.l10n.settings, style: context.t.headlineMedium),
        // centerTitle: false,
      ),
      body: ValueListenableBuilder<ThemeMode>(
        valueListenable: _themeController,
        builder: (context, themeMode, _) =>
            ValueListenableBuilder<CurrencyInfo>(
              valueListenable: _currencyController,
              builder: (context, currency, _) =>
                  ValueListenableBuilder<AppSettings>(
                    valueListenable: _settingsController,
                    builder: (context, settings, _) => SafeArea(
                      top: false,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _SettingsGroup(
                            title: context.l10n.general,
                            items: [
                              _SettingsItem(
                                icon: LucideIcons.sun_moon,
                                title: context.l10n.theme,
                                value: themeMode.localizedLabel(context),
                                onTap: _selectTheme,
                              ),
                              _SettingsItem(
                                icon: LucideIcons.badge_dollar_sign,
                                title: context.l10n.currency,
                                value: '${currency.name} (${currency.symbol})',
                                onTap: _selectCurrency,
                              ),
                              _SettingsItem(
                                icon: LucideIcons.languages,
                                title: context.l10n.language,
                                value:
                                    (_localeController.value ??
                                            Localizations.localeOf(context))
                                        .localizedName(context.l10n),
                                onTap: _selectLanguage,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _SettingsGroup(
                            title: context.l10n.management,
                            items: [
                              _SettingsItem(
                                icon: LucideIcons.wallet_cards,
                                title: context.l10n.accounts,
                                onTap: _openAccounts,
                              ),
                              _SettingsItem(
                                icon: LucideIcons.tags,
                                title: context.l10n.categories,
                                onTap: _openCategories,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _SettingsGroup(
                            title: context.l10n.preferences,
                            items: [
                              _SettingsItem(
                                icon: LucideIcons.calendar_days,
                                title: context.l10n.weekStartsOn,
                                value: settings.weekStart == WeekStart.monday
                                    ? context.l10n.monday
                                    : context.l10n.sunday,
                                onTap: _selectWeekStart,
                              ),
                              _SettingsItem(
                                icon: LucideIcons.panel_top,
                                title: context.l10n.startScreen,
                                value:
                                    settings.startTab == StartTab.transactions
                                    ? context.l10n.transactions
                                    : context.l10n.budgets,
                                onTap: _selectStartTab,
                              ),
                              _SettingsItem(
                                icon: LucideIcons.calendar_1,
                                title: context.l10n.defaultHomePeriod,
                                value: settings.homePeriod.localizedLabel(
                                  context,
                                ),
                                onTap: () =>
                                    _selectDefaultPeriod(analytics: false),
                              ),
                              _SettingsItem(
                                icon: LucideIcons.chart_pie,
                                title: context.l10n.defaultAnalyticsPeriod,
                                value: settings.analyticsPeriod.localizedLabel(
                                  context,
                                ),
                                onTap: () =>
                                    _selectDefaultPeriod(analytics: true),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _SettingsGroup(
                            title: context.l10n.security,
                            items: [
                              _SettingsItem(
                                icon: LucideIcons.scan_face,
                                title: context.l10n.biometricLock,
                                value: settings.biometricLock
                                    ? context.l10n.enabled
                                    : context.l10n.disabled,
                                onTap: _toggleBiometrics,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _SettingsGroup(
                            title: context.l10n.data,
                            items: [
                              _SettingsItem(
                                icon: LucideIcons.trash_2,
                                title: context.l10n.clearAllData,
                                destructive: true,
                                onTap: _clearData,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _SettingsGroup(
                            title: context.l10n.aboutApp,
                            items: [
                              _SettingsItem(
                                icon: LucideIcons.info,
                                title: context.l10n.aboutApp,
                                onTap: _openAbout,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback? onTap;
  final bool destructive;

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
            Expanded(
              child: Text(
                title,
                style: context.t.titleMedium?.copyWith(
                  color: destructive ? context.c.error : null,
                ),
              ),
            ),
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
