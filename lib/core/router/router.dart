import 'package:go_router/go_router.dart';
import 'package:woolet/core/router/routes.dart';
import 'package:woolet/features/presentation/screens/splash_screen.dart';
import 'package:woolet/main_tab_view.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: SplashScreen()),
      ),
      GoRoute(
        path: AppRoutes.main,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: MainTabView()),
      ),
    ],
  );
}
