import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/services/feedback_service.dart';
import 'core/services/image_cache_service.dart';
import 'core/services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize feedback service
  try {
    await feedbackService.initialize();
  } catch (e) {
    debugPrint('Warning: FeedbackService initialization failed: $e');
  }

  // Initialize image cache service
  try {
    await imageCacheService.initialize();
  } catch (e) {
    debugPrint('Warning: ImageCacheService initialization failed: $e');
  }

  // Initialize database service
  try {
    await databaseService.initialize();
  } catch (e) {
    debugPrint('Warning: DatabaseService initialization failed: $e');
  }

  runApp(
    const ProviderScope(
      child: MatchWiseApp(),
    ),
  );
}
