import 'package:flutter/material.dart';
import 'package:woolet/core/constants/app_enums.dart';
import 'package:woolet/core/di/service_locator.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/extensions/transaction_type_x.dart';
import 'package:woolet/core/settings/currency_controller.dart';
import 'package:woolet/features/domain/entities/analytics_entity.dart';
import 'package:woolet/features/domain/entities/category_entity.dart';
import 'package:woolet/features/presentation/widgets/analytics/category_breakdown_controller.dart';
import 'package:woolet/features/presentation/widgets/analytics/category_donut_chart.dart';
import 'package:woolet/features/presentation/widgets/analytics/category_filter_list.dart';
import 'package:woolet/features/presentation/widgets/type_toggle.dart';

class CategoryBreakdown extends StatefulWidget {
  const CategoryBreakdown({
    super.key,
    required this.incomeValues,
    required this.expenseValues,
    required this.categories,
    required this.incomeTotalMinor,
    required this.expenseTotalMinor,
    required this.symbol,
  });

  final List<AnalyticsCategoryTotal> incomeValues;
  final List<AnalyticsCategoryTotal> expenseValues;
  final List<CategoryEntity> categories;
  final int incomeTotalMinor;
  final int expenseTotalMinor;
  final String? symbol;

  @override
  State<CategoryBreakdown> createState() => _CategoryBreakdownState();
}

class _CategoryBreakdownState extends State<CategoryBreakdown> {
  late final CategoryBreakdownController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CategoryBreakdownController(
      incomeValues: widget.incomeValues,
      expenseValues: widget.expenseValues,
      categories: widget.categories,
      incomeTotalMinor: widget.incomeTotalMinor,
      expenseTotalMinor: widget.expenseTotalMinor,
    );
  }

  @override
  void didUpdateWidget(covariant CategoryBreakdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.update(
      incomeValues: widget.incomeValues,
      expenseValues: widget.expenseValues,
      categories: widget.categories,
      incomeTotalMinor: widget.incomeTotalMinor,
      expenseTotalMinor: widget.expenseTotalMinor,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, _) {
      final segments = _controller.segments;
      final currency = widget.symbol ?? sl<CurrencyController>().value.symbol;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.c.surfaceContainer,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(controller: _controller),
            const SizedBox(height: 20),
            if (segments.isEmpty)
              _EmptyState(typeLabel: _controller.typeLabel)
            else ...[
              CategoryDonutChart(
                segments: _controller.chartSegments,
                totalMinor: _controller.chartTotalMinor,
                focusedSegment: _controller.focusedSegment,
                symbol: currency,
                isFocused: _controller.isSegmentFocused,
                onSegmentTap: _controller.focusSegmentAt,
              ),
              const SizedBox(height: 12),
              CategoryFilterList(
                segments: segments,
                totalMinor: _controller.totalMinor,
                symbol: currency,
                allSelected: _controller.allCategoriesSelected,
                isSelected: _controller.isCategorySelected,
                onSelectAll: _controller.selectAll,
                onToggle: _controller.toggleCategory,
              ),
            ],
          ],
        ),
      );
    },
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.controller});

  final CategoryBreakdownController controller;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          '${controller.typeLabel} by category',
          style: context.t.titleLarge,
        ),
      ),
      SizedBox(
        width: 76,
        height: 34,
        child: TypeToggle<TransactionType>(
          showLabels: false,
          items: [
            TypeToggleItem(
              value: TransactionType.income,
              label: 'Income',
              icon: TransactionType.income.icon,
            ),
            TypeToggleItem(
              value: TransactionType.expense,
              label: 'Expenses',
              icon: TransactionType.expense.icon,
            ),
          ],
          selected: controller.selectedType,
          onChanged: controller.selectType,
          backgroundColor: context.c.surfaceContainerHighest,
          selectedBackgroundColor: (value) => value == TransactionType.income
              ? context.appColors.income
              : context.appColors.expense,
        ),
      ),
    ],
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.typeLabel});

  final String typeLabel;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 180,
    child: Center(
      child: Text(
        'No ${typeLabel.toLowerCase()} in this period',
        style: context.t.bodyMedium?.copyWith(color: context.c.outline),
      ),
    ),
  );
}
