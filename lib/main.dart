import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:woolet/core/bootstrap/app_bootstrap.dart';
import 'package:woolet/core/di/service_locator.dart';
import 'package:woolet/core/router/router.dart';
import 'package:woolet/core/theme/app_theme.dart';
import 'package:woolet/core/theme/theme_controller.dart';
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
      builder: (context, themeMode, _) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Woolet',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
