import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/extensions/localization_x.dart';
import 'package:woolet/core/di/service_locator.dart';
import 'package:woolet/core/settings/app_settings_controller.dart';
import 'package:woolet/core/utils/date_utils.dart';
import 'package:woolet/features/presentation/widgets/custom_bottom_sheet.dart';

enum PeriodType { day, week, month, year, lastWeek, lastMonth, allTime, custom }

extension PeriodTypeX on PeriodType {
  String get label => switch (this) {
    PeriodType.day => 'Day',
    PeriodType.week => 'Week',
    PeriodType.month => 'Month',
    PeriodType.year => 'Year',
    PeriodType.lastWeek => 'Last week',
    PeriodType.lastMonth => 'Last month',
    PeriodType.allTime => 'All the time',
    PeriodType.custom => 'Custom',
  };

  String localizedLabel(BuildContext context) => switch (this) {
    PeriodType.day => context.l10n.periodDay,
    PeriodType.week => context.l10n.periodWeek,
    PeriodType.month => context.l10n.periodMonth,
    PeriodType.year => context.l10n.periodYear,
    PeriodType.lastWeek => context.l10n.periodLastWeek,
    PeriodType.lastMonth => context.l10n.periodLastMonth,
    PeriodType.allTime => context.l10n.periodAllTime,
    PeriodType.custom => context.l10n.periodCustom,
  };

  bool get canNavigate => switch (this) {
    PeriodType.day ||
    PeriodType.week ||
    PeriodType.month ||
    PeriodType.year => true,
    _ => false,
  };
}

@immutable
class PeriodSelection {
  const PeriodSelection({
    required this.type,
    required this.anchor,
    this.start,
    this.end,
  });

  factory PeriodSelection.currentDay() {
    final now = DateTime.now();
    return PeriodSelection(type: PeriodType.day, anchor: _dateOnly(now));
  }

  factory PeriodSelection.currentWeek() {
    final now = DateTime.now();
    return PeriodSelection(type: PeriodType.week, anchor: _dateOnly(now));
  }

  factory PeriodSelection.forType(PeriodType type) {
    final now = DateTime.now();
    return PeriodSelection(type: type, anchor: _dateOnly(now));
  }

  final PeriodType type;
  final DateTime anchor;
  final DateTime? start;
  final DateTime? end;

  bool get canNavigate => type.canNavigate;

  PeriodSelection copyWith({
    PeriodType? type,
    DateTime? anchor,
    DateTime? start,
    DateTime? end,
  }) {
    return PeriodSelection(
      type: type ?? this.type,
      anchor: anchor ?? this.anchor,
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }

  PeriodSelection shifted(int direction) {
    assert(direction == -1 || direction == 1);

    final shiftedAnchor = switch (type) {
      PeriodType.day => anchor.add(Duration(days: direction)),
      PeriodType.week => anchor.add(Duration(days: 7 * direction)),
      PeriodType.month => DateTime(anchor.year, anchor.month + direction),
      PeriodType.year => DateTime(
        anchor.year + direction,
        anchor.month,
        anchor.day,
      ),
      _ => anchor,
    };

    return copyWith(anchor: shiftedAnchor);
  }

  String label(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);

    return switch (type) {
      PeriodType.day => _dayLabel(context, localizations),
      PeriodType.week => _weekLabel(localizations),
      PeriodType.month => localizations.formatMonthYear(anchor),
      PeriodType.year => anchor.year.toString(),
      PeriodType.lastWeek => PeriodType.lastWeek.localizedLabel(context),
      PeriodType.lastMonth => PeriodType.lastMonth.localizedLabel(context),
      PeriodType.allTime => PeriodType.allTime.localizedLabel(context),
      PeriodType.custom => _customLabel(context, localizations),
    };
  }

