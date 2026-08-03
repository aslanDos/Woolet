import 'package:flutter/material.dart';
import 'package:woolet/core/theme/app_colors.dart';

class AppColorScheme {
  AppColorScheme._();

  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,

    primary: AppColors.black,
    onPrimary: AppColors.white,

    primaryContainer: AppColors.neutral900,
    onPrimaryContainer: AppColors.white,

    secondary: AppColors.neutral700,
    onSecondary: AppColors.white,

    secondaryContainer: AppColors.neutral200,
    onSecondaryContainer: AppColors.neutral900,

    tertiary: AppColors.neutral500,
    onTertiary: AppColors.white,

    error: AppColors.red0,
    onError: AppColors.white,

    surface: AppColors.neutral100,
    onSurface: AppColors.black,

    surfaceContainerLowest: AppColors.white,
    surfaceContainerLow: AppColors.neutral50,

    surfaceContainer: AppColors.white,

    surfaceContainerHigh: AppColors.neutral200,
    surfaceContainerHighest: AppColors.neutral300,

    onSurfaceVariant: AppColors.neutral400,

    outline: AppColors.neutral400,
    outlineVariant: AppColors.neutral200,

    shadow: AppColors.black,

    scrim: AppColors.black,

    inverseSurface: AppColors.neutral900,

    onInverseSurface: AppColors.neutral50,

    inversePrimary: AppColors.white,
  );

  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,

    primary: AppColors.white,
    onPrimary: AppColors.black,

    primaryContainer: AppColors.neutral100,
    onPrimaryContainer: AppColors.neutral950,

    secondary: AppColors.neutral300,
    onSecondary: AppColors.neutral950,

    secondaryContainer: AppColors.neutral800,
    onSecondaryContainer: AppColors.neutral100,

    tertiary: AppColors.neutral400,
    onTertiary: AppColors.neutral950,

    error: AppColors.red1,
    onError: AppColors.neutral950,

    surface: AppColors.neutral950,
    onSurface: AppColors.neutral50,

    surfaceContainerLowest: AppColors.black,
    surfaceContainerLow: AppColors.neutral900,

    surfaceContainer: AppColors.neutral800,

    surfaceContainerHigh: AppColors.neutral700,
    surfaceContainerHighest: AppColors.neutral600,

    onSurfaceVariant: AppColors.neutral600,

    outline: AppColors.neutral500,
    outlineVariant: AppColors.neutral800,

    shadow: AppColors.black,

    scrim: AppColors.black,

    inverseSurface: AppColors.neutral100,
    onInverseSurface: AppColors.neutral900,

    inversePrimary: AppColors.black,
  );
}
