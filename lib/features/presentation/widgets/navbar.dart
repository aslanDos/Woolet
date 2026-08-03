import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/extensions/theme_x.dart';

class Navbar extends StatelessWidget {
  const Navbar({
    super.key,
    this.activeIndex = 0,
    required this.onTap,
    this.onAddTap,
  });

  final int activeIndex;
  final ValueChanged<int> onTap;
  final VoidCallback? onAddTap;

  static const _items = <({IconData icon, String label})>[
    (icon: LucideIcons.receipt_text, label: 'Transactions'),
    (icon: LucideIcons.chart_no_axes_column_increasing, label: 'Analytics'),
    (icon: LucideIcons.wallet_cards, label: 'Budgets'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.c.brightness == Brightness.dark;

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 58,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: isDark
                        ? context.c.surfaceContainerLow
                        : context.c.surface,
                    borderRadius: BorderRadius.circular(38),
                    border: isDark
                        ? Border.all(color: context.c.outlineVariant)
                        : null,
                    boxShadow: isDark
                        ? null
                        : [
                            BoxShadow(
                              color: context.c.shadow.withValues(alpha: 0.12),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                  ),
                  child: Row(children: [_item(0), _item(1), _item(2)]),
                ),
              ),
              const SizedBox(width: 12),
              _AddButton(onTap: onAddTap),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(int index) {
    final item = _items[index];

    return Expanded(
      child: _NavbarButton(
        index: index,
        isActive: index == activeIndex,
        icon: item.icon,
        label: item.label,
        onTap: onTap,
      ),
    );
  }
}

class _NavbarButton extends StatelessWidget {
  const _NavbarButton({
    required this.index,
    required this.isActive,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final int index;
  final bool isActive;
  final IconData icon;
  final String label;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isActive,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          borderRadius: BorderRadius.circular(32),
          child: Center(
            child: SizedBox(
              width: 52,
              height: 58,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedScale(
                    scale: isActive ? 1.08 : 1,
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutBack,
                    child: Icon(
                      icon,
                      size: 24,
                      color: isActive
                          ? context.c.primary
                          : context.c.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Semantics(
      button: true,
      label: 'Add transaction',
      child: SizedBox.square(
        dimension: 58,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.16),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Material(
            color: colorScheme.primary,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Icon(
                LucideIcons.plus,
                color: colorScheme.onPrimary,
                size: 30,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
