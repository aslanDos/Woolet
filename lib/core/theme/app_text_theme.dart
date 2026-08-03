import 'package:flutter/material.dart';

/* 

Display - Used for large hero text, splash screens, and high-impact headlines.
Headline - Used for page titles and section headings to establish visual hierarchy.
Title - Used for card titles, dialogs, app bars, and other medium-emphasis headings.
Body - Used for the main readable content, such as descriptions, paragraphs, and list items.
Label - Used for buttons, chips, badges, captions, and other small UI labels.

*/

final TextTheme appTextTheme = .new(
  // displayLarge: ,
  // displayMedium: ,
  // displaySmall: ,
  headlineLarge: AppTextStyle.headLine28,

  // headlineMedium: ,
  // headlineSmall: ,
  titleLarge: AppTextStyle.title16,
  titleMedium: AppTextStyle.title14,
  titleSmall: AppTextStyle.title12,

  // bodyLarge: ,
  // bodyMedium: ,
  // bodySmall: ,

  // labelLarge: ,
  // labelMedium: ,
  // labelSmall:
);

class AppTextStyle {
  static const TextStyle headLine28 = TextStyle(
    fontSize: 28,
    fontWeight: .w700,
    height: 1.25,
  );

  static const TextStyle title16 = TextStyle(
    fontSize: 16,
    fontWeight: .w600,
    height: 20 / 16,
  );

  static const TextStyle title14 = TextStyle(
    fontSize: 14,
    fontWeight: .w500,
    height: 18 / 14,
  );

  static const TextStyle title12 = TextStyle(
    fontSize: 12,
    fontWeight: .w400,
    height: 16 / 12,
  );
}
