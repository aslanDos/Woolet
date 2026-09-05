import 'package:flutter/widgets.dart';
import 'package:woolet/l10n/app_localizations.dart';

extension LocalizationX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  String localizedAccountName(String name) => switch (name) {
    'Cash' => l10n.defaultCash,
    _ => name,
  };

  String localizedCategoryName(String name) => switch (name) {
    'Salary' => l10n.defaultSalary,
    'Freelance' => l10n.defaultFreelance,
    'Investments' => l10n.defaultInvestments,
    'Gifts' => l10n.defaultGifts,
    'Interest' => l10n.defaultInterest,
    'Other' => l10n.defaultOther,
    'Groceries' => l10n.defaultGroceries,
    'Cafe' => l10n.defaultCafe,
    'Entertainment' => l10n.defaultEntertainment,
    'Fuel' => l10n.defaultFuel,
    'Shopping' => l10n.defaultShopping,
    'Taxi' => l10n.defaultTaxi,
    'Home' => l10n.defaultHome,
    'Car' => l10n.defaultCar,
    'Pharmacy' => l10n.defaultPharmacy,
    _ => name,
  };
}

extension LocaleLabelX on Locale {
  String localizedName(AppLocalizations l10n) => switch (languageCode) {
    'ru' => l10n.languageRussian,
    'kk' => l10n.languageKazakh,
    _ => l10n.languageEnglish,
  };
}
