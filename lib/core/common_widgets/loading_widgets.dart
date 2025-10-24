import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Enhanced loading indicator with Lottie animation
class EnhancedLoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;
  final bool showMessage;

  const EnhancedLoadingIndicator({
    Key? key,
    this.message,
    this.size = 200,
    this.showMessage = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie loading animation
          SizedBox(
            width: size,
            height: size,
            child: Lottie.asset(
              'assets/animations/loading.json',
              fit: BoxFit.contain,
              // Fallback to circular indicator if animation not found
              errorBuilder: (context, error, stackTrace) {
                return const CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                );
              },
            ),
          ),
          if (showMessage) ...[
            const SizedBox(height: 24),
            if (message != null)
              Text(
                message!,
                style: AppTypography.body(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              )
            else
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: 3),
                duration: const Duration(seconds: 2),
                builder: (context, value, child) {
                  return Text(
                    'Loading${'.' * (value + 1)}',
                    style: AppTypography.body(color: AppColors.textSecondary),
                  );
                },
                onEnd: () {
                  // Loop animation
                },
              ),
          ],
        ],
      ),
    );
  }
}

/// Small inline loading indicator
class InlineLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const InlineLoadingIndicator({
    Key? key,
    this.size = 24,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.primaryGreen,
        ),
      ),
    );
  }
}

/// Skeleton loading for cards
class SkeletonCard extends StatelessWidget {
  final double height;
  final double? width;
  final BorderRadius? borderRadius;

  const SkeletonCard({
    Key? key,
    this.height = 200,
    this.width,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(16),
        ),
      ),
    );
  }
}

/// Skeleton loading for list items
class SkeletonListItem extends StatelessWidget {
  final bool showAvatar;
  final int lines;

  const SkeletonListItem({
    Key? key,
    this.showAvatar = true,
    this.lines = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showAvatar) ...[
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(
                    lines - 1,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        height: 12,
                        width: double.infinity * (0.7 - index * 0.1),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
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
}

/// Skeleton loading for swipe cards
class SkeletonSwipeCard extends StatelessWidget {
  const SkeletonSwipeCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 20,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 14,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Match factors
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Mismatch factors
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Action buttons
                  Row(
                    children: List.generate(
                      3,
                      (index) => Expanded(
                        child: Container(
                          margin: EdgeInsets.only(
                            left: index > 0 ? 8 : 0,
                          ),
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
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
}

/// Skeleton grid for domain cards
class SkeletonDomainGrid extends StatelessWidget {
  final int itemCount;

  const SkeletonDomainGrid({
    Key? key,
    this.itemCount = 6,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.95,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 16,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Processing animation with steps
class ProcessingAnimation extends StatefulWidget {
  final List<String> steps;
  final int currentStep;

  const ProcessingAnimation({
    Key? key,
    required this.steps,
    required this.currentStep,
  }) : super(key: key);

  @override
  State<ProcessingAnimation> createState() => _ProcessingAnimationState();
}

class _ProcessingAnimationState extends State<ProcessingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Lottie animation
        SizedBox(
          width: 200,
          height: 200,
          child: Lottie.asset(
            'assets/animations/processing.json',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return RotationTransition(
                turns: _controller,
                child: Icon(
                  Icons.autorenew,
                  size: 80,
                  color: AppColors.primaryGreen,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 32),
        // Steps
        ...widget.steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isActive = index == widget.currentStep;
          final isCompleted = index < widget.currentStep;

          return TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            tween: Tween(
              begin: 0.0,
              end: isActive ? 1.0 : (isCompleted ? 1.0 : 0.3),
            ),
            builder: (context, opacity, child) {
              return Opacity(
                opacity: opacity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      // Step indicator
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppColors.success
                              : (isActive
                                  ? AppColors.primaryGreen
                                  : AppColors.neutralGray),
                          shape: BoxShape.circle,
                        ),
                        child: isCompleted
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : (isActive
                                ? const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : null),
                      ),
                      const SizedBox(width: 16),
                      // Step text
                      Expanded(
                        child: Text(
                          step,
                          style: AppTypography.bodyMedium(
                            color: isActive
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ).copyWith(
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }
}
