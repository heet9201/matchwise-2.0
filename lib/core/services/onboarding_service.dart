import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _onboardingCompleteKey = 'onboarding_complete';

  /// Check if the user has completed onboarding
  static Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompleteKey) ?? false;
  }

  /// Mark onboarding as completed
  static Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompleteKey, true);
  }

  /// Reset onboarding status (useful for testing or settings)
  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingCompleteKey);
  }
}
