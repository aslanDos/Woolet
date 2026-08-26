import 'package:flutter/material.dart';
import 'package:woolet/core/constants/app_icons.dart';
import 'package:woolet/core/extensions/pop_up_x.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/theme/app_colors.dart';
import 'package:woolet/features/presentation/sheets/icon_picker_sheet.dart';
import 'package:woolet/features/presentation/widgets/color_picker.dart';
import 'package:woolet/features/presentation/widgets/icon_picker.dart';
import 'package:woolet/features/presentation/widgets/icon_preview.dart';

class IconColorSelector extends StatelessWidget {
  const IconColorSelector({
    super.key,
    required this.icon,
    required this.color,
    required this.onIconChanged,
    required this.onColorChanged,
    this.compact = false,
    this.showPreview = true,
  });

  final AppIcon icon;
  final Color color;
  final ValueChanged<AppIcon> onIconChanged;
  final ValueChanged<Color> onColorChanged;
  final bool compact;
  final bool showPreview;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showPreview) ...[
          IconPreview(icon: icon, color: color),
          const SizedBox(height: 24),
        ],
        IconPickerField(
          selected: icon,
          color: color,
          onSeeAll: () => _openIconPicker(context),
          onChanged: onIconChanged,
        ),
        SizedBox(height: compact ? 4 : 24),
        if (!compact) ...[
          Text('Color', style: context.t.titleLarge),
          const SizedBox(height: 10),
        ],
        ColorPicker(
          colors: AppColors.pickerColors,
          selected: color,
          onChanged: onColorChanged,
        ),
      ],
    );
  }

  Future<void> _openIconPicker(BuildContext context) async {
    final selected = await context.openBottomSheet<AppIcon>(
      showDragHandle: true,
      child: IconPickerSheet(selected: icon, color: color),
    );
    if (selected != null && context.mounted) onIconChanged(selected);
  }
}
