import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/extensions/localization_x.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/features/presentation/widgets/custom_bottom_sheet.dart';

class LanguagePickerSheet extends StatelessWidget {
  const LanguagePickerSheet({super.key, required this.selected});

  final Locale? selected;

  static const _locales = [Locale('en'), Locale('ru'), Locale('kk')];

  @override
  Widget build(BuildContext context) {
    final current = selected ?? Localizations.localeOf(context);

    return CustomBottomSheet(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.selectLanguage, style: context.t.headlineMedium),
          const SizedBox(height: 16),
          ..._locales.map(
            (locale) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _LanguageOption(
                locale: locale,
                selected: locale.languageCode == current.languageCode,
                onTap: () => Navigator.pop(context, locale),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.locale,
    required this.selected,
    required this.onTap,
  });

  final Locale locale;
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
              SizedBox(
                width: 24,
                child: Text(
                  switch (locale.languageCode) {
                    'ru' => 'RU',
                    'kk' => 'KZ',
                    _ => 'EN',
                  },
                  style: context.t.labelMedium?.copyWith(
                    color: foregroundColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  locale.localizedName(context.l10n),
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
