import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/domain_types.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/ai_engine/universal_matcher.dart';
import '../../../../core/ai_engine/comparison_suggester.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/common_widgets/loading_widgets.dart';

class ProcessingScreen extends StatefulWidget {
  final Map<String, dynamic>? userProfile;
  final List<Map<String, dynamic>>? comparisonItems;
  final DomainType? domainType;

  const ProcessingScreen({
    Key? key,
    this.userProfile,
    this.comparisonItems,
    this.domainType,
  }) : super(key: key);

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  int _currentStep = 0;
  final List<String> _steps = [
    'Extracting information from documents...',
    'Analyzing compatibility...',
    'Calculating match scores...',
    'Preparing results...',
  ];

  @override
  void initState() {
    super.initState();
    _processComparisons();
  }

  Future<void> _processComparisons() async {
    final matcher = UniversalMatcher();
    final suggester = ComparisonSuggester();

    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        setState(() => _currentStep = i + 1);
      }
    }

    if (widget.userProfile != null && widget.comparisonItems != null) {
      final weights = suggester.getWeights(widget.domainType ?? DomainType.job);

      final results = await Future.wait(
        widget.comparisonItems!.map((item) => matcher.compare(
              userProfile: widget.userProfile!,
              comparisonItem: item,
              domainType: widget.domainType ?? DomainType.job,
              weights: weights,
            )),
      );

      if (mounted) {
        context.go(
          RouteNames.swipe,
          extra: {'comparisonResults': results},
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentStep / _steps.length).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.neutralGray,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Processing Animation with Steps
              ProcessingAnimation(
                steps: _steps,
                currentStep: _currentStep,
              ),
              const SizedBox(height: 48),
              // Progress bar
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Step $_currentStep/${_steps.length}',
                        style:
                            AppTypography.small(color: AppColors.textSecondary),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style:
                            AppTypography.small(color: AppColors.primaryGreen)
                                .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: AppColors.neutralGray,
                      valueColor:
                          const AlwaysStoppedAnimation(AppColors.primaryGreen),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Current step
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.sync,
                      color: AppColors.primaryGreen,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _currentStep < _steps.length
                            ? _steps[_currentStep]
                            : _steps.last,
                        style: AppTypography.body(color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Cancel button
              TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  'Cancel',
                  style: AppTypography.button(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
