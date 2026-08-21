import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/features/presentation/widgets/custom_bottom_sheet.dart';

extension ThemeModeUI on ThemeMode {
  String get label => switch (this) {
    ThemeMode.system => 'System',
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
  };

  IconData get icon => switch (this) {
    ThemeMode.system => LucideIcons.monitor_cog,
    ThemeMode.light => LucideIcons.sun,
    ThemeMode.dark => LucideIcons.moon,
  };
}

class ThemePickerSheet extends StatelessWidget {
  const ThemePickerSheet({super.key, required this.selected});

  final ThemeMode selected;

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Theme', style: context.t.headlineMedium),
          const SizedBox(height: 16),
          ...ThemeMode.values.map(
            (mode) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ThemeOption(
                mode: mode,
                selected: mode == selected,
                onTap: () => Navigator.pop(context, mode),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final ThemeMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = selected
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
              Icon(mode.icon, size: 20, color: foregroundColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  mode.label,
                  style: context.t.titleMedium?.copyWith(
                    color: foregroundColor,
                  ),
                ),
              ),
              if (selected)
                Icon(LucideIcons.check, size: 18, color: foregroundColor),
            ],
          ),
        ),
      ),
    );
  }
}
