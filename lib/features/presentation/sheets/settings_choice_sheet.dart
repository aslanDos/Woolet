import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/features/presentation/widgets/custom_bottom_sheet.dart';

class SettingsChoice<T> {
  const SettingsChoice({required this.value, required this.label});

  final T value;
  final String label;
}

class SettingsChoiceSheet<T> extends StatelessWidget {
  const SettingsChoiceSheet({
    super.key,
    required this.title,
    required this.selected,
    required this.choices,
  });

  final String title;
  final T selected;
  final List<SettingsChoice<T>> choices;

  @override
  Widget build(BuildContext context) => CustomBottomSheet(
    padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.t.headlineMedium),
        const SizedBox(height: 16),
        for (final choice in choices)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _ChoiceTile(
              label: choice.label,
              selected: choice.value == selected,
              onTap: () => Navigator.pop(context, choice.value),
            ),
          ),
      ],
    ),
  );
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected
        ? context.c.onPrimaryContainer
        : context.c.onSurface;
    return Material(
      color: selected ? context.c.primaryContainer : context.c.surfaceContainer,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: context.t.titleMedium?.copyWith(color: foreground),
                ),
              ),
              if (selected)
                Icon(LucideIcons.check, size: 18, color: foreground),
            ],
          ),
        ),
      ),
    );
  }
}
