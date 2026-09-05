import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:woolet/l10n/app_localizations.dart';
import 'package:woolet/core/bootstrap/app_bootstrap.dart';
import 'package:woolet/core/di/service_locator.dart';
import 'package:woolet/core/router/router.dart';
import 'package:woolet/core/theme/app_theme.dart';
import 'package:woolet/core/theme/theme_controller.dart';
import 'package:woolet/core/settings/locale_controller.dart';
import 'package:woolet/core/widgets/biometric_gate.dart';
import 'package:woolet/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await bootstrapApp();

  runApp(const WooletApp());
}

class WooletApp extends StatelessWidget {
  const WooletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: sl<ThemeController>(),
      builder: (context, themeMode, _) => ValueListenableBuilder<Locale?>(
        valueListenable: sl<LocaleController>(),
        builder: (context, locale, _) => MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Woolet',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routerConfig: AppRouter.router,
          builder: (context, child) => BiometricGate(child: child!),
        ),
      ),
    );
  }
}
