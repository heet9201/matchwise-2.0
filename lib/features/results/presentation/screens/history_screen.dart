import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/common_widgets/optimized_list_builder.dart';

// Data model for history items
class HistoryItemData {
  final String id;
  final String icon;
  final String title;
  final String date;
  final int itemCount;
  final int topScore;

  HistoryItemData({
    required this.id,
    required this.icon,
    required this.title,
    required this.date,
    required this.itemCount,
    required this.topScore,
  });
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Mock data - Replace with actual data from state management
  final List<HistoryItemData> _items = [
    HistoryItemData(
      id: '1',
      icon: '💼',
      title: 'Software Engineer Job Match',
      date: '2 hours ago',
      itemCount: 8,
      topScore: 85,
    ),
    HistoryItemData(
      id: '2',
      icon: '💻',
      title: 'Laptop Comparison',
      date: 'Yesterday',
      itemCount: 5,
      topScore: 78,
    ),
    HistoryItemData(
      id: '3',
      icon: '🏠',
      title: 'Apartment Search',
      date: '2 days ago',
      itemCount: 12,
      topScore: 92,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralGray,
      appBar: AppBar(
        title: const Text('Comparison History'),
      ),
      body: OptimizedListBuilder(
        itemCount: _items.length,
        padding: const EdgeInsets.all(16),
        keyBuilder: (index) => 'history_${_items[index].id}',
        itemBuilder: (context, index) {
          final item = _items[index];
          return _buildHistoryItem(
            icon: item.icon,
            title: item.title,
            date: item.date,
            itemCount: item.itemCount,
            topScore: item.topScore,
          );
        },
      ),
    );
  }

  Widget _buildHistoryItem({
    required String icon,
    required String title,
    required String date,
    required int itemCount,
    required int topScore,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.neutralGray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 28)),
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
                  '$itemCount comparisons • $date',
                  style: AppTypography.small(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Top: ',
                      style:
                          AppTypography.small(color: AppColors.textSecondary),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.getScoreBackgroundColor(
                            topScore.toDouble()),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$topScore%',
                        style: AppTypography.caption(
                          color: AppColors.getScoreColor(topScore.toDouble()),
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
