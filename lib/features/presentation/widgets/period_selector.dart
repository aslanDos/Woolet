import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/features/presentation/sheets/periods_sheet.dart';

class PeriodSelector extends StatelessWidget {
  const PeriodSelector({
    super.key,
    required this.period,
    required this.onTap,
    required this.onPrevious,
    required this.onNext,
    this.textStyle,
  });

  final PeriodSelection period;
  final VoidCallback onTap;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final label = period.label(context);

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: context.c.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PeriodArrow(
            visible: period.canNavigate,
            onTap: onPrevious,
            icon: LucideIcons.chevron_left,
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Center(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      final slide = Tween<Offset>(
                        begin: const Offset(0, 0.15),
                        end: Offset.zero,
                      ).animate(animation);
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(position: slide, child: child),
                      );
                    },
                    child: Text(
                      label,
                      key: ValueKey(label),
                      textAlign: TextAlign.center,
                      style: textStyle ?? context.t.titleMedium,
                    ),
                  ),
                ),
              ),
            ),
          ),
          _PeriodArrow(
            visible: period.canNavigate,
            onTap: onNext,
            icon: LucideIcons.chevron_right,
          ),
        ],
      ),
    );
  }
}

class _PeriodArrow extends StatelessWidget {
  const _PeriodArrow({
    required this.visible,
    required this.onTap,
    required this.icon,
  });

  final bool visible;
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    ignoring: !visible,
    child: Opacity(
      opacity: visible ? 1 : 0,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(width: 36, height: 40, child: Icon(icon, size: 16)),
      ),
    ),
  );
}
