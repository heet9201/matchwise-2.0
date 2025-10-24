import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/domain_types.dart';
import '../../../../core/ai_engine/content_detector.dart';
import '../../../../core/ai_engine/comparison_suggester.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/common_widgets/loading_widgets.dart';

class DetectionResultScreen extends StatefulWidget {
  final DetectionResult? detectedContent;

  const DetectionResultScreen({Key? key, this.detectedContent})
      : super(key: key);

  @override
  State<DetectionResultScreen> createState() => _DetectionResultScreenState();
}

class _DetectionResultScreenState extends State<DetectionResultScreen> {
  final ComparisonSuggester _suggester = ComparisonSuggester();
  ComparisonSuggestion? _suggestion;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSuggestion();
  }

  Future<void> _loadSuggestion() async {
    if (widget.detectedContent != null) {
      final suggestion = await _suggester.suggestComparison(
        widget.detectedContent!.contentType,
      );
      setState(() {
        _suggestion = suggestion;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _acceptSuggestion() {
    if (_suggestion != null && widget.detectedContent != null) {
      context.push(
        RouteNames.optionsUpload,
        extra: {
          'comparisonType': _suggestion!.primarySuggestion,
          'userProfile': widget.detectedContent!.extractedFields,
          'domainType': widget.detectedContent!.contentType.suggestedDomain,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: EnhancedLoadingIndicator(
          message: 'Analyzing content...',
          size: 120,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.neutralGray,
      appBar: AppBar(
        title: const Text('Detection Result'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'We Detected Your Document Type',
              style: AppTypography.h3(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingXL),
            _buildDetectionCard(),
            const SizedBox(height: AppConstants.spacingXL),
            if (_suggestion != null) ...[
              Text(
                'Suggested Comparison',
                style: AppTypography.h4(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppConstants.spacingL),
              _buildSuggestionCard(),
              const SizedBox(height: AppConstants.spacingXL),
              ElevatedButton(
                onPressed: _acceptSuggestion,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Use This Suggestion',
                      style:
                          AppTypography.buttonLarge(color: AppColors.textWhite),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacingM),
              OutlinedButton(
                onPressed: () => context.push(RouteNames.manualSelection),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Choose Manually',
                  style:
                      AppTypography.buttonLarge(color: AppColors.primaryGreen),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetectionCard() {
    if (widget.detectedContent == null) {
      return const SizedBox.shrink();
    }

    final detection = widget.detectedContent!;
    final confidencePercent = (detection.confidence * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryGreenOverlay,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _getIconForContentType(detection.contentType),
              size: 40,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 16),
          // Type name
          Text(
            detection.contentType.displayName,
            style: AppTypography.h3(color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Confidence badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.success),
            ),
            child: Text(
              '$confidencePercent% Confident',
              style: AppTypography.bodyMedium(color: AppColors.success)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 20),
          // Extracted fields
          if (detection.extractedFields.isNotEmpty) ...[
            const Divider(),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _buildFieldChips(detection.extractedFields),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestionCard() {
    if (_suggestion == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryGreen, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreenOverlay,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lightbulb,
                  color: AppColors.primaryGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Suggestion',
                      style: AppTypography.label(color: AppColors.primaryGreen),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Compare with ${_suggestion!.primarySuggestion.displayName}',
                      style: AppTypography.h5(color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _suggestion!.explanation,
            style: AppTypography.body(color: AppColors.textSecondary),
          ),
          if (_suggestion!.alternatives.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Or compare with:',
              style: AppTypography.small(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            ...(_suggestion!.alternatives.map((alt) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.arrow_right,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        alt.displayName,
                        style:
                            AppTypography.small(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ))),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildFieldChips(Map<String, dynamic> fields) {
    final chips = <Widget>[];

    for (final entry in fields.entries.take(6)) {
      final value = entry.value;
      String displayText;

      if (value is List) {
        displayText = value.take(3).join(', ');
      } else {
        displayText = value.toString();
      }

      if (displayText.length > 30) {
        displayText = '${displayText.substring(0, 27)}...';
      }

      chips.add(
        Chip(
          label: Text(displayText),
          backgroundColor: AppColors.primaryGreenOverlay,
          labelStyle: AppTypography.small(color: AppColors.primaryGreen),
        ),
      );
    }

    return chips;
  }

  IconData _getIconForContentType(ContentType type) {
    switch (type) {
      case ContentType.resume:
        return Icons.person;
      case ContentType.jobDescription:
        return Icons.work;
      case ContentType.biodata:
        return Icons.favorite;
      case ContentType.productSpec:
        return Icons.laptop;
      case ContentType.propertyListing:
        return Icons.home;
      case ContentType.educationProgram:
        return Icons.school;
      default:
        return Icons.description;
    }
  }
}
