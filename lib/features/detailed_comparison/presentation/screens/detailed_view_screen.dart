import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/models/comparison_models.dart';
import '../../../../core/common_widgets/universal_match_display.dart';
import '../../../../core/common_widgets/universal_mismatch_display.dart';

class DetailedViewScreen extends StatefulWidget {
  final ComparisonResult? result;

  const DetailedViewScreen({Key? key, this.result}) : super(key: key);

  @override
  State<DetailedViewScreen> createState() => _DetailedViewScreenState();
}

class _DetailedViewScreenState extends State<DetailedViewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.result == null) {
      return const Scaffold(
        body: Center(child: Text('No data available')),
      );
    }

    final result = widget.result!;

    return Scaffold(
      backgroundColor: AppColors.neutralGray,
      appBar: AppBar(
        title: const Text('Detailed Comparison'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primaryGreen,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primaryGreen,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Matching ✓'),
            Tab(text: 'Gaps ✕'),
            Tab(text: 'AI Analysis'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(result),
          _buildMatchingTab(result),
          _buildGapsTab(result),
          _buildAIAnalysisTab(result),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(ComparisonResult result) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Score card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  '${result.overallScore.toInt()}%',
                  style: AppTypography.scoreDisplay(color: AppColors.textWhite),
                ),
                const SizedBox(height: 8),
                Text(
                  'Overall Match Score',
                  style: AppTypography.body(color: AppColors.textWhite),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Summary
          _buildSummaryCard(
            'Matching Factors',
            result.matchingFactors.length.toString(),
            AppColors.success,
          ),
          const SizedBox(height: 12),
          _buildSummaryCard(
            'Non-Matching Factors',
            result.mismatchingFactors.length.toString(),
            AppColors.error,
          ),
          const SizedBox(height: 24),
          // AI Recommendation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.psychology, color: AppColors.detailBlue),
                    const SizedBox(width: 8),
                    Text(
                      'AI Recommendation',
                      style: AppTypography.h5(color: AppColors.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  result.aiRecommendation.decision,
                  style: AppTypography.bodyMedium(color: AppColors.primaryGreen)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  result.aiRecommendation.summary,
                  style: AppTypography.body(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchingTab(ComparisonResult result) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: UniversalMatchDisplay(
        matchingFactors: result.matchingFactors,
        isExpanded: true,
      ),
    );
  }

  Widget _buildGapsTab(ComparisonResult result) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: UniversalMismatchDisplay(
        mismatchingFactors: result.mismatchingFactors,
        isExpanded: true,
      ),
    );
  }

  Widget _buildAIAnalysisTab(ComparisonResult result) {
    final ai = result.aiRecommendation;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Decision
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Decision',
                  style: AppTypography.label(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Text(
                  ai.decision,
                  style: AppTypography.h4(color: AppColors.primaryGreen),
                ),
                const SizedBox(height: 12),
                Text(
                  ai.summary,
                  style: AppTypography.body(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Pros
          if (ai.pros.isNotEmpty) ...[
            Text(
              'Pros',
              style: AppTypography.h5(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            ...ai.pros.map((pro) => _buildListItem(pro, true)),
            const SizedBox(height: 16),
          ],
          // Cons
          if (ai.cons.isNotEmpty) ...[
            Text(
              'Cons',
              style: AppTypography.h5(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            ...ai.cons.map((con) => _buildListItem(con, false)),
            const SizedBox(height: 16),
          ],
          // Alternatives
          if (ai.alternatives.isNotEmpty) ...[
            Text(
              'Alternatives to Consider',
              style: AppTypography.h5(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            ...ai.alternatives.map((alt) => _buildAlternativeItem(alt)),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium(color: AppColors.textPrimary),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value,
              style: AppTypography.h5(color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(String text, bool isPositive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isPositive ? Icons.check_circle : Icons.cancel,
            color: isPositive ? AppColors.success : AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTypography.body(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativeItem(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.arrow_right,
            color: AppColors.detailBlue,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTypography.body(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
