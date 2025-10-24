import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/services/onboarding_service.dart';
import '../../../../core/services/feedback_service.dart';
import '../../data/onboarding_data.dart';
import '../../models/onboarding_page_model.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<OnboardingPageModel> _pages = OnboardingPageData.pages;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() async {
    await feedbackService.tap();
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() async {
    await feedbackService.tap();
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() async {
    await feedbackService.tap();
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    await feedbackService.success();
    await OnboardingService.completeOnboarding();
    if (mounted) {
      context.go(RouteNames.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralGray,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button (only show if not on first page)
                  if (_currentPage > 0)
                    TextButton.icon(
                      onPressed: _previousPage,
                      icon: const Icon(Icons.arrow_back_ios, size: 16),
                      label: const Text('Back'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                      ),
                    )
                  else
                    const SizedBox(width: 80),
                  // Page indicator
                  Text(
                    '${_currentPage + 1}/${_pages.length}',
                    style: AppTypography.small(color: AppColors.textSecondary),
                  ),
                  // Skip button (only show if not on last page)
                  if (_currentPage < _pages.length - 1)
                    TextButton(
                      onPressed: _skipOnboarding,
                      child: Text(
                        'Skip',
                        style: AppTypography.small(
                          color: AppColors.textSecondary,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                    )
                  else
                    const SizedBox(width: 80),
                ],
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingPage(
                    page: _pages[index],
                    isActive: index == _currentPage,
                  );
                },
              ),
            ),

            // Progress indicator and button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Dot indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => _buildDotIndicator(index),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Next/Get Started button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pages[_currentPage].primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage < _pages.length - 1
                                ? 'Next'
                                : 'Get Started',
                            style: AppTypography.buttonLarge(
                              color: AppColors.textWhite,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _currentPage < _pages.length - 1
                                ? Icons.arrow_forward_rounded
                                : Icons.check_rounded,
                            size: 24,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(
                          begin: 0.2,
                          end: 0,
                          duration: 400.ms,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDotIndicator(int index) {
    final isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? _pages[_currentPage].primaryColor : AppColors.border,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingPageModel page;
  final bool isActive;

  const _OnboardingPage({
    required this.page,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Icon/Illustration placeholder
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: page.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 100,
              color: page.primaryColor,
            ),
          )
              .animate(target: isActive ? 1 : 0)
              .fadeIn(duration: 600.ms)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),

          const SizedBox(height: 40),

          // Title
          Text(
            page.title,
            style: AppTypography.h1(color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          )
              .animate(target: isActive ? 1 : 0)
              .fadeIn(delay: 200.ms, duration: 600.ms)
              .slideY(begin: 0.3, end: 0),

          const SizedBox(height: 16),

          // Description
          Text(
            page.description,
            style: AppTypography.body(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          )
              .animate(target: isActive ? 1 : 0)
              .fadeIn(delay: 400.ms, duration: 600.ms)
              .slideY(begin: 0.3, end: 0),

          const SizedBox(height: 32),

          // Key features
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: page.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Key Features',
                      style: AppTypography.h3(color: AppColors.textPrimary)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...page.keyFeatures.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: page.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: AppTypography.body(
                                color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ).animate(target: isActive ? 1 : 0).fadeIn(
                        delay: (600 + (entry.key * 100)).ms,
                        duration: 400.ms,
                      );
                }),
              ],
            ),
          )
              .animate(target: isActive ? 1 : 0)
              .fadeIn(delay: 600.ms, duration: 600.ms)
              .slideY(begin: 0.3, end: 0),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
