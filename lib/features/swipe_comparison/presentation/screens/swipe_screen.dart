import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/models/comparison_models.dart';
import '../../providers/swipe_provider.dart';
import '../../widgets/premium_swipe_card.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/services/feedback_service.dart';

class SwipeScreen extends ConsumerStatefulWidget {
  final List<ComparisonResult> comparisonResults;

  const SwipeScreen({Key? key, required this.comparisonResults})
      : super(key: key);

  @override
  ConsumerState<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends ConsumerState<SwipeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _backgroundController;
  late Animation<Color?> _backgroundColorAnimation;

  CardSwipeDirection _currentDirection = CardSwipeDirection.none;
  double _swipeProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _backgroundColorAnimation = ColorTween(
      begin: AppColors.neutralGray,
      end: AppColors.neutralGray,
    ).animate(_backgroundController);
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  void _handleSwipeLeft() async {
    final notifier = ref.read(swipeProvider(widget.comparisonResults).notifier);

    // Trigger feedback
    await feedbackService.swipeLeft();

    // Animate background
    _animateBackground(AppColors.error.withOpacity(0.1));

    notifier.swipeLeft();

    // Check if completed
    Future.delayed(const Duration(milliseconds: 400), () {
      final state = ref.read(swipeProvider(widget.comparisonResults));
      if (!state.hasMore) {
        _showCompletionDialog();
      }
    });
  }

  void _handleSwipeRight() async {
    final notifier = ref.read(swipeProvider(widget.comparisonResults).notifier);

    // Trigger feedback
    await feedbackService.swipeRight();

    // Animate background
    _animateBackground(AppColors.success.withOpacity(0.1));

    notifier.swipeRight();

    // Check if completed
    Future.delayed(const Duration(milliseconds: 400), () {
      final state = ref.read(swipeProvider(widget.comparisonResults));
      if (!state.hasMore) {
        _showCompletionDialog();
      }
    });
  }

  void _handleSwipeUp() async {
    final state = ref.read(swipeProvider(widget.comparisonResults));

    if (state.currentResult != null) {
      // Trigger feedback
      await feedbackService.swipeUp();

      _viewDetails(state.currentResult!);
    }
  }

