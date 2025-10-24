import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/common_widgets/loading_widgets.dart';
import '../../../../core/services/onboarding_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingAndNavigate();
  }

  Future<void> _checkOnboardingAndNavigate() async {
    await Future.delayed(AppConstants.splashDuration);

    if (mounted) {
      final hasCompletedOnboarding =
          await OnboardingService.hasCompletedOnboarding();

      if (hasCompletedOnboarding) {
        context.go(RouteNames.home);
      } else {
        context.go(RouteNames.onboarding);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.textWhite,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.compare_arrows_rounded,
                size: 60,
                color: AppColors.primaryGreen,
              ),
            ).animate().scale(
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                ),
            const SizedBox(height: 32),
            // App Name
            Text(
              AppConstants.appName,
              style: AppTypography.h1(color: AppColors.textWhite),
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0),
            const SizedBox(height: 12),
            // Tagline
            Text(
              AppConstants.appTagline,
              style: AppTypography.body(
                  color: AppColors.textWhite.withOpacity(0.9)),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 600.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0),
            const SizedBox(height: 48),
            // Loading Indicator
            const SizedBox(
              width: 80,
              height: 80,
              child: EnhancedLoadingIndicator(
                size: 80,
                showMessage: false,
              ),
            ).animate().fadeIn(delay: 900.ms),
          ],
        ),
      ),
    );
  }
}
