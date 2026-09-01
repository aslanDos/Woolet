import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/utils/amount_utils.dart';
import 'package:woolet/features/presentation/widgets/analytics/category_breakdown_controller.dart';

class CategoryDonutChart extends StatelessWidget {
  const CategoryDonutChart({
    super.key,
    required this.segments,
    required this.totalMinor,
    required this.focusedSegment,
    required this.symbol,
    required this.isFocused,
    required this.onSegmentTap,
  });

  final List<CategorySegment> segments;
  final int totalMinor;
  final CategorySegment? focusedSegment;
  final String symbol;
  final bool Function(String id) isFocused;
  final ValueChanged<int?> onSegmentTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              centerSpaceRadius: 66,
              sectionsSpace: 2,
              startDegreeOffset: -90,
              pieTouchData: PieTouchData(
                enabled: true,
                touchCallback: (event, response) {
                  if (event is! FlTapUpEvent) return;
                  onSegmentTap(response?.touchedSection?.touchedSectionIndex);
                },
              ),
              sections: [
                for (final segment in segments) _section(context, segment),
              ],
            ),
            duration: const Duration(milliseconds: 250),
          ),
          _ChartCenter(
            segment: focusedSegment,
            totalMinor: totalMinor,
            symbol: symbol,
          ),
        ],
      ),
    );
  }

  PieChartSectionData _section(BuildContext context, CategorySegment segment) {
    final share = totalMinor == 0 ? 0.0 : segment.amountMinor / totalMinor;
    return PieChartSectionData(
      value: segment.amountMinor.toDouble(),
      color: segment.color.withValues(alpha: .5),
      radius: isFocused(segment.id) ? 32 : 28,
      showTitle: false,
      badgeWidget: share < .05
          ? null
          : Icon(
              segment.icon,
              color: segment.color,
              size: share < .08 ? 9 : 13,
            ),
      badgePositionPercentageOffset: .5,
      borderSide: BorderSide(color: context.c.surfaceContainer, width: 1),
    );
  }
}

class _ChartCenter extends StatelessWidget {
  const _ChartCenter({
    required this.segment,
    required this.totalMinor,
    required this.symbol,
  });

  final CategorySegment? segment;
  final int totalMinor;
  final String symbol;

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 180),
    child: SizedBox(
      key: ValueKey(segment?.id ?? 'total'),
      width: 104,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (segment != null) ...[
            Icon(segment!.icon, color: segment!.color, size: 20),
            const SizedBox(height: 3),
          ],
          Text(
            segment?.name ?? 'Total',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: context.t.labelMedium,
          ),
          const SizedBox(height: 2),
          Text(
            '${AmountUtils.formatMinor(segment?.amountMinor ?? totalMinor)} $symbol',
            maxLines: 1,
            style: context.t.titleLarge,
          ),
        ],
      ),
    ),
  );
}
