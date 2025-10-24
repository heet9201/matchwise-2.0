import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/domain_types.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/services/feedback_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralGray,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverPadding(
              padding: const EdgeInsets.all(AppConstants.spacingL),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildWelcomeSection(),
                  const SizedBox(height: AppConstants.spacingXL),
                  _buildMainUploadButton(context),
                  const SizedBox(height: AppConstants.spacingL),
                  _buildPasteTextLink(context),
                  const SizedBox(height: AppConstants.spacingXXL),
                  _buildRecentComparisons(context),
                  const SizedBox(height: AppConstants.spacingXXL),
                  _buildWhatCanICompareSection(),
                  const SizedBox(height: AppConstants.spacingL),
                  _buildDomainGrid(context),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.cardBg,
      title: Text(
        AppConstants.appName,
        style: AppTypography.h4(color: AppColors.primaryGreen),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.history),
          onPressed: () async {
            await feedbackService.tap();
            if (context.mounted) context.push(RouteNames.history);
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () async {
            await feedbackService.tap();
            if (context.mounted) context.push(RouteNames.settings);
          },
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back! 👋',
          style: AppTypography.h2(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          'Upload your document to get started with intelligent comparisons',
          style: AppTypography.body(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildMainUploadButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            await feedbackService.tap();
            if (context.mounted) context.push(RouteNames.upload);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.textWhite.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.upload_file,
                    color: AppColors.textWhite,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload Your Document/Data',
                        style: AppTypography.h4(color: AppColors.textWhite),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'PDF, Word, Image, or Text file',
                        style: AppTypography.small(
                          color: AppColors.textWhite.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textWhite,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasteTextLink(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: () async {
          await feedbackService.tap();
          if (context.mounted) context.push(RouteNames.upload);
        },
        icon: const Icon(Icons.text_fields, size: 18),
        label: Text(
          'Or paste text instead',
          style: AppTypography.button(color: AppColors.detailBlue),
        ),
      ),
    );
  }

  Widget _buildRecentComparisons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Comparisons',
              style: AppTypography.h4(color: AppColors.textPrimary),
            ),
            TextButton(
              onPressed: () async {
                await feedbackService.tap();
                if (context.mounted) context.push(RouteNames.history);
              },
              child: Text(
                'View All',
                style: AppTypography.button(color: AppColors.primaryGreen),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildRecentComparisonCard(
          icon: '💼',
          title: 'Software Engineer Job Match',
          subtitle: '8 comparisons • 2 hours ago',
          score: 78,
        ),
        const SizedBox(height: 8),
        _buildRecentComparisonCard(
          icon: '💻',
          title: 'Laptop Comparison',
          subtitle: '5 comparisons • Yesterday',
          score: 85,
        ),
      ],
    );
  }

  Widget _buildRecentComparisonCard({
    required String icon,
    required String title,
    required String subtitle,
    required int score,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.neutralGray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium(color: AppColors.textPrimary)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.small(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.getScoreBackgroundColor(score.toDouble()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$score%',
              style: AppTypography.bodyMedium(
                color: AppColors.getScoreColor(score.toDouble()),
              ).copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatCanICompareSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What can I compare?',
          style: AppTypography.h4(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose from popular comparison types or create your own',
          style: AppTypography.body(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildDomainGrid(BuildContext context) {
    final domains = [
      DomainType.job,
      DomainType.marriage,
      DomainType.product,
      DomainType.realEstate,
      DomainType.education,
      DomainType.custom,
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.05,
      ),
      itemCount: domains.length,
      itemBuilder: (context, index) {
        final domain = domains[index];
        return _buildDomainCard(
          context: context,
          icon: domain.icon,
          title: domain.displayName,
          description: domain.description,
          onTap: () async {
            await feedbackService.tap();
            if (context.mounted) context.push(RouteNames.upload);
          },
        );
      },
    );
  }

  Widget _buildDomainCard({
    required BuildContext context,
    required String icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  icon,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    title,
                    style:
                        AppTypography.bodyMedium(color: AppColors.textPrimary)
                            .copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    description,
                    style:
                        AppTypography.caption(color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
