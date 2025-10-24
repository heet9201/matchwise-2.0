import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/universal_upload/presentation/screens/upload_input_screen.dart';
import '../../features/detection/presentation/screens/detection_result_screen.dart';
import '../../features/detection/presentation/screens/manual_selection_screen.dart';
import '../../features/comparison_upload/presentation/screens/comparison_upload_screen.dart';
import '../../features/comparison_processing/presentation/screens/processing_screen.dart';
import '../../features/swipe_comparison/presentation/screens/swipe_screen.dart';
import '../../features/detailed_comparison/presentation/screens/detailed_view_screen.dart';
import '../../features/results/presentation/screens/shortlist_screen.dart';
import '../../features/results/presentation/screens/history_screen.dart';
import '../../features/home/presentation/screens/settings_screen.dart';
import 'route_names.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RouteNames.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: RouteNames.upload,
        name: 'upload',
        builder: (context, state) => const UploadInputScreen(),
      ),
      GoRoute(
        path: RouteNames.detection,
        name: 'detection',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return DetectionResultScreen(
            detectedContent: extra?['detectedContent'],
          );
        },
      ),
      GoRoute(
        path: RouteNames.manualSelection,
        name: 'manual-selection',
        builder: (context, state) => const ManualSelectionScreen(),
      ),
      GoRoute(
        path: RouteNames.optionsUpload,
        name: 'options-upload',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ComparisonUploadScreen(
            comparisonType: extra?['comparisonType'],
            userProfile: extra?['userProfile'],
          );
        },
      ),
      GoRoute(
        path: RouteNames.processing,
        name: 'processing',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ProcessingScreen(
            userProfile: extra?['userProfile'],
            comparisonItems: extra?['comparisonItems'],
            domainType: extra?['domainType'],
          );
        },
      ),
      GoRoute(
        path: RouteNames.swipe,
        name: 'swipe',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return SwipeScreen(
            comparisonResults: extra?['comparisonResults'] ?? [],
          );
        },
      ),
      GoRoute(
        path: RouteNames.detailedView,
        name: 'detailed-view',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return DetailedViewScreen(
            result: extra?['result'],
          );
        },
      ),
      GoRoute(
        path: RouteNames.shortlist,
        name: 'shortlist',
        builder: (context, state) => const ShortlistScreen(),
      ),
      GoRoute(
        path: RouteNames.history,
        name: 'history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: RouteNames.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
}
