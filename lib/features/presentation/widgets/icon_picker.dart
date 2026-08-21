import 'package:flutter/material.dart';
import 'package:woolet/core/constants/app_icons.dart';
import 'package:woolet/core/extensions/theme_x.dart';

class IconPicker extends StatelessWidget {
  const IconPicker({
    super.key,
    required this.icons,
    required this.selected,
    required this.color,
    required this.onChanged,
    this.crossAxisCount = 6,
    this.itemSize = 44,
    this.spacing = 8,
  });

  static const basicIcons = <AppIcon>[
    AppIcon.wallet,
    AppIcon.banknote,
    AppIcon.creditCard,
    AppIcon.groceries,
    AppIcon.cafe,
    AppIcon.shopping,
    AppIcon.car,
    AppIcon.taxi,
    AppIcon.home,
    AppIcon.briefcase,
    AppIcon.gift,
    AppIcon.entertainment,
  ];

  static List<AppIcon> compactIcons(AppIcon selected) {
    if (basicIcons.contains(selected)) return basicIcons;
    return [...basicIcons.take(11), selected];
  }

  final List<AppIcon> icons;
  final AppIcon selected;
  final Color color;
  final ValueChanged<AppIcon> onChanged;
  final int crossAxisCount;
  final double itemSize;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      primary: false,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: icons.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: itemSize,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
      ),
      itemBuilder: (context, index) {
        final appIcon = icons[index];
        final isSelected = appIcon == selected;

        return Center(
          child: SizedBox.square(
            dimension: itemSize,
            child: Semantics(
              button: true,
              selected: isSelected,
              label: appIcon.code,
              child: Material(
                color: isSelected ? context.c.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () => onChanged(appIcon),
                  splashFactory: NoSplash.splashFactory,
                  borderRadius: BorderRadius.circular(8),
                  child: Icon(
                    appIcon.icon,
                    size: itemSize * 0.5,
                    color: isSelected
                        ? context.c.onPrimary
                        : context.c.onSurface,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class IconPreview extends StatelessWidget {
  const IconPreview({super.key, required this.icon, required this.color});

  final AppIcon icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon.icon, color: color, size: 32),
      ),
    );
  }
}

class IconPickerField extends StatelessWidget {
  const IconPickerField({
    super.key,
    required this.selected,
    required this.color,
    required this.onChanged,
    required this.onSeeAll,
  });

  final AppIcon selected;
  final Color color;
  final ValueChanged<AppIcon> onChanged;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Icon', style: context.t.titleLarge),
            GestureDetector(
              onTap: onSeeAll,
              child: Text(
                'See All',
                style: context.t.titleSmall?.copyWith(
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: context.c.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconPicker(
            icons: IconPicker.compactIcons(selected),
            selected: selected,
            color: color,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
