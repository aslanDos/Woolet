import 'package:flutter/material.dart';
import 'package:pie_menu/pie_menu.dart';
import 'package:woolet/core/theme/app_colors.dart';

extension ThemeAccessor on BuildContext {
  TextTheme get t => Theme.of(this).textTheme;
  ColorScheme get c => Theme.of(this).colorScheme;
  PieTheme get pieTheme =>
      Theme.of(this).extension<PieThemeExtension>()!.pieTheme;
  AppThemeColors get appColors => Theme.of(this).extension<AppThemeColors>()!;
}

class PieThemeExtension extends ThemeExtension<PieThemeExtension> {
  const PieThemeExtension({required this.pieTheme});

  final PieTheme pieTheme;

  @override
  ThemeExtension<PieThemeExtension> copyWith({PieTheme? pieTheme}) {
    return PieThemeExtension(pieTheme: pieTheme ?? this.pieTheme);
  }

  @override
  ThemeExtension<PieThemeExtension> lerp(
    covariant ThemeExtension<PieThemeExtension>? other,
    double t,
  ) {
    return (t < 0.5 ? this : other) as PieThemeExtension;
  }
}
