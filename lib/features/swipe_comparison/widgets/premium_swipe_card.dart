import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import '../../../core/models/comparison_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/feedback_service.dart';

enum CardSwipeDirection { none, left, right, up }

class PremiumSwipeCard extends StatefulWidget {
  final ComparisonResult result;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onSwipeUp;
  final VoidCallback? onTap;
  final Function(double, CardSwipeDirection)? onDragUpdate;

  const PremiumSwipeCard({
    Key? key,
    required this.result,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onSwipeUp,
    this.onTap,
    this.onDragUpdate,
  }) : super(key: key);

  @override
  State<PremiumSwipeCard> createState() => _PremiumSwipeCardState();
}

class _PremiumSwipeCardState extends State<PremiumSwipeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  Offset _dragPosition = Offset.zero;
  bool _isDragging = false;
  CardSwipeDirection _swipeDirection = CardSwipeDirection.none;
  double _dragDistance = 0.0;

  // Spring simulation constants
  static const double _kSpringStiffness = 150.0;
  static const double _kSpringDamping = 15.0;
  static const double _kSwipeThreshold = 100.0;
  static const double _kRotationFactor = 0.3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Initialize _animation with default values
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
    _triggerHaptic(HapticType.light);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    setState(() {
      _dragPosition += details.delta;
      _dragDistance = _dragPosition.distance;

      // Determine swipe direction
      if (_dragPosition.dx.abs() > _dragPosition.dy.abs()) {
        _swipeDirection = _dragPosition.dx > 0
            ? CardSwipeDirection.right
            : CardSwipeDirection.left;
      } else if (_dragPosition.dy < -50) {
        _swipeDirection = CardSwipeDirection.up;
      } else {
        _swipeDirection = CardSwipeDirection.none;
      }
    });

    // Trigger haptic at threshold
    if (_dragDistance > _kSwipeThreshold &&
        _dragDistance < _kSwipeThreshold + 10) {
      _triggerHaptic(HapticType.selection);
    }

    // Notify parent
    widget.onDragUpdate?.call(
      _dragDistance / _kSwipeThreshold,
      _swipeDirection,
    );
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_isDragging) return;

    final shouldSwipe = _dragDistance > _kSwipeThreshold;

    if (shouldSwipe) {
      _performSwipeAnimation();
    } else {
      _animateBack();
    }

    setState(() {
      _isDragging = false;
    });
  }

  void _performSwipeAnimation() {
    _triggerHaptic(HapticType.medium);

    // Calculate swipe direction
    final direction = _dragPosition / _dragPosition.distance;

    final endPosition = direction * MediaQuery.of(context).size.width * 2;

    _animation = Tween<Offset>(
      begin: _dragPosition,
      end: Offset(endPosition.dx, endPosition.dy),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _rotationAnimation = Tween<double>(
      begin: _dragPosition.dx * _kRotationFactor * 0.01,
      end: (_swipeDirection == CardSwipeDirection.right ? 0.5 : -0.5),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward(from: 0.0).then((_) {
      // Call appropriate callback
      switch (_swipeDirection) {
        case CardSwipeDirection.left:
          widget.onSwipeLeft?.call();
          break;
        case CardSwipeDirection.right:
          widget.onSwipeRight?.call();
          break;
        case CardSwipeDirection.up:
          widget.onSwipeUp?.call();
          break;
        case CardSwipeDirection.none:
          break;
      }
      _controller.reset();
      setState(() {
        _dragPosition = Offset.zero;
        _dragDistance = 0.0;
        _swipeDirection = CardSwipeDirection.none;
      });
    });
  }

  void _animateBack() {
    final springDescription = SpringDescription(
      mass: 1,
      stiffness: _kSpringStiffness,
      damping: _kSpringDamping,
    );

    final simulation = SpringSimulation(
      springDescription,
      _dragDistance,
      0,
      0,
    );

    _controller.animateWith(simulation).then((_) {
      setState(() {
        _dragPosition = Offset.zero;
        _dragDistance = 0.0;
        _swipeDirection = CardSwipeDirection.none;
      });
      widget.onDragUpdate?.call(0.0, CardSwipeDirection.none);
    });
  }

  void _triggerHaptic(HapticType type) async {
    switch (type) {
      case HapticType.light:
        await feedbackService.haptic(HapticPattern.light);
        break;
      case HapticType.medium:
        await feedbackService.haptic(HapticPattern.medium);
        break;
      case HapticType.selection:
        await feedbackService.haptic(HapticPattern.selection);
        break;
      case HapticType.success:
        await feedbackService.haptic(HapticPattern.success);
        break;
    }
  }

  double get _rotation {
    if (_controller.isAnimating) {
      return _rotationAnimation.value;
    }
    return _dragPosition.dx * _kRotationFactor * 0.01;
  }

  double get _scale {
    if (_controller.isAnimating) {
      return _scaleAnimation.value;
    }
    final scaleReduction = (_dragDistance / 1000).clamp(0.0, 0.05);
    return 1.0 - scaleReduction;
  }

  Offset get _position {
    if (_controller.isAnimating) {
      return _animation.value;
    }
    return _dragPosition;
  }

  double get _opacity {
    if (_controller.isAnimating) {
      return 1.0 - _controller.value;
    }
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cardWidth = size.width - 32;
    final cardHeight = size.height * 0.65;

    return GestureDetector(
      onPanStart: _handleDragStart,
      onPanUpdate: _handleDragUpdate,
      onPanEnd: _handleDragEnd,
      onTap: widget.onTap,
      child: Transform.translate(
        offset: _position,
        child: Transform.rotate(
          angle: _rotation,
          child: Transform.scale(
            scale: _scale,
            child: Opacity(
              opacity: _opacity,
              child: Stack(
                children: [
                  // Main Card
                  Container(
                    width: cardWidth,
                    height: cardHeight,
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: _buildCardContent(),
                    ),
                  ),
                  // Swipe indicators
                  if (_isDragging) _buildSwipeIndicators(cardWidth, cardHeight),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent() {
    final score = widget.result.overallScore;
    final matchCount = widget.result.matchingFactors.length;
    final mismatchCount = widget.result.mismatchingFactors.length;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with score
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.getScoreColor(score).withOpacity(0.1),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.result.itemTitle,
                        style: AppTypography.h3(color: AppColors.textPrimary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 16),
                    _buildScoreBadge(score),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatChip(
                      Icons.check_circle,
                      '$matchCount',
                      AppColors.success,
                    ),
                    const SizedBox(width: 8),
                    _buildStatChip(
                      Icons.warning,
                      '$mismatchCount',
                      AppColors.warning,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Match Summary
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top Matches',
                  style: AppTypography.h5(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                ...widget.result.matchingFactors.take(3).map(
                      (factor) => _buildFactorTile(
                        factor.factor,
                        factor.score,
                        true,
                      ),
                    ),
                const SizedBox(height: 24),
                if (widget.result.mismatchingFactors.isNotEmpty) ...[
                  Text(
                    'Key Gaps',
                    style: AppTypography.h5(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  ...widget.result.mismatchingFactors.take(2).map(
                        (factor) => _buildFactorTile(
                          factor.factor,
                          0,
                          false,
                        ),
                      ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBadge(double score) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.getScoreColor(score),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.getScoreColor(score).withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Text(
        '${score.toInt()}%',
        style: AppTypography.h4(color: AppColors.textWhite)
            .copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: AppTypography.body(color: color)
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildFactorTile(String title, double score, bool isMatch) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            isMatch ? Icons.check_circle : Icons.info,
            size: 20,
            color: isMatch ? AppColors.success : AppColors.warning,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: AppTypography.body(color: AppColors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeIndicators(double width, double height) {
    final progress = (_dragDistance / _kSwipeThreshold).clamp(0.0, 1.0);

    return Positioned.fill(
      child: Stack(
        children: [
          // Left indicator (Pass)
          if (_swipeDirection == CardSwipeDirection.left)
            Positioned(
              left: 40,
              top: height * 0.3,
              child: _buildIndicator(
                'PASS',
                AppColors.error,
                Icons.close,
                progress,
              ),
            ),
          // Right indicator (Shortlist)
          if (_swipeDirection == CardSwipeDirection.right)
            Positioned(
              right: 40,
              top: height * 0.3,
              child: _buildIndicator(
                'LIKE',
                AppColors.success,
                Icons.favorite,
                progress,
              ),
            ),
          // Up indicator (Details)
          if (_swipeDirection == CardSwipeDirection.up)
            Positioned(
              left: width / 2 - 40,
              top: 40,
              child: _buildIndicator(
                'DETAILS',
                AppColors.info,
                Icons.info,
                progress,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIndicator(
      String text, Color color, IconData icon, double progress) {
    return Transform.scale(
      scale: 0.8 + (progress * 0.4),
      child: Opacity(
        opacity: progress,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.textWhite, size: 24),
              const SizedBox(width: 8),
              Text(
                text,
                style: AppTypography.h5(color: AppColors.textWhite)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum HapticType {
  light,
  medium,
  selection,
  success,
}
