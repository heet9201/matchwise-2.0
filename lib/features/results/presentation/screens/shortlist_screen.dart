import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/common_widgets/optimized_list_builder.dart';

// Data model for shortlist items
class ShortlistItemData {
  final String id;
  final String title;
  final int score;
  final String summary;

  ShortlistItemData({
    required this.id,
    required this.title,
    required this.score,
    required this.summary,
  });
}

class ShortlistScreen extends StatefulWidget {
  const ShortlistScreen({Key? key}) : super(key: key);

  @override
  State<ShortlistScreen> createState() => _ShortlistScreenState();
}

class _ShortlistScreenState extends State<ShortlistScreen> {
  // Mock data - Replace with actual data from state management
  final List<ShortlistItemData> _items = [
    ShortlistItemData(
      id: '1',
      title: 'Software Engineer - Google',
      score: 78,
      summary: 'Good match with some gaps. Strong technical fit.',
    ),
    ShortlistItemData(
      id: '2',
      title: 'Senior Developer - Microsoft',
      score: 85,
      summary: 'Excellent match! Aligns very well with your profile.',
    ),
    ShortlistItemData(
      id: '3',
      title: 'Full Stack Engineer - Amazon',
      score: 72,
      summary: 'Good match. Consider your priorities carefully.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralGray,
      appBar: AppBar(
        title: const Text('Your Shortlist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share functionality
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'sort_score',
                child: Text('Sort by Score'),
              ),
              const PopupMenuItem(
                value: 'sort_recent',
                child: Text('Sort by Recently Added'),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Text('Export All as PDF'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              'Items you selected',
              style: AppTypography.body(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: OptimizedListBuilder(
              itemCount: _items.length,
              padding: const EdgeInsets.all(16),
              keyBuilder: (index) => 'shortlist_${_items[index].id}',
              itemBuilder: (context, index) {
                final item = _items[index];
                return _buildShortlistItem(
                  title: item.title,
                  score: item.score,
                  summary: item.summary,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.add),
        label: const Text('New Comparison'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  Widget _buildShortlistItem({
    required String title,
    required int score,
    required String summary,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.bodyMedium(color: AppColors.textPrimary)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          const SizedBox(height: 8),
          Text(
            summary,
            style: AppTypography.small(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('View Details'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Remove'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
