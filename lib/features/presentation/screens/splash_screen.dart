import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:woolet/core/constants/app_constants.dart';
import 'package:woolet/core/di/service_locator.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/router/routes.dart';
import 'package:woolet/core/usecases/usecase.dart';
import 'package:woolet/features/domain/usecases/auth/is_signed_in.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.6, curve: Curves.easeInBack),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.6, curve: Curves.easeInToLinear),
      ),
    );

    _animationController.forward().then((_) => _openInitialRoute());
  }

  Future<void> _openInitialRoute() async {
    // always show onboarding
    // if (mounted) {
    //   context.go(AppRoutes.onboarding);
    //   return;
    // }

    final authResult = await sl<IsSignedIn>()(const NoParams());
    final isSignedIn = authResult.getOrElse(() => false);
    final onboardingCompleted =
        sl<SharedPreferences>().getBool(AppConstants.onboardingCompletedKey) ??
        false;

    if (!mounted) return;
    if (isSignedIn) {
      context.go(AppRoutes.main);
    } else if (onboardingCompleted) {
      context.go(AppRoutes.login);
    } else {
      context.go(AppRoutes.onboarding);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: .center,
              children: [
                // SvgPicture.asset('assets/images/logo_icon.png'),
                SvgPicture.asset(
                  'assets/images/logo_text.svg',
                  colorFilter: .mode(context.c.onSurface, .srcIn),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
