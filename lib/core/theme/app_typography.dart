import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  // Heading Styles
  static TextStyle h1({Color? color}) => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: color,
        height: 1.2,
      );

  static TextStyle h2({Color? color}) => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: color,
        height: 1.3,
      );

  static TextStyle h3({Color? color}) => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.3,
      );

  static TextStyle h4({Color? color}) => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.4,
      );

  static TextStyle h5({Color? color}) => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.4,
      );

  // Body Styles
  static TextStyle bodyLarge({Color? color}) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: color,
        height: 1.5,
      );

  static TextStyle body({Color? color}) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: color,
        height: 1.5,
      );

  static TextStyle bodyMedium({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: color,
        height: 1.5,
      );

  static TextStyle small({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: color,
        height: 1.4,
      );

  static TextStyle caption({Color? color}) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: color,
        height: 1.3,
      );

  // Button Styles
  static TextStyle buttonLarge({Color? color}) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.0,
      );

  static TextStyle button({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.0,
      );

  static TextStyle buttonSmall({Color? color}) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.0,
      );

  // Special Styles
  static TextStyle scoreDisplay({Color? color}) => GoogleFonts.inter(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: color,
        height: 1.0,
      );

  static TextStyle cardTitle({Color? color}) => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.3,
      );

  static TextStyle label({Color? color}) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color,
        height: 1.2,
        letterSpacing: 0.5,
      );

  static TextStyle overline({Color? color}) => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: color,
        height: 1.2,
        letterSpacing: 1.0,
      );
}
