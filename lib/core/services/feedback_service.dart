import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Types of haptic feedback patterns
enum HapticPattern {
  light, // Subtle tap feedback
  medium, // Standard interaction
  heavy, // Important action
  success, // Positive confirmation
  warning, // Attention needed
  error, // Negative action
  selection, // Item selection/toggle
  impact, // Collision/snap
}

/// Types of sound effects
enum SoundEffect {
  tap, // Generic tap
  swipeLeft, // Pass/Reject
  swipeRight, // Like/Accept
  swipeUp, // Super like
  undo, // Undo action
  success, // Success confirmation
  error, // Error notification
  toggle, // Toggle switch
  notification, // Notification alert
  completion, // Task completed
  pop, // Modal dismiss
  whoosh, // Transition
}

/// Premium haptic and audio feedback service
class FeedbackService {
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;
  FeedbackService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isInitialized = false;
  bool _hapticsEnabled = true;
  bool _soundsEnabled = true;
  bool _hasVibrator = false;

  /// Initialize the feedback service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Check if device has vibrator
      _hasVibrator = await Vibration.hasVibrator() ?? false;

      // Load preferences
      final prefs = await SharedPreferences.getInstance();
      _hapticsEnabled = prefs.getBool('haptics_enabled') ?? true;
      _soundsEnabled = prefs.getBool('sounds_enabled') ?? true;

      // Configure audio player
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      await _audioPlayer.setVolume(0.5);

      _isInitialized = true;
    } catch (e) {
      debugPrint('FeedbackService initialization error: $e');
    }
  }

  /// Enable or disable haptic feedback
  Future<void> setHapticsEnabled(bool enabled) async {
    _hapticsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('haptics_enabled', enabled);
  }

  /// Enable or disable sound effects
  Future<void> setSoundsEnabled(bool enabled) async {
    _soundsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sounds_enabled', enabled);
  }

  /// Check if haptics are enabled
  bool get hapticsEnabled => _hapticsEnabled;

  /// Check if sounds are enabled
  bool get soundsEnabled => _soundsEnabled;

  /// Trigger haptic feedback
  Future<void> haptic(HapticPattern pattern) async {
    if (!_hapticsEnabled || !_hasVibrator) return;

    try {
      switch (pattern) {
        case HapticPattern.light:
          HapticFeedback.lightImpact();
          await Vibration.vibrate(duration: 10, amplitude: 50);
          break;

        case HapticPattern.medium:
          HapticFeedback.mediumImpact();
          await Vibration.vibrate(duration: 20, amplitude: 128);
          break;

        case HapticPattern.heavy:
          HapticFeedback.heavyImpact();
          await Vibration.vibrate(duration: 40, amplitude: 255);
          break;

        case HapticPattern.success:
          HapticFeedback.mediumImpact();
          await Vibration.vibrate(
            pattern: [0, 50, 50, 50],
            intensities: [0, 128, 0, 255],
          );
          break;

        case HapticPattern.warning:
          await Vibration.vibrate(
            pattern: [0, 30, 50, 30],
            intensities: [0, 200, 0, 200],
          );
          break;

        case HapticPattern.error:
          await Vibration.vibrate(
            pattern: [0, 50, 30, 50, 30, 50],
            intensities: [0, 255, 0, 200, 0, 255],
          );
          break;

        case HapticPattern.selection:
          HapticFeedback.selectionClick();
          await Vibration.vibrate(duration: 15, amplitude: 100);
          break;

        case HapticPattern.impact:
          HapticFeedback.heavyImpact();
          await Vibration.vibrate(duration: 30, amplitude: 200);
          break;
      }
    } catch (e) {
      debugPrint('Haptic feedback error: $e');
    }
  }

  /// Play a sound effect
  Future<void> sound(SoundEffect effect) async {
    if (!_soundsEnabled) return;

    try {
      final soundPath = _getSoundPath(effect);
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(soundPath));
    } catch (e) {
      debugPrint('Sound effect error: $e');
    }
  }

  /// Combined haptic + sound feedback
  Future<void> feedback(HapticPattern haptic, SoundEffect sound) async {
    await Future.wait([
      this.haptic(haptic),
      this.sound(sound),
    ]);
  }

  /// Feedback for swipe left (reject)
  Future<void> swipeLeft() async {
    await feedback(HapticPattern.medium, SoundEffect.swipeLeft);
  }

  /// Feedback for swipe right (accept)
  Future<void> swipeRight() async {
    await feedback(HapticPattern.success, SoundEffect.swipeRight);
  }

  /// Feedback for swipe up (super like)
  Future<void> swipeUp() async {
    await feedback(HapticPattern.heavy, SoundEffect.swipeUp);
  }

  /// Feedback for undo action
  Future<void> undo() async {
    await feedback(HapticPattern.light, SoundEffect.undo);
  }

  /// Feedback for button tap
  Future<void> tap() async {
    await feedback(HapticPattern.light, SoundEffect.tap);
  }

  /// Feedback for successful action
  Future<void> success() async {
    await feedback(HapticPattern.success, SoundEffect.success);
  }

  /// Feedback for error
  Future<void> error() async {
    await feedback(HapticPattern.error, SoundEffect.error);
  }

  /// Feedback for toggle switch
  Future<void> toggle() async {
    await feedback(HapticPattern.selection, SoundEffect.toggle);
  }

  /// Feedback for completion
  Future<void> completion() async {
    await feedback(HapticPattern.success, SoundEffect.completion);
  }

  /// Feedback for notification
  Future<void> notification() async {
    await feedback(HapticPattern.medium, SoundEffect.notification);
  }

  /// Feedback for modal/dialog dismiss
  Future<void> pop() async {
    await feedback(HapticPattern.light, SoundEffect.pop);
  }

  /// Feedback for screen transition
  Future<void> transition() async {
    await haptic(HapticPattern.light);
  }

  /// Get sound file path
  String _getSoundPath(SoundEffect effect) {
    switch (effect) {
      case SoundEffect.tap:
        return 'sounds/tap.mp3';
      case SoundEffect.swipeLeft:
        return 'sounds/swipe_left.mp3';
      case SoundEffect.swipeRight:
        return 'sounds/swipe_right.mp3';
      case SoundEffect.swipeUp:
        return 'sounds/swipe_up.mp3';
      case SoundEffect.undo:
        return 'sounds/undo.mp3';
      case SoundEffect.success:
        return 'sounds/success.mp3';
      case SoundEffect.error:
        return 'sounds/error.mp3';
      case SoundEffect.toggle:
        return 'sounds/toggle.mp3';
      case SoundEffect.notification:
        return 'sounds/notification.mp3';
      case SoundEffect.completion:
        return 'sounds/completion.mp3';
      case SoundEffect.pop:
        return 'sounds/pop.mp3';
      case SoundEffect.whoosh:
        return 'sounds/whoosh.mp3';
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}

/// Global feedback service instance
final feedbackService = FeedbackService();
