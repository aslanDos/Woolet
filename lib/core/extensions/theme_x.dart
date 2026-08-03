import 'package:flutter/material.dart';
import 'package:woolet/core/theme/app_colors.dart';

extension ThemeAccessor on BuildContext {
  TextTheme get t => Theme.of(this).textTheme;
  ColorScheme get c => Theme.of(this).colorScheme;
  AppThemeColors get appColors => Theme.of(this).extension<AppThemeColors>()!;
}
