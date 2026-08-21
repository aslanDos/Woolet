import 'package:flutter/material.dart';
import 'package:woolet/core/constants/app_icons.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/features/presentation/widgets/custom_bottom_sheet.dart';
import 'package:woolet/features/presentation/widgets/icon_picker.dart';

class IconPickerSheet extends StatelessWidget {
  const IconPickerSheet({
    super.key,
    required this.selected,
    required this.color,
  });

  final AppIcon selected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final groups = IconGroup.values
        .map(
          (group) => (
            group: group,
            icons: AppIcon.values
                .where((icon) => icon.group == group)
                .toList(growable: false),
          ),
        )
        .where((entry) => entry.icons.isNotEmpty);

    return CustomBottomSheet(
      safeAreaBottom: false,
      height: MediaQuery.sizeOf(context).height * 0.78,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in groups) ...[
            Text(entry.group.label, style: context.t.titleLarge),
            const SizedBox(height: 18),
            IconPicker(
              icons: entry.icons,
              selected: selected,
              color: color,
              onChanged: (icon) => Navigator.pop(context, icon),
            ),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}
