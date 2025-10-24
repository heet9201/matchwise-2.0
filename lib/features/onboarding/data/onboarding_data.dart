import 'package:flutter/material.dart';
import '../models/onboarding_page_model.dart';
import '../../../../core/theme/app_colors.dart';

class OnboardingPageData {
  static final List<OnboardingPageModel> pages = [
    OnboardingPageModel(
      title: 'Welcome to MatchWise',
      description:
          'Your intelligent comparison assistant that helps you make smarter decisions across multiple domains.',
      imagePath: 'assets/images/onboarding_welcome.png',
      icon: Icons.stars_rounded,
      primaryColor: AppColors.primaryGreen,
      keyFeatures: [
        'AI-powered analysis',
        'Multi-domain support',
        'Smart recommendations',
      ],
    ),
    OnboardingPageModel(
      title: 'Upload & Detect',
      description:
          'Simply upload your profile or document. Our AI automatically detects the domain - jobs, education, products, or services.',
      imagePath: 'assets/images/onboarding_upload.png',
      icon: Icons.upload_file_rounded,
      primaryColor: AppColors.detailBlue,
      keyFeatures: [
        'Drag & drop or browse',
        'PDF, DOC, TXT, Images',
        'Auto-domain detection',
      ],
    ),
    OnboardingPageModel(
      title: 'Add Comparison Options',
      description:
          'Upload multiple options to compare against your profile. The more options, the better insights you\'ll get!',
      imagePath: 'assets/images/onboarding_compare.png',
      icon: Icons.compare_arrows_rounded,
      primaryColor: AppColors.warningAmber,
      keyFeatures: [
        'Bulk upload support',
        'Mix different formats',
        'Unlimited comparisons',
      ],
    ),
    OnboardingPageModel(
      title: 'Swipe to Decide',
      description:
          'Review each match with an intuitive swipe interface. Like what you see? Swipe right. Need more info? Tap for details.',
      imagePath: 'assets/images/onboarding_swipe.png',
      icon: Icons.swipe_rounded,
      primaryColor: AppColors.info,
      keyFeatures: [
        'Tinder-style interface',
        'Match scores & insights',
        'Quick actions',
      ],
    ),
    OnboardingPageModel(
      title: 'Get Detailed Insights',
      description:
          'Dive deep into compatibility scores, matching factors, and personalized recommendations for each option.',
      imagePath: 'assets/images/onboarding_insights.png',
      icon: Icons.analytics_rounded,
      primaryColor: AppColors.primaryGreen,
      keyFeatures: [
        'Compatibility breakdown',
        'Strength & weakness analysis',
        'Actionable recommendations',
      ],
    ),
    OnboardingPageModel(
      title: 'Track Your Decisions',
      description:
          'Save your favorites to shortlist and review your comparison history anytime. Make informed choices with confidence!',
      imagePath: 'assets/images/onboarding_track.png',
      icon: Icons.bookmark_rounded,
      primaryColor: AppColors.detailBlue,
      keyFeatures: [
        'Shortlist favorites',
        'Comparison history',
        'Export & share results',
      ],
    ),
  ];
}
