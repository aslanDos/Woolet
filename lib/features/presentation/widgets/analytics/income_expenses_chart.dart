import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/utils/amount_utils.dart';
import 'package:woolet/features/domain/entities/analytics_entity.dart';
import 'package:woolet/features/presentation/sheets/periods_sheet.dart';

class IncomeExpensesChart extends StatefulWidget {
  const IncomeExpensesChart({
    super.key,
    required this.income,
    required this.expenses,
    required this.period,
  });

  final List<AnalyticsPoint> income;
  final List<AnalyticsPoint> expenses;
  final PeriodSelection period;

  @override
  State<IncomeExpensesChart> createState() => _IncomeExpensesChartState();
}

class _IncomeExpensesChartState extends State<IncomeExpensesChart> {
  int? _hoveredGroup;

  @override
  Widget build(BuildContext context) {
    final groups = _groups(widget.income, widget.expenses);
    final highest = groups.fold<int>(
      0,
      (value, group) => math.max(value, math.max(group.income, group.expense)),
    );
    return Container(
      height: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.c.surfaceContainer,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Income and expenses',
                  style: context.t.titleMedium,
                ),
              ),
              _Legend(color: context.appColors.income, label: 'Income'),
              const SizedBox(width: 12),
              _Legend(color: context.appColors.expense, label: 'Expenses'),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: highest == 0
                ? const _EmptyChart()
                : BarChart(
                    _chartData(context, groups, highest),
                    duration: Duration.zero,
                  ),
          ),
        ],
      ),
    );
  }

  BarChartData _chartData(
    BuildContext context,
    List<_ChartGroup> groups,
    int highest,
  ) {
    final maxY = _axisMaximum(highest).toDouble();
    final interval = maxY / 4;
    final width = math.min(10.0, math.max(5.0, 72 / groups.length));
    final gridColor = context.c.outlineVariant.withValues(alpha: .6);
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY,
      groupsSpace: 8,
      barTouchData: BarTouchData(
        enabled: true,
        handleBuiltInTouches: false,
        touchExtraThreshold: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 240,
        ),
        touchCallback: (event, response) {
          final groupIndex = event.isInterestedForInteractions
              ? response?.spot?.touchedBarGroupIndex
              : null;
          if (groupIndex == _hoveredGroup) return;
          setState(() => _hoveredGroup = groupIndex);
        },
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => context.c.primary,
          tooltipPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          tooltipMargin: 12,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final chartGroup = groups[groupIndex];
            if (chartGroup.income == 0 && chartGroup.expense == 0) {
              return null;
            }
            return _tooltipItem(context, chartGroup);
          },
        ),
      ),
      borderData: FlBorderData(show: false),
      extraLinesData: ExtraLinesData(
        horizontalLines: [
          HorizontalLine(y: maxY, color: gridColor, strokeWidth: 1),
        ],
      ),
      gridData: FlGridData(
        drawVerticalLine: false,
        horizontalInterval: interval,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: gridColor, strokeWidth: 1),
      ),
      titlesData: _titlesData(context, groups, interval),
      barGroups: [
        for (var index = 0; index < groups.length; index++)
          BarChartGroupData(
            x: index,
            barsSpace: 3,
            showingTooltipIndicators: _hoveredGroup == index ? [0] : [],
            barRods: [
              _bar(groups[index].income, width, context.appColors.income),
              _bar(groups[index].expense, width, context.appColors.expense),
            ],
          ),
      ],
    );
  }

  FlTitlesData _titlesData(
    BuildContext context,
    List<_ChartGroup> groups,
    double interval,
  ) => FlTitlesData(
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 36,
        interval: interval,
        getTitlesWidget: (value, meta) => value == 0
            ? const SizedBox.shrink()
            : SideTitleWidget(
                meta: meta,
                child: Text(
                  _compactNumber(value.round()),
                  // textAlign: .end,
                  style: context.t.labelSmall?.copyWith(
                    color: context.c.outline,
                    fontSize: 10,
                  ),
                ),
              ),
      ),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) {
          final index = value.toInt();
          if (index < 0 || index >= groups.length) {
            return const SizedBox.shrink();
          }
          return SideTitleWidget(
            meta: meta,
            space: 8,
            child: Text(
              groups[index].label,
              style: context.t.labelSmall?.copyWith(
                color: context.c.outline,
                fontSize: 10,
              ),
            ),
          );
        },
      ),
    ),
  );

  BarChartRodData _bar(int value, double width, Color color) => BarChartRodData(
    toY: value.toDouble(),
    width: width,
    color: color,
    borderRadius: BorderRadius.circular(8),
  );

  BarTooltipItem _tooltipItem(BuildContext context, _ChartGroup group) {
    return BarTooltipItem(
      group.label,
      context.t.labelMedium!.copyWith(
        color: context.c.onInverseSurface,
        height: 1.4,
      ),
      textAlign: .start,
      children: [
        if (group.income > 0)
          TextSpan(
            text: '\n+ ${AmountUtils.formatMinor(group.income)}',
            style: TextStyle(color: context.appColors.income),
          ),
        if (group.expense > 0)
          TextSpan(
            text: '\n− ${AmountUtils.formatMinor(group.expense)}',
            style: TextStyle(color: context.appColors.expense),
          ),
      ],
    );
  }

  int _axisMaximum(int highest) {
    final step = AmountUtils.toMinor(100);
    return ((highest + step - 1) ~/ step) * step;
  }

  List<_ChartGroup> _groups(
    List<AnalyticsPoint> income,
    List<AnalyticsPoint> expenses,
  ) {
    if (widget.period.type == PeriodType.year) {
      return _yearGroups(income, expenses, widget.period.anchor.year);
    }

    final all = [...income, ...expenses];
    if (all.isEmpty) return const [_ChartGroup('', 0, 0)];
    final first = all
        .map((point) => point.date)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    final last = all
        .map((point) => point.date)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    final monthly = last.difference(first).inDays > 62;
    final incomeByDate = _amountsByDate(income, monthly);
    final expensesByDate = _amountsByDate(expenses, monthly);
    final dates = {...incomeByDate.keys, ...expensesByDate.keys}.toList()
      ..sort();
    final step = math.max(1, (dates.length / 10).ceil());
    return [
      for (var start = 0; start < dates.length; start += step)
        _ChartGroup(
          _dateLabel(dates[start], monthly),
          dates
              .skip(start)
              .take(step)
              .fold(0, (sum, date) => sum + (incomeByDate[date] ?? 0)),
          dates
              .skip(start)
              .take(step)
              .fold(0, (sum, date) => sum + (expensesByDate[date] ?? 0)),
        ),
    ];
  }

  List<_ChartGroup> _yearGroups(
    List<AnalyticsPoint> income,
    List<AnalyticsPoint> expenses,
    int year,
  ) {
    final incomeByMonth = _amountsByMonth(income, year);
    final expensesByMonth = _amountsByMonth(expenses, year);

    return [
      for (var month = 1; month <= 12; month++)
        _ChartGroup(
          _monthLabel(month),
          incomeByMonth[month] ?? 0,
          expensesByMonth[month] ?? 0,
        ),
    ];
  }

  Map<int, int> _amountsByMonth(List<AnalyticsPoint> points, int year) {
    final amounts = <int, int>{};
    for (final point in points.where((point) => point.date.year == year)) {
      amounts.update(
        point.date.month,
        (value) => value + point.amountMinor,
        ifAbsent: () => point.amountMinor,
      );
    }
    return amounts;
  }

  Map<DateTime, int> _amountsByDate(List<AnalyticsPoint> points, bool monthly) {
    final amounts = <DateTime, int>{};
    for (final point in points) {
      final date = monthly
          ? DateTime(point.date.year, point.date.month)
          : DateTime(point.date.year, point.date.month, point.date.day);
      amounts.update(
        date,
        (value) => value + point.amountMinor,
        ifAbsent: () => point.amountMinor,
      );
    }
    return amounts;
  }

  String _dateLabel(DateTime date, bool monthly) {
    return monthly ? _monthLabel(date.month) : '${date.day}';
  }

  String _monthLabel(int month) => const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][month - 1];

  String _compactNumber(int value) {
    final amount = AmountUtils.fromMinor(value);
    if (amount >= 1000000) {
      final digits = amount % 1000000 == 0 ? 0 : 1;
      return '${(amount / 1000000).toStringAsFixed(digits)}m';
    }
    if (amount >= 1000) return '${(amount / 1000).round()}k';
    return amount.round().toString();
  }
}

class _ChartGroup {
  const _ChartGroup(this.label, this.income, this.expense);
  final String label;
  final int income;
  final int expense;
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
        child: const SizedBox(width: 7, height: 7),
      ),
      const SizedBox(width: 5),
      Text(
        label,
        style: context.t.labelSmall?.copyWith(color: context.c.outline),
      ),
    ],
  );
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart();

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      'No income or expenses',
      style: context.t.bodyMedium?.copyWith(color: context.c.outline),
    ),
  );
}
