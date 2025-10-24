import 'package:flutter/material.dart';

class OnboardingPageModel {
  final String title;
  final String description;
  final String imagePath;
  final IconData icon;
  final Color primaryColor;
  final List<String> keyFeatures;

  const OnboardingPageModel({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.icon,
    required this.primaryColor,
    required this.keyFeatures,
  });
}
