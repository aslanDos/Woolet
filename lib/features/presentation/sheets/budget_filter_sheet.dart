import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/constants/app_enums.dart';
import 'package:woolet/core/extensions/budget_period_x.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/extensions/localization_x.dart';
import 'package:woolet/features/presentation/widgets/button.dart';
import 'package:woolet/features/presentation/widgets/custom_bottom_sheet.dart';

@immutable
class BudgetFilter {
  const BudgetFilter({
    this.periods = const {
      BudgetPeriod.daily,
      BudgetPeriod.weekly,
      BudgetPeriod.monthly,
      BudgetPeriod.yearly,
    },
  });

  final Set<BudgetPeriod> periods;

  bool get isDefault => periods.length == BudgetPeriod.values.length;
}

class BudgetFilterSheet extends StatefulWidget {
  const BudgetFilterSheet({super.key, this.filter = const BudgetFilter()});

  final BudgetFilter filter;

  @override
  State<BudgetFilterSheet> createState() => _BudgetFilterSheetState();
}

class _BudgetFilterSheetState extends State<BudgetFilterSheet> {
  late Set<BudgetPeriod> _selectedPeriods;

  @override
  void initState() {
    super.initState();
    _selectedPeriods = Set.of(widget.filter.periods);
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      title: Text(context.l10n.filterBudgets),
      leading: IconButton.filled(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(LucideIcons.x),
      ),
      footer: Row(
        children: [
          Expanded(
            child: Button(
              label: context.l10n.reset,
              backgroundColor: context.c.surfaceContainerHigh,
              foregroundColor: context.c.onSurface,
              onPressed: _reset,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Button(
              label: context.l10n.save,
              onPressed: _selectedPeriods.isEmpty ? null : _save,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.period, style: context.t.titleLarge),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 3.5,
            children: BudgetPeriod.values.map(_buildPeriodChip).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(BudgetPeriod period) {
    final selected = _selectedPeriods.contains(period);

    return SizedBox(
      width: double.infinity,
      child: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: FilterChip(
          selected: selected,
          showCheckmark: false,
          label: SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  period.icon,
                  size: 14,
                  color: selected
                      ? context.c.onPrimary
                      : context.c.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    period.localizedLabel(context),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          labelStyle: context.t.titleMedium?.copyWith(
            color: selected ? context.c.onPrimary : context.c.onSurfaceVariant,
          ),
          backgroundColor: context.c.surfaceContainer,
          selectedColor: context.c.primary,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (value) {
            setState(() {
              if (value) {
                _selectedPeriods.add(period);
              } else {
                _selectedPeriods.remove(period);
              }
            });
          },
        ),
      ),
    );
  }

  void _reset() {
    setState(() => _selectedPeriods = BudgetPeriod.values.toSet());
  }

  void _save() {
    Navigator.pop(
      context,
      BudgetFilter(periods: Set<BudgetPeriod>.unmodifiable(_selectedPeriods)),
    );
  }
}
