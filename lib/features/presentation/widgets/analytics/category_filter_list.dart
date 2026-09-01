import 'package:flutter/material.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/utils/amount_utils.dart';
import 'package:woolet/core/widgets/pressable.dart';
import 'package:woolet/features/presentation/widgets/analytics/category_breakdown_controller.dart';
import 'package:woolet/features/presentation/widgets/icon_preview.dart';

class CategoryFilterList extends StatelessWidget {
  const CategoryFilterList({
    super.key,
    required this.segments,
    required this.totalMinor,
    required this.symbol,
    required this.allSelected,
    required this.isSelected,
    required this.onSelectAll,
    required this.onToggle,
  });

  final List<CategorySegment> segments;
  final int totalMinor;
  final String symbol;
  final bool allSelected;
  final bool Function(String id) isSelected;
  final VoidCallback onSelectAll;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _AllCategoriesCard(selected: allSelected, onTap: onSelectAll),
      const SizedBox(height: 10),
      for (var index = 0; index < segments.length; index++) ...[
        _CategoryCard(
          segment: segments[index],
          totalMinor: totalMinor,
          symbol: symbol,
          selected: isSelected(segments[index].id),
          onTap: () => onToggle(segments[index].id),
        ),
        if (index < segments.length - 1) const SizedBox(height: 10),
      ],
    ],
  );
}

class _AllCategoriesCard extends StatelessWidget {
  const _AllCategoriesCard({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: onTap,
    child: Opacity(
      opacity: selected ? 1 : .5,
      child: _CardContainer(
        child: Row(
          children: [
            Expanded(
              child: Text('All Categories', style: context.t.titleMedium),
            ),
            const SizedBox(width: 12),
            _RoundCheckbox(value: selected, onChanged: onTap),
          ],
        ),
      ),
    ),
  );
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.segment,
    required this.totalMinor,
    required this.symbol,
    required this.selected,
    required this.onTap,
  });

  final CategorySegment segment;
  final int totalMinor;
  final String symbol;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final percentage = totalMinor == 0
        ? 0
        : (segment.amountMinor / totalMinor * 100).round();
    return Pressable(
      onTap: onTap,
      child: _CardContainer(
        child: Row(
          children: [
            IconPreview.compact(icon: segment.icon, color: segment.color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    segment.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.t.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$percentage%',
                    style: context.t.bodySmall?.copyWith(
                      color: context.c.outline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${AmountUtils.formatMinor(segment.amountMinor)} $symbol',
              style: context.t.titleSmall,
            ),
            const SizedBox(width: 10),
            _RoundCheckbox(value: selected, onChanged: onTap),
          ],
        ),
      ),
    );
  }
}

class _CardContainer extends StatelessWidget {
  const _CardContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: context.c.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(12),
    ),
    child: child,
  );
}

class _RoundCheckbox extends StatelessWidget {
  const _RoundCheckbox({required this.value, required this.onChanged});

  final bool value;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 24,
    height: 24,
    child: Checkbox(
      value: value,
      onChanged: (_) => onChanged(),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: context.c.onSurfaceVariant, width: 1.5),
      shape: const CircleBorder(),
    ),
  );
}
