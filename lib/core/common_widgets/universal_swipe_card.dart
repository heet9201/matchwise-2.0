import 'package:flutter/material.dart';
import '../../core/models/comparison_models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'universal_match_display.dart';
import 'universal_mismatch_display.dart';

class UniversalSwipeCard extends StatelessWidget {
  final ComparisonResult result;
  final VoidCallback? onTap;
  final VoidCallback? onPass;
  final VoidCallback? onShortlist;

  const UniversalSwipeCard({
    Key? key,
    required this.result,
    this.onTap,
    this.onPass,
    this.onShortlist,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMatchSummary(),
                    const SizedBox(height: 16),
                    UniversalMatchDisplay(
                      matchingFactors: result.matchingFactors,
                    ),
                    const SizedBox(height: 12),
                    UniversalMismatchDisplay(
                      mismatchingFactors: result.mismatchingFactors,
                    ),
                    const SizedBox(height: 16),
                    _buildAISummary(),
                  ],
                ),
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final scoreColor = AppColors.getScoreColor(result.overallScore);
    final scoreBgColor = AppColors.getScoreBackgroundColor(result.overallScore);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scoreBgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  result.itemTitle,
                  style: AppTypography.h4(color: AppColors.textPrimary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: scoreColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${result.overallScore.toInt()}%',
                  style: AppTypography.h3(color: AppColors.textWhite),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildMatchBadge(result.overallScore),
        ],
      ),
    );
  }

  Widget _buildMatchBadge(double score) {
    String label;
    Color color;

    if (score >= 75) {
      label = '🟢 Excellent Match';
      color = AppColors.success;
    } else if (score >= 50) {
      label = '🟡 Good Match';
      color = AppColors.warning;
    } else {
      label = '🔴 Limited Match';
      color = AppColors.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: AppTypography.small(color: color).copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMatchSummary() {
    final totalMatches = result.matchingFactors.length;
    final totalFactors = totalMatches + result.mismatchingFactors.length;
    final matchPercentage =
        totalFactors > 0 ? (totalMatches / totalFactors) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Match Progress',
              style: AppTypography.bodyMedium(color: AppColors.textSecondary),
            ),
            Text(
              '$totalMatches/$totalFactors matched',
              style: AppTypography.bodyMedium(color: AppColors.textPrimary)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: matchPercentage,
            minHeight: 8,
            backgroundColor: AppColors.mismatchRed,
            valueColor: const AlwaysStoppedAnimation(AppColors.success),
          ),
        ),
      ],
    );
  }

  Widget _buildAISummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.detailBlueOverlay,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.detailBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.psychology,
            color: AppColors.detailBlue,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              result.aiRecommendation.summary,
              style: AppTypography.small(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutralGray,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: onPass,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rejectRed,
                foregroundColor: AppColors.textWhite,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'PASS',
                style: AppTypography.button(color: AppColors.textWhite),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.detailBlue,
                side: const BorderSide(color: AppColors.detailBlue, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Details',
                style: AppTypography.button(color: AppColors.detailBlue),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: onShortlist,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.textWhite,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'SHORTLIST',
                style: AppTypography.button(color: AppColors.textWhite),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
