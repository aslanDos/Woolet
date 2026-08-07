import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/extensions/theme_x.dart';

class DateSelector extends StatelessWidget {
  const DateSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
  });

  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;

  Future<void> _selectDate(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: value,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
    );

    if (selectedDate != null && selectedDate != value) {
      onChanged(selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = MaterialLocalizations.of(
      context,
    ).formatShortMonthDay(value);

    return Semantics(
      button: true,
      label: 'Transaction date: $dateLabel',
      child: Material(
        color: context.c.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          splashFactory: NoSplash.splashFactory,
          onTap: () => _selectDate(context),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.calendar_days, size: 16),
                const SizedBox(width: 8),
                Text(dateLabel, style: context.t.titleMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
