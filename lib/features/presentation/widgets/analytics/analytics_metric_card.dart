import 'package:flutter/material.dart';
import 'package:woolet/core/extensions/theme_x.dart';

class AnalyticsMetricCard extends StatelessWidget {
  const AnalyticsMetricCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: context.c.surfaceContainer,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: context.c.primary),
        const SizedBox(height: 18),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.t.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: context.t.bodySmall?.copyWith(color: context.c.outline),
        ),
      ],
    ),
  );
}
