import 'package:flutter/material.dart';
import 'package:woolet/core/constants/icons.dart';
import 'package:woolet/core/extensions/theme_x.dart';

class TransactionCard extends StatelessWidget {
  const TransactionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: context.c.surfaceContainer,
        borderRadius: .circular(12),
      ),
      child: Row(
        children: [
          // Icon Box
          Container(
            padding: .all(10),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.4),
              borderRadius: .circular(12),
            ),
            child: Icon(AppIcon.banknote.icon, color: Colors.green, size: 24),
          ),

          const SizedBox(width: 10),

          // Category Name + Description
          Expanded(
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: .start,
              children: [
                Text('Credits', style: context.t.titleLarge),
                const SizedBox(height: 4),
                Text(
                  'Kaspi',
                  style: context.t.titleSmall?.copyWith(
                    color: context.c.outline,
                  ),
                ),
              ],
            ),
          ),

          // Amount
          Text(
            '+ 2 948 TG',
            style: context.t.titleMedium?.copyWith(
              color: context.appColors.income,
            ),
          ),
        ],
      ),
    );
  }
}
