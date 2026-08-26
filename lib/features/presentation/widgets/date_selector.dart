import 'package:flutter/cupertino.dart';
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

    final minimum = firstDate ?? DateTime(2000);
    final maximum = lastDate ?? DateTime(2100);
    final initial = value.isBefore(minimum)
        ? minimum
        : value.isAfter(maximum)
        ? maximum
        : value;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final Future<DateTime?> picker = isIOS
        ? _showCupertinoPicker(context, initial, minimum, maximum)
        : showDatePicker(
            context: context,
            initialDate: initial,
            firstDate: minimum,
            lastDate: maximum,
          );
    final selectedDate = await picker;

    if (selectedDate != null && selectedDate != value) {
      onChanged(selectedDate);
    }
  }

  Future<DateTime?> _showCupertinoPicker(
    BuildContext context,
    DateTime initial,
    DateTime minimum,
    DateTime maximum,
  ) {
    var selected = initial;
    final localizations = MaterialLocalizations.of(context);
    return showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (popupContext) => ColoredBox(
        color: CupertinoTheme.of(popupContext).scaffoldBackgroundColor,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 280,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        onPressed: () => Navigator.pop(popupContext),
                        child: Text(localizations.cancelButtonLabel),
                      ),
                      CupertinoButton(
                        onPressed: () => Navigator.pop(
                          popupContext,
                          DateTime(selected.year, selected.month, selected.day),
                        ),
                        child: Text(
                          localizations.okButtonLabel,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: initial,
                    minimumDate: minimum,
                    maximumDate: maximum,
                    onDateTimeChanged: (value) => selected = value,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
