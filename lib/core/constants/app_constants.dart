class AppConstants {
  // App Info
  static const String appName = 'MatchWise 2.0';
  static const String appTagline = 'One Solution for Every Decision';
  static const String appVersion = '1.0.0';

  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const int maxComparisonItems = 10;
  static const List<String> supportedFileTypes = [
    'pdf',
    'doc',
    'docx',
    'txt',
    'jpg',
    'jpeg',
    'png',
    'csv',
  ];

  // Timing
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);
  static const Duration processingSimulationDuration = Duration(seconds: 15);

  // Thresholds
  static const double highMatchThreshold = 75.0;
  static const double mediumMatchThreshold = 50.0;
  static const double lowMatchThreshold = 25.0;

  static const double highConfidenceThreshold = 0.85;
  static const double mediumConfidenceThreshold = 0.70;

  // Swipe
  static const double swipeVelocityThreshold = 200.0;
  static const int maxUndoCount = 5;

  // Storage Keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyUserId = 'user_id';
  static const String keyUserName = 'user_name';
  static const String keyUserEmail = 'user_email';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyComparisonHistory = 'comparison_history';
  static const String keyShortlist = 'shortlist';

  // API (Placeholder for future backend)
  static const String apiBaseUrl = 'https://api.matchwise.com';
  static const String apiVersion = 'v1';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 12.0;
  static const double spacingL = 16.0;
  static const double spacingXL = 24.0;
  static const double spacingXXL = 32.0;

  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;

  // Elevation
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;

  // Icon Sizes
  static const double iconSizeS = 16.0;
  static const double iconSizeM = 24.0;
  static const double iconSizeL = 32.0;
  static const double iconSizeXL = 48.0;
  static const double iconSizeXXL = 64.0;

  // Recent Items
  static const int maxRecentComparisons = 5;

  // Cache
  static const Duration cacheDuration = Duration(hours: 24);
}
