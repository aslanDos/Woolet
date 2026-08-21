import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/extensions/theme_x.dart';
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

  factory PeriodSelection.initial() {
    final now = DateTime.now();
    return PeriodSelection(type: PeriodType.month, anchor: _dateOnly(now));
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
      PeriodType.day => localizations.formatMediumDate(anchor),
      PeriodType.week => _weekLabel(localizations),
      PeriodType.month => localizations.formatMonthYear(anchor),
      PeriodType.year => anchor.year.toString(),
      PeriodType.lastWeek => PeriodType.lastWeek.label,
      PeriodType.lastMonth => PeriodType.lastMonth.label,
      PeriodType.allTime => PeriodType.allTime.label,
      PeriodType.custom => _customLabel(localizations),
    };
  }

  String _weekLabel(MaterialLocalizations localizations) {
    final firstDay = anchor.subtract(Duration(days: anchor.weekday - 1));
    final lastDay = firstDay.add(const Duration(days: 6));
    return '${localizations.formatShortMonthDay(firstDay)} – '
        '${localizations.formatShortMonthDay(lastDay)}';
  }

  String _customLabel(MaterialLocalizations localizations) {
    if (start == null || end == null) return PeriodType.custom.label;
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
      padding: EdgeInsetsGeometry.fromLTRB(16, 32, 16, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Period', style: context.t.headlineMedium),
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
                    type.label,
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
                  label: 'From',
                  value: _customStart,
                  onTap: () => _pickDate(isStart: true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DateButton(
                  label: 'To',
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
              child: const Text('Apply'),
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
