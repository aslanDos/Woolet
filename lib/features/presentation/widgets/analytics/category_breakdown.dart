import 'package:flutter/material.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/utils/amount_utils.dart';
import 'package:woolet/features/domain/entities/analytics_entity.dart';
import 'package:woolet/features/domain/entities/category_entity.dart';

class CategoryBreakdown extends StatelessWidget {
  const CategoryBreakdown({
    super.key,
    required this.values,
    required this.categories,
    required this.totalMinor,
    required this.symbol,
  });

  final List<AnalyticsCategoryTotal> values;
  final List<CategoryEntity> categories;
  final int totalMinor;
  final String? symbol;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return Text(
        'No expenses in this period',
        style: context.t.bodyMedium?.copyWith(color: context.c.outline),
      );
    }
    return Column(
      children: values.take(5).map((value) {
        final category = _category(value.categoryUuid);
        final progress = totalMinor == 0 ? 0.0 : value.amountMinor / totalMinor;
        final color = category?.colorValue == null
            ? context.c.primary
            : Color(category!.colorValue!);
        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      category?.name ?? 'Other',
                      style: context.t.titleMedium,
                    ),
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: context.t.titleSmall,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${AmountUtils.formatMinor(value.amountMinor)}${symbol == null ? '' : ' $symbol'}',
                    style: context.t.bodySmall?.copyWith(
                      color: context.c.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 7,
                  color: color,
                  backgroundColor: context.c.surfaceContainerHighest,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  CategoryEntity? _category(String? uuid) {
    for (final category in categories) {
      if (category.uuid == uuid) return category;
    }
    return null;
  }
}
