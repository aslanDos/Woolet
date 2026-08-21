import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color black = Color(0xFF081126);
  static const Color neutral950 = Color(0xFF0A0A0A);
  static const Color neutral900 = Color(0xFF171717);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color white = Color(0xFFFFFFFF);

  static const Color red0 = Color(0xFFDC2626);
  static const Color red1 = Color(0xFFF87171);

  static const Color green0 = Color(0xFF16A34A);
  static const Color green1 = Color(0xFF4ADE80);

  static const Color blue0 = Color(0xFF2563EB);
  static const Color blue1 = Color(0xFF60A5FA);

  static const List<Color> pickerColors = [
    Color(0xFF16A34A),
    Color(0xFF0D9488),
    Color(0xFF2563EB),
    Color(0xFF4F46E5),
    Color(0xFF7C3AED),
    Color(0xFFC026D3),
    Color(0xFFE11D48),
    Color(0xFFDC2626),
    Color(0xFFEA580C),
    Color(0xFFD97706),
    Color(0xFF64748B),
    Color(0xFF475569),
  ];
}

@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({
    required this.income,
    required this.expense,
    required this.transfer,
  });

  final Color income;
  final Color expense;
  final Color transfer;

  static const AppThemeColors light = AppThemeColors(
    income: AppColors.green0,
    expense: AppColors.red0,
    transfer: AppColors.blue0,
  );

  static const AppThemeColors dark = AppThemeColors(
    income: AppColors.green1,
    expense: AppColors.red1,
    transfer: AppColors.blue1,
  );

  @override
  AppThemeColors copyWith({Color? income, Color? expense, Color? transfer}) {
    return AppThemeColors(
      income: income ?? this.income,
      expense: expense ?? this.expense,
      transfer: transfer ?? this.transfer,
    );
  }

  @override
  AppThemeColors lerp(covariant AppThemeColors? other, double t) {
    if (other == null) return this;

    return AppThemeColors(
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      transfer: Color.lerp(transfer, other.transfer, t)!,
    );
  }
}