  void _animateBackground(Color targetColor) {
    _backgroundColorAnimation = ColorTween(
      begin: AppColors.neutralGray,
      end: targetColor,
    ).animate(_backgroundController);

    _backgroundController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        _backgroundController.reverse();
      });
    });
  }

  void _handleDragUpdate(double progress, CardSwipeDirection direction) {
    setState(() {
      _swipeProgress = progress;
      _currentDirection = direction;
    });
  }

  void _undoLastSwipe() async {
    final notifier = ref.read(swipeProvider(widget.comparisonResults).notifier);

    await feedbackService.undo();

    notifier.undo();
  }

  void _showCompletionDialog() {
    final state = ref.read(swipeProvider(widget.comparisonResults));

    // Play completion feedback
    feedbackService.completion();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 60,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'All Done! 🎉',
                style: AppTypography.h3(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              Text(
                'You\'ve reviewed all ${widget.comparisonResults.length} items',
                style: AppTypography.body(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      Icons.favorite,
                      state.shortlist.length,
                      'Shortlisted',
                      AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      Icons.close,
                      state.passed.length,
                      'Passed',
                      AppColors.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await feedbackService.tap();
                    if (context.mounted) {
                      context.pop();
                      context.push(RouteNames.shortlist, extra: {
                        'shortlist': state.shortlist,
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'View Shortlist',
                    style: AppTypography.body(color: AppColors.textWhite)
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, int count, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: AppTypography.h4(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.caption(color: color),
          ),
        ],
      ),
    );
  }

  void _viewDetails(ComparisonResult result) {
    context.push(
      RouteNames.detailedView,
      extra: {'result': result},
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(swipeProvider(widget.comparisonResults));
    final hasMore = state.hasMore;
    final currentResult = state.currentResult;

    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Scaffold(
          backgroundColor:
              _backgroundColorAnimation.value ?? AppColors.neutralGray,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              '${state.currentIndex + 1}/${widget.comparisonResults.length}',
              style: AppTypography.h5(color: AppColors.textPrimary),
            ),
            actions: [
              // Shortlist badge
              IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.list_alt, color: AppColors.textPrimary),
                    if (state.shortlist.isNotEmpty)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.success.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Text(
                            '${state.shortlist.length}',
                            style: const TextStyle(
                              color: AppColors.textWhite,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () => context.push(RouteNames.shortlist, extra: {
                  'shortlist': state.shortlist,
                }),
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: AppColors.textPrimary),
                onPressed: () => context.push(RouteNames.settings),
              ),
            ],
          ),
          body: Column(
            children: [
              // Main card area
              Expanded(
                child: hasMore
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          // Next card preview (for depth effect)
                          if (state.currentIndex + 1 <
                              widget.comparisonResults.length)
                            Transform.scale(
                              scale: 0.9,
                              child: Opacity(
                                opacity: 0.5,
                                child: _buildCardPreview(
                                  widget.comparisonResults[
                                      state.currentIndex + 1],
                                ),
                              ),
                            ),
                          // Current card
                          Center(
                            child: PremiumSwipeCard(
                              result: currentResult!,
                              onSwipeLeft: _handleSwipeLeft,
                              onSwipeRight: _handleSwipeRight,
                              onSwipeUp: _handleSwipeUp,
                              onTap: () => _viewDetails(currentResult),
                              onDragUpdate: _handleDragUpdate,
                            ),
                          ),
                        ],
                      )
                    : _buildCompletionView(state),
              ),
              // Bottom actions
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Undo button
                      _buildActionButton(
                        icon: Icons.undo,
                        label: 'Undo',
                        color: AppColors.textSecondary,
                        size: 50,
                        onPressed: state.canUndo ? _undoLastSwipe : null,
                      ),
                      // Pass button
                      _buildActionButton(
                        icon: Icons.close,
                        label: 'Pass',
                        color: AppColors.error,
                        size: 70,
                        isPrimary: true,
                        onPressed: hasMore ? _handleSwipeLeft : null,
                      ),
                      // Swipe counter
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.info.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.remove_red_eye,
                                color: AppColors.info,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${state.currentIndex}/${widget.comparisonResults.length}',
                            style: AppTypography.caption(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      // Like button
                      _buildActionButton(
                        icon: Icons.favorite,
                        label: 'Like',
                        color: AppColors.success,
                        size: 70,
                        isPrimary: true,
                        onPressed: hasMore ? _handleSwipeRight : null,
                      ),
                      // View shortlist
                      _buildActionButton(
                        icon: Icons.list_alt,
                        label: 'List',
                        color: AppColors.primaryGreen,
                        size: 50,
                        badge: state.shortlist.isNotEmpty
                            ? '${state.shortlist.length}'
                            : null,
                        onPressed: () =>
                            context.push(RouteNames.shortlist, extra: {
                          'shortlist': state.shortlist,
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCardPreview(ComparisonResult result) {
    return Container(
      width: MediaQuery.of(context).size.width - 32,
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: BoxDecoration(
        color: AppColors.cardBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }

  Widget _buildCompletionView(SwipeState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              size: 80,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'All items reviewed!',
            style: AppTypography.h3(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Text(
            '${state.shortlist.length} items shortlisted',
            style: AppTypography.body(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.push(RouteNames.shortlist, extra: {
              'shortlist': state.shortlist,
            }),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'View Shortlist',
              style: AppTypography.body(color: AppColors.textWhite)
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required double size,
    String? badge,
    bool isPrimary = false,
    VoidCallback? onPressed,
  }) {
    final isEnabled = onPressed != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: isEnabled
                    ? (isPrimary ? color : color.withOpacity(0.1))
                    : AppColors.textSecondary.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: isPrimary && isEnabled
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 3,
                        ),
                      ]
                    : [],
              ),
              child: IconButton(
                icon: Icon(icon, size: size * 0.5),
                color: isEnabled
                    ? (isPrimary ? AppColors.textWhite : color)
                    : AppColors.textSecondary.withOpacity(0.3),
                onPressed: onPressed,
              ),
            ),
            if (badge != null)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.error.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.caption(
            color: isEnabled ? color : AppColors.textSecondary.withOpacity(0.3),
          ),
        ),
      ],
    );
  }
}
