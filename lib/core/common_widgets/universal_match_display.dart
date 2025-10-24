import 'package:flutter/material.dart';
import '../../core/models/comparison_models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class UniversalMatchDisplay extends StatefulWidget {
  final List<MatchingFactor> matchingFactors;
  final bool isExpanded;

  const UniversalMatchDisplay({
    Key? key,
    required this.matchingFactors,
    this.isExpanded = false,
  }) : super(key: key);

  @override
  State<UniversalMatchDisplay> createState() => _UniversalMatchDisplayState();
}

class _UniversalMatchDisplayState extends State<UniversalMatchDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.matchingFactors.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayFactors = widget.isExpanded
        ? widget.matchingFactors
        : widget.matchingFactors.take(3).toList();

    final remaining = widget.matchingFactors.length - displayFactors.length;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CustomPaint(
                  painter: _GradientBackgroundPainter(
                    color: AppColors.success,
                    animationValue: _animationController.value,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 16),
                        ...displayFactors.asMap().entries.map((entry) {
                          return _buildMatchItem(entry.value, entry.key);
                        }),
                        if (!widget.isExpanded && remaining > 0) ...[
                          const SizedBox(height: 12),
                          _buildMoreIndicator(remaining),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'MATCHING FACTORS',
          style: AppTypography.label(color: AppColors.success).copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${widget.matchingFactors.length}',
            style: AppTypography.bodyMedium(color: AppColors.success).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoreIndicator(int remaining) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.success.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.add_circle_outline,
            size: 16,
            color: AppColors.success.withOpacity(0.8),
          ),
          const SizedBox(width: 6),
          Text(
            '$remaining more matching factors',
            style: AppTypography.small(color: AppColors.success).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchItem(MatchingFactor factor, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    // Progress bar background
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 800),
                        tween: Tween(
                            begin: 0.0,
                            end: _getImportanceWidth(factor.importance)),
                        curve: Curves.easeOutCubic,
                        builder: (context, width, child) {
                          return CustomPaint(
                            painter: _ProgressBarPainter(
                              progress: width,
                              color: AppColors.success,
                            ),
                            size: Size(width, double.infinity),
                          );
                        },
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: AppColors.success,
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        factor.factor,
                                        style: AppTypography.bodyMedium(
                                          color: AppColors.textPrimary,
                                        ).copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildImportanceBadge(factor.importance),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  factor.explanation,
                                  style: AppTypography.small(
                                    color: AppColors.textSecondary,
                                  ).copyWith(height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  double _getImportanceWidth(ImportanceLevel importance) {
    switch (importance) {
      case ImportanceLevel.high:
        return 6.0;
      case ImportanceLevel.medium:
        return 4.0;
      case ImportanceLevel.low:
        return 2.0;
    }
  }

  Widget _buildImportanceBadge(ImportanceLevel importance) {
    Color color;
    String label;

    switch (importance) {
      case ImportanceLevel.high:
        color = AppColors.success;
        label = 'HIGH';
        break;
      case ImportanceLevel.medium:
        color = AppColors.warning;
        label = 'MED';
        break;
      case ImportanceLevel.low:
        color = AppColors.textSecondary;
        label = 'LOW';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTypography.caption(color: color).copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// Custom Painter for gradient background with light reflection
class _GradientBackgroundPainter extends CustomPainter {
  final Color color;
  final double animationValue;

  _GradientBackgroundPainter({
    required this.color,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Base gradient
    final rect = Offset.zero & size;
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        color.withOpacity(0.08),
        color.withOpacity(0.15),
        color.withOpacity(0.08),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(16)),
      paint,
    );

    // Light reflection effect
    final reflectionPath = Path();
    final reflectionWidth = size.width * 0.4;
    final reflectionX =
        (size.width + reflectionWidth) * animationValue - reflectionWidth;

    reflectionPath.moveTo(reflectionX, 0);
    reflectionPath.lineTo(reflectionX + reflectionWidth, 0);
    reflectionPath.lineTo(reflectionX + reflectionWidth - 20, size.height);
    reflectionPath.lineTo(reflectionX - 20, size.height);
    reflectionPath.close();

    final reflectionGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Colors.white.withOpacity(0.0),
        Colors.white.withOpacity(0.2),
        Colors.white.withOpacity(0.0),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final reflectionPaint = Paint()
      ..shader = reflectionGradient.createShader(reflectionPath.getBounds())
      ..style = PaintingStyle.fill;

    canvas.drawPath(reflectionPath, reflectionPaint);

    // Subtle border
    final borderPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(16)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(_GradientBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

// Custom Painter for animated progress bar
class _ProgressBarPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ProgressBarPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final rect = Rect.fromLTWH(0, 0, progress, size.height);

    // Gradient progress bar
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        color.withOpacity(0.15),
        color.withOpacity(0.08),
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    final rrect = RRect.fromRectAndCorners(
      rect,
      topLeft: const Radius.circular(12),
      bottomLeft: const Radius.circular(12),
    );

    canvas.drawRRect(rrect, paint);

    // Glow effect on the edge
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawLine(
      Offset(progress, 0),
      Offset(progress, size.height),
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(_ProgressBarPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
