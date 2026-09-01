# Woolet

<p align="center">
  <img src="assets/images/app_icon.png" alt="Woolet logo" width="160">
</p>

Woolet is a cross-platform personal finance app built with Flutter. It helps users manage accounts, track income and expenses, plan budgets, and understand their spending habits.

## Demo

<p align="center">
  <img src="assets/images/demo.gif" alt="Woolet app demo" width="160">
</p>

## Functionality

- Create, edit, categorize, filter, and delete transactions
- Record income, expenses, and transfers between accounts
- Create and manage multiple accounts in different currencies
- Create daily, weekly, monthly, and yearly budgets
- Track budget progress by account and spending category
- View income and expense analytics for custom time periods
- Manage transaction categories, icons, and colors
- Switch between light, dark, and system themes
- Choose a preferred currency
- Store accounts, transactions, budgets, categories, and preferences locally

## Technologies

- **Flutter & Dart** — cross-platform UI
- **BLoC** — state management
- **Drift & SQLite** — local database
- **GetIt** — dependency injection
- **GoRouter** — navigation
- **SharedPreferences** — user preferences
- **FL Chart** — financial analytics charts
- **Clean Architecture** — data, domain, and presentation layers

## Getting Started

Requirements: Flutter SDK with Dart `^3.10.7`.

```bash
flutter pub get
flutter run
```

Run the tests:

```bash
flutter test
```

Supported platforms: Android and iOS.
