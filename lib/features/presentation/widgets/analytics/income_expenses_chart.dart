import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:woolet/core/di/service_locator.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/settings/currency_controller.dart';
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
      (value, group) => math.max(value, group.income + group.expense),
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
                child: Text('Income and expenses', style: context.t.titleLarge),
              ),
              _Legend(color: context.appColors.income, label: 'Income'),
              const SizedBox(width: 12),
              _Legend(color: context.appColors.expense, label: 'Expenses'),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (highest == 0) return const _EmptyChart();

                return SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: BarChart(
                    _chartData(context, groups, highest, constraints.maxWidth),
                    duration: Duration.zero,
                  ),
                );
              },
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
    double chartWidth,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxY = _axisMaximum(highest).toDouble();
    final interval = maxY / 4;
    final availablePlotWidth = math.max(0.0, chartWidth - 36);
    final slotWidth = availablePlotWidth / groups.length;
    final width = widget.period.type == PeriodType.day
        ? math.min(48.0, math.max(10.0, slotWidth * .35))
        : math.min(10.0, math.max(3.0, slotWidth * .45));
    final gridColor = context.c.outlineVariant.withValues(alpha: .6);
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY,
      groupsSpace: 8,
      barTouchData: BarTouchData(
        enabled: true,
        handleBuiltInTouches: false,
        touchExtraThreshold: EdgeInsets.zero,
        touchCallback: (event, response) {
          final groupIndex = event.isInterestedForInteractions
              ? response?.spot?.touchedBarGroupIndex
              : null;
          if (groupIndex == _hoveredGroup) return;
          setState(() => _hoveredGroup = groupIndex);
        },
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) =>
              isDark ? context.c.surfaceContainerHighest : context.c.primary,
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
            showingTooltipIndicators: _hoveredGroup == index ? [0] : [],
            barRods: [
              _stackedBar(
                groups[index],
                width,
                context.appColors.income,
                context.appColors.expense,
              ),
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
                fitInside: SideTitleFitInsideData.fromTitleMeta(
                  meta,
                  distanceFromEdge: 2,
                ),
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
              groups[index].showLabel ? groups[index].label : '',
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

  BarChartRodData _stackedBar(
    _ChartGroup group,
    double width,
    Color incomeColor,
    Color expenseColor,
  ) {
    final income = group.income.toDouble();
    final total = income + group.expense;
    return BarChartRodData(
      toY: total,
      width: width,
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(4),
      rodStackItems: [
        if (group.income > 0) BarChartRodStackItem(0, income, incomeColor),
        if (group.expense > 0)
          BarChartRodStackItem(income, total, expenseColor),
      ],
    );
  }

  BarTooltipItem _tooltipItem(BuildContext context, _ChartGroup group) {
    final currencySymbol = sl<CurrencyController>().value.symbol;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BarTooltipItem(
      group.tooltipLabel ?? group.label,
      context.t.labelMedium!.copyWith(
        color: isDark ? context.c.onSurface : context.c.onPrimary,
        height: 1.4,
      ),
      textAlign: .start,
      children: [
        if (group.income > 0)
          TextSpan(
            text:
                '\n+ ${AmountUtils.formatMinor(group.income)} $currencySymbol',
            style: TextStyle(color: context.appColors.income),
          ),
        if (group.expense > 0)
          TextSpan(
            text:
                '\n− ${AmountUtils.formatMinor(group.expense)} $currencySymbol',
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
    return switch (widget.period.type) {
      PeriodType.day => _dailyGroups(income, expenses, widget.period.anchor, 1),
      PeriodType.week => _dailyGroups(
        income,
        expenses,
        widget.period.anchor.subtract(
          Duration(days: widget.period.anchor.weekday - 1),
        ),
        7,
      ),
      PeriodType.month => _monthGroups(
        income,
        expenses,
        DateTime(widget.period.anchor.year, widget.period.anchor.month),
      ),
      PeriodType.year => _yearGroups(
        income,
        expenses,
        widget.period.anchor.year,
      ),
      PeriodType.lastWeek => _lastWeekGroups(income, expenses),
      PeriodType.lastMonth => _lastMonthGroups(income, expenses),
      PeriodType.allTime ||
      PeriodType.custom => _dataRangeGroups(income, expenses),
    };
  }

  List<_ChartGroup> _lastWeekGroups(
    List<AnalyticsPoint> income,
    List<AnalyticsPoint> expenses,
  ) {
    final today = _dateOnly(DateTime.now());
    final thisWeek = today.subtract(Duration(days: today.weekday - 1));
    return _dailyGroups(
      income,
      expenses,
      thisWeek.subtract(const Duration(days: 7)),
      7,
    );
  }

  List<_ChartGroup> _lastMonthGroups(
    List<AnalyticsPoint> income,
    List<AnalyticsPoint> expenses,
  ) {
    final now = DateTime.now();
    return _monthGroups(income, expenses, DateTime(now.year, now.month - 1));
  }

  List<_ChartGroup> _monthGroups(
    List<AnalyticsPoint> income,
    List<AnalyticsPoint> expenses,
    DateTime month,
  ) {
    final days = DateTime(month.year, month.month + 1, 0).day;
    return _dailyGroups(income, expenses, month, days, sparseLabels: true);
  }

  List<_ChartGroup> _dailyGroups(
    List<AnalyticsPoint> income,
    List<AnalyticsPoint> expenses,
    DateTime start,
    int dayCount, {
    bool sparseLabels = false,
  }) {
    final incomeByDate = _amountsByDate(income, false);
    final expensesByDate = _amountsByDate(expenses, false);
    return [
      for (var index = 0; index < dayCount; index++)
        _dailyGroup(
          start.add(Duration(days: index)),
          incomeByDate,
          expensesByDate,
          showLabel: !sparseLabels || index.isEven,
        ),
    ];
  }

  _ChartGroup _dailyGroup(
    DateTime date,
    Map<DateTime, int> incomeByDate,
    Map<DateTime, int> expensesByDate, {
    required bool showLabel,
  }) {
    final day = _dateOnly(date);
    return _ChartGroup(
      '${day.day}',
      incomeByDate[day] ?? 0,
      expensesByDate[day] ?? 0,
      showLabel: showLabel,
      tooltipLabel: '${day.day} ${_monthLabel(day.month)}',
    );
  }

  List<_ChartGroup> _dataRangeGroups(
    List<AnalyticsPoint> income,
    List<AnalyticsPoint> expenses,
  ) {
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

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

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
  const _ChartGroup(
    this.label,
    this.income,
    this.expense, {
    this.showLabel = true,
    this.tooltipLabel,
  });
  final String label;
  final int income;
  final int expense;
  final bool showLabel;
  final String? tooltipLabel;
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
          borderRadius: BorderRadius.circular(8),
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
