import 'package:flutter/material.dart';
import 'package:woolet/core/extensions/theme_x.dart';

class TypeToggle<T> extends StatelessWidget {
  const TypeToggle({
    super.key,
    required this.items,
    required this.selected,
    required this.onChanged,
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.selectedForegroundColor,
  });

  final List<TypeToggleItem<T>> items;
  final T selected;
  final ValueChanged<T> onChanged;
  final Color? backgroundColor;
  final Color Function(T value)? selectedBackgroundColor;
  final Color Function(T value)? selectedForegroundColor;

  @override
  Widget build(BuildContext context) {
    assert(items.isNotEmpty, 'TypeToggle.items must not be empty.');

    final selectedIndex = items.indexWhere((item) => item.value == selected);
    assert(
      selectedIndex >= 0,
      'TypeToggle.selected must match one of the item values.',
    );

    if (items.isEmpty) return const SizedBox.shrink();

    final safeSelectedIndex = selectedIndex < 0 ? 0 : selectedIndex;
    final selectedItem = items[safeSelectedIndex];
    final indicatorColor =
        selectedItem.selectedBackgroundColor ??
        selectedBackgroundColor?.call(selectedItem.value) ??
        context.c.primary;

    return Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: backgroundColor ?? context.c.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / items.length;

          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                left: safeSelectedIndex * itemWidth,
                top: 0,
                bottom: 0,
                width: itemWidth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: indicatorColor,
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
              ),
              Row(
                children: items.map((item) {
                  final isSelected = item.value == selected;
                  final foregroundColor = isSelected
                      ? item.selectedForegroundColor ??
                            selectedForegroundColor?.call(item.value) ??
                            context.c.onPrimary
                      : context.c.onSurfaceVariant;

                  return Expanded(
                    child: Semantics(
                      button: true,
                      selected: isSelected,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: isSelected
                              ? null
                              : () => onChanged(item.value),
                          splashFactory: NoSplash.splashFactory,
                          borderRadius: BorderRadius.circular(11),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Center(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style:
                                    (isSelected
                                            ? context.t.titleSmall
                                            : context.t.titleSmall)
                                        ?.copyWith(
                                          color: foregroundColor,
                                          fontSize: item.fontSize,
                                        ) ??
                                    TextStyle(
                                      color: foregroundColor,
                                      fontSize: item.fontSize,
                                    ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AnimatedSize(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      curve: Curves.easeOutCubic,
                                      child: Icon(
                                        item.icon,
                                        size: item.fontSize,
                                        color: foregroundColor,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(item.label),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class TypeToggleItem<T> {
  const TypeToggleItem({
    required this.value,
    required this.label,
    this.icon,
    this.fontSize = 12,
    this.selectedBackgroundColor,
    this.selectedForegroundColor,
  });

  final T value;
  final String label;
  final IconData? icon;
  final double fontSize;
  final Color? selectedBackgroundColor;
  final Color? selectedForegroundColor;
}
