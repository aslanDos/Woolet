import 'package:flutter/material.dart';
import 'package:pie_menu/pie_menu.dart';
import 'package:woolet/core/constants/app_constants.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/theme/app_color_scheme.dart';
import 'package:woolet/core/theme/app_colors.dart';
import 'package:woolet/core/theme/app_text_theme.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData light = _buildTheme(AppColorScheme.light);
  static final ThemeData dark = _buildTheme(AppColorScheme.dark);

  static ThemeData _buildTheme(ColorScheme scheme) {
    final TextTheme textTheme = appTextTheme.apply(
      fontFamily: AppConstants.fontFamily,
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
      decorationColor: scheme.onSurface,
    );

    final PieTheme pieTheme = PieTheme(
      customAngleDiff: 45,
      radius: 200.0,
      customAngle: 135,
      leftClickShowsMenu: true,
      rightClickShowsMenu: true,
      regularPressShowsMenu: false,
      longPressDuration: const Duration(milliseconds: 350),
      buttonTheme: PieButtonTheme(
        backgroundColor: scheme.primary,
        iconColor: scheme.primary,
      ),
      buttonThemeHovered: PieButtonTheme(
        backgroundColor: scheme.primary,
        iconColor: scheme.primary,
      ),
      overlayColor: scheme.surface.withValues(alpha: 0.7),
      pointerColor: Colors.transparent,
      // pointerSize: 2.0,
      tooltipTextStyle: appTextTheme.headlineLarge?.copyWith(
        color: scheme.primary,
      ),
      menuAlignment: .center,
    );

    return ThemeData(
      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      colorScheme: scheme,
      brightness: scheme.brightness,
      textTheme: textTheme,
      extensions: [
        PieThemeExtension(pieTheme: pieTheme),
        scheme.brightness == Brightness.dark
            ? AppThemeColors.dark
            : AppThemeColors.light,
      ],
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      dividerColor: scheme.outlineVariant,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        leadingWidth: 72,
        centerTitle: true,
        scrolledUnderElevation: 0.0,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(48, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          splashFactory: NoSplash.splashFactory,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          splashFactory: NoSplash.splashFactory,
          backgroundColor: scheme.surfaceContainer,
          foregroundColor: scheme.onSurface,
          iconSize: 24,
          padding: EdgeInsets.all(10),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        modalBackgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }
}
