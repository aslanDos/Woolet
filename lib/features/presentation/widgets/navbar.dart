import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:pie_menu/pie_menu.dart';
import 'package:woolet/core/constants/app_enums.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/extensions/localization_x.dart';
import 'package:woolet/core/extensions/transaction_type_x.dart';

class Navbar extends StatelessWidget {
  const Navbar({
    super.key,
    this.activeIndex = 0,
    required this.onTap,
    required this.onAddTap,
  });

  final int activeIndex;
  final ValueChanged<int> onTap;
  final ValueChanged<TransactionType> onAddTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.c.brightness == Brightness.dark;

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 62,
                  decoration: BoxDecoration(
                    color: isDark
                        ? context.c.surfaceContainerLow
                        : context.c.surface,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: isDark
                          ? context.c.outlineVariant
                          : context.c.outlineVariant.withValues(alpha: 0.45),
                    ),
                    boxShadow: _floatingShadow(context, isDark),
                  ),
                  child: Row(
                    children:
                        [
                              (
                                LucideIcons.receipt_text,
                                context.l10n.transactions,
                              ),
                              (LucideIcons.piggy_bank, context.l10n.budgets),
                            ].indexed
                            .map(
                              (entry) =>
                                  _item(entry.$1, entry.$2.$1, entry.$2.$2),
                            )
                            .toList(),
                  ),
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

  Widget _item(int index, IconData icon, String label) {
    return Expanded(
      child: _NavbarButton(
        index: index,
        isActive: index == activeIndex,
        icon: icon,
        label: label,
        onTap: onTap,
      ),
    );
  }
}

List<BoxShadow> _floatingShadow(BuildContext context, bool isDark) => [
  BoxShadow(
    color: context.c.shadow.withValues(alpha: isDark ? 0.32 : 0.08),
    blurRadius: 10,
    spreadRadius: 1,
    offset: const Offset(0, 2),
  ),
  BoxShadow(
    color: context.c.shadow.withValues(alpha: isDark ? 0.4 : 0.16),
    blurRadius: 28,
    offset: const Offset(0, 10),
  ),
];

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
              height: 52,
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
  const _AddButton({required this.onTap});

  final ValueChanged<TransactionType> onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return PieMenu(
      onPressed: () => onTap(TransactionType.expense),
      actions: TransactionType.values
          .map(
            (type) => PieAction(
              tooltip: Text(type.localizedLabel(context)),
              onSelect: () => onTap(type),
              buttonThemeHovered: PieButtonTheme(
                backgroundColor: type.backgroundColor,
                iconColor: type.backgroundColor,
              ),
              child: Icon(type.icon, size: 24.0, color: context.c.onPrimary),
            ),
          )
          .toList(),
      child: SizedBox.square(
        dimension: 62,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: _floatingShadow(context, isDark),
          ),
          child: Material(
            color: colorScheme.primary,
            shape: const CircleBorder(),
            child: Icon(
              LucideIcons.plus,
              size: 30,
              color: colorScheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