  String _dayLabel(BuildContext context, MaterialLocalizations localizations) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode != 'kk') {
      return localizations.formatMediumDate(anchor);
    }
    return '${localizations.formatShortMonthDay(anchor)}, '
        '${AppDateUtils.weekdayName(anchor, locale)}';
  }

  String _weekLabel(MaterialLocalizations localizations) {
    final firstDay = sl<AppSettingsController>().value.weekStart.startOfWeek(
      anchor,
    );
    final lastDay = firstDay.add(const Duration(days: 6));
    return '${localizations.formatShortMonthDay(firstDay)} – '
        '${localizations.formatShortMonthDay(lastDay)}';
  }

  String _customLabel(
    BuildContext context,
    MaterialLocalizations localizations,
  ) {
    if (start == null || end == null) {
      return PeriodType.custom.localizedLabel(context);
    }
    return '${localizations.formatShortDate(start!)} – '
        '${localizations.formatShortDate(end!)}';
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}

class PeriodsSheet extends StatefulWidget {
  const PeriodsSheet({super.key, required this.selected});

  final PeriodSelection selected;

  @override
  State<PeriodsSheet> createState() => _PeriodsSheetState();
}

class _PeriodsSheetState extends State<PeriodsSheet> {
  static const _visibleTypes = [
    PeriodType.day,
    PeriodType.week,
    PeriodType.month,
    PeriodType.year,
    PeriodType.lastWeek,
    PeriodType.lastMonth,
    PeriodType.allTime,
    // PeriodType.custom,
  ];

  late PeriodType _selectedType;
  late DateTime _customStart;
  late DateTime _customEnd;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.selected.type;
    final today = DateTime.now();
    _customStart =
        widget.selected.start ?? DateTime(today.year, today.month, 1);
    _customEnd =
        widget.selected.end ?? DateTime(today.year, today.month, today.day);
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      showDragHandle: true,
      padding: EdgeInsetsGeometry.fromLTRB(16, 16, 16, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.selectPeriod, style: context.t.headlineMedium),
          const SizedBox(height: 16),
          ..._visibleTypes.map(_buildOption),
          if (_selectedType == PeriodType.custom) _buildCustomRange(),
        ],
      ),
    );
  }

  Widget _buildOption(PeriodType type) {
    final isSelected = _selectedType == type;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected
            ? context.c.primaryContainer
            : context.c.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _select(type),
          splashFactory: NoSplash.splashFactory,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    type.localizedLabel(context),
                    style: context.t.titleMedium?.copyWith(
                      color: isSelected
                          ? context.c.onPrimaryContainer
                          : context.c.onSurface,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    LucideIcons.check,
                    size: 18,
                    color: context.c.onPrimaryContainer,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomRange() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _DateButton(
                  label: context.l10n.from,
                  value: _customStart,
                  onTap: () => _pickDate(isStart: true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DateButton(
                  label: context.l10n.to,
                  value: _customEnd,
                  onTap: () => _pickDate(isStart: false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(
                context,
                PeriodSelection(
                  type: PeriodType.custom,
                  anchor: widget.selected.anchor,
                  start: _customStart,
                  end: _customEnd,
                ),
              ),
              child: Text(context.l10n.apply),
            ),
          ),
        ],
      ),
    );
  }

  void _select(PeriodType type) {
    if (type == PeriodType.custom) {
      setState(() => _selectedType = type);
      return;
    }

    Navigator.pop(context, widget.selected.copyWith(type: type));
  }

  Future<void> _pickDate({required bool isStart}) async {
    final value = isStart ? _customStart : _customEnd;
    final selected = await showDatePicker(
      context: context,
      initialDate: value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected == null || !mounted) return;

    setState(() {
      if (isStart) {
        _customStart = selected;
        if (_customEnd.isBefore(selected)) _customEnd = selected;
      } else {
        _customEnd = selected;
        if (_customStart.isAfter(selected)) _customStart = selected;
      }
    });
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      child: Column(
        children: [
          Text(label, style: context.t.labelSmall),
          const SizedBox(height: 2),
          Text(MaterialLocalizations.of(context).formatShortDate(value)),
        ],
      ),
    );
  }
}
