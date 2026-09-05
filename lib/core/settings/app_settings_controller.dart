import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:woolet/features/presentation/sheets/periods_sheet.dart';

enum WeekStart { monday, sunday }

enum StartTab { transactions, budgets }

extension WeekStartX on WeekStart {
  DateTime startOfWeek(DateTime value) {
    final offset = this == WeekStart.monday
        ? value.weekday - DateTime.monday
        : value.weekday % DateTime.daysPerWeek;
    return DateTime(
      value.year,
      value.month,
      value.day,
    ).subtract(Duration(days: offset));
  }
}

@immutable
class AppSettings {
  const AppSettings({
    this.weekStart = WeekStart.monday,
    this.startTab = StartTab.transactions,
    this.homePeriod = PeriodType.day,
    this.analyticsPeriod = PeriodType.week,
    this.biometricLock = false,
  });

  final WeekStart weekStart;
  final StartTab startTab;
  final PeriodType homePeriod;
  final PeriodType analyticsPeriod;
  final bool biometricLock;

  AppSettings copyWith({
    WeekStart? weekStart,
    StartTab? startTab,
    PeriodType? homePeriod,
    PeriodType? analyticsPeriod,
    bool? biometricLock,
  }) => AppSettings(
    weekStart: weekStart ?? this.weekStart,
    startTab: startTab ?? this.startTab,
    homePeriod: homePeriod ?? this.homePeriod,
    analyticsPeriod: analyticsPeriod ?? this.analyticsPeriod,
    biometricLock: biometricLock ?? this.biometricLock,
  );
}

class AppSettingsController extends ValueNotifier<AppSettings> {
  AppSettingsController(this._preferences) : super(_read(_preferences));

  final SharedPreferences _preferences;

  static AppSettings _read(SharedPreferences preferences) => AppSettings(
    weekStart: _enumValue(
      WeekStart.values,
      preferences.getString('week_start'),
      WeekStart.monday,
    ),
    startTab: _enumValue(
      StartTab.values,
      preferences.getString('start_tab'),
      StartTab.transactions,
    ),
    homePeriod: _enumValue(
      PeriodType.values,
      preferences.getString('home_period'),
      PeriodType.day,
    ),
    analyticsPeriod: _enumValue(
      PeriodType.values,
      preferences.getString('analytics_period'),
      PeriodType.week,
    ),
    biometricLock: preferences.getBool('biometric_lock') ?? false,
  );

  static T _enumValue<T extends Enum>(
    List<T> values,
    String? name,
    T fallback,
  ) => values.where((value) => value.name == name).firstOrNull ?? fallback;

  Future<void> setWeekStart(WeekStart value) =>
      _set(this.value.copyWith(weekStart: value), 'week_start', value.name);

  Future<void> setStartTab(StartTab value) =>
      _set(this.value.copyWith(startTab: value), 'start_tab', value.name);

  Future<void> setHomePeriod(PeriodType value) =>
      _set(this.value.copyWith(homePeriod: value), 'home_period', value.name);

  Future<void> setAnalyticsPeriod(PeriodType value) => _set(
    this.value.copyWith(analyticsPeriod: value),
    'analytics_period',
    value.name,
  );

  Future<void> setBiometricLock(bool enabled) =>
      _set(value.copyWith(biometricLock: enabled), 'biometric_lock', enabled);

  Future<void> _set(AppSettings settings, String key, Object value) async {
    this.value = settings;
    if (value is bool) {
      await _preferences.setBool(key, value);
    } else {
      await _preferences.setString(key, value as String);
    }
  }
}
