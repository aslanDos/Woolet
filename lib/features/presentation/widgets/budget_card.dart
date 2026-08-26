import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/constants/app_icons.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/utils/amount_utils.dart';
import 'package:woolet/core/widgets/pressable.dart';
import 'package:woolet/features/presentation/blocs/budget/budget_bloc.dart';

class BudgetCard extends StatelessWidget {
  const BudgetCard({
    super.key,
    required this.item,
    required this.currencySymbol,
    required this.categoryCount,
    this.onTap,
  });

  final BudgetItem item;
  final String currencySymbol;
  final int? categoryCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final budget = item.budget;
    final accent = Color(budget.colorValue);
    final isOver = item.remainingMinor < 0;
    final statusColor = isOver
        ? context.appColors.expense
        : context.c.onSurface;
    // final remaining = AmountUtils.formatMinor(item.remainingMinor.abs());
    final spent = AmountUtils.formatMinor(item.spentMinor);
    final limit = AmountUtils.formatMinor(budget.amountMinor);

    return Semantics(
      button: onTap != null,
      label: budget.name,
      child: Pressable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.c.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            // border: Border.all(color: context.c.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      AppIcon.fromCode(budget.iconCode).icon,
                      size: 17,
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            budget.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.t.titleMedium,
                          ),
                        ),
                        if (categoryCount != null) ...[
                          const SizedBox(width: 7),
                          _CategoryCountChip(count: categoryCount!),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$spent / $limit $currencySymbol',
                    style: context.t.bodySmall?.copyWith(color: statusColor),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: item.progress.clamp(0.0, 1.0),
                  minHeight: 4,
                  color: statusColor,
                  backgroundColor: context.c.surfaceContainerHighest,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCountChip extends StatelessWidget {
  const _CategoryCountChip({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.c.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.tags, size: 11, color: context.c.onSurface),
          const SizedBox(width: 3),
          Text(
            '$count',
            style: context.t.labelSmall?.copyWith(color: context.c.onSurface),
          ),
        ],
      ),
    );
  }
}
