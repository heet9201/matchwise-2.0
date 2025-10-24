import 'package:flutter/material.dart';

class AppColors {
  // Primary Actions
  static const Color primaryGreen = Color(0xFF10B981);
  static const Color rejectRed = Color(0xFFEF4444);
  static const Color detailBlue = Color(0xFF3B82F6);
  static const Color warningAmber = Color(0xFFF59E0B);

  // Backgrounds
  static const Color matchGreen = Color(0xFFD1FAE5);
  static const Color matchGreenDark = Color(0xFF065F46);
  static const Color mismatchRed = Color(0xFFFEE2E2);
  static const Color mismatchRedDark = Color(0xFF991B1B);
  static const Color neutralGray = Color(0xFFF3F4F6);
  static const Color darkBg = Color(0xFF1F2937);

  // Text
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFFF9FAFB);
  static const Color textWhite = Color(0xFFFFFFFF);

  // UI Elements
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color border = Color(0xFFD1D5DB);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient rejectGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient detailGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Opacity Overlays
  static Color primaryGreenOverlay = primaryGreen.withOpacity(0.1);
  static Color rejectRedOverlay = rejectRed.withOpacity(0.1);
  static Color detailBlueOverlay = detailBlue.withOpacity(0.1);

  // Score Colors
  static Color getScoreColor(double score) {
    if (score >= 75) return success;
    if (score >= 50) return warning;
    return error;
  }

  static Color getScoreBackgroundColor(double score) {
    if (score >= 75) return matchGreen;
    if (score >= 50) return Color(0xFFFEF3C7);
    return mismatchRed;
  }
}
