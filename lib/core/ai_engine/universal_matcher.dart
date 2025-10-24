import 'package:uuid/uuid.dart';
import '../models/comparison_models.dart';
import '../constants/domain_types.dart';

class UniversalMatcher {
  final Uuid _uuid = const Uuid();

  /// Universal matching algorithm that works for ANY domain
  Future<ComparisonResult> compare({
    required Map<String, dynamic> userProfile,
    required Map<String, dynamic> comparisonItem,
    required DomainType domainType,
    required Map<String, double> weights,
  }) async {
    // Simulate processing delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Step 1: Calculate match score per criterion
    final Map<String, double> scores = {};
    for (final entry in weights.entries) {
      final criterion = entry.key;
      final weight = entry.value;

      final userVal = userProfile[criterion];
      final itemVal = comparisonItem[criterion];

      final matchScore = _calculateSimilarity(userVal, itemVal, criterion);
      scores[criterion] = matchScore * weight;
    }

    // Step 2: Identify matching factors
    final matchingFactors = <MatchingFactor>[];
    for (final entry in scores.entries) {
      if (entry.value >= 0.70) {
        matchingFactors.add(
          MatchingFactor(
            factor: _formatCriterionName(entry.key),
            score: entry.value,
            explanation: _generateMatchExplanation(
              entry.key,
              userProfile[entry.key],
              comparisonItem[entry.key],
            ),
            importance: _determineImportance(weights[entry.key] ?? 0.0),
            userValue: _formatValue(userProfile[entry.key]),
            requiredValue: _formatValue(comparisonItem[entry.key]),
          ),
        );
      }
    }

    // Step 3: Identify non-matching factors
    final mismatchingFactors = <MismatchingFactor>[];
    for (final entry in scores.entries) {
      if (entry.value < 0.70) {
        mismatchingFactors.add(
          MismatchingFactor(
            factor: _formatCriterionName(entry.key),
            gap: _describeGap(
              entry.key,
              userProfile[entry.key],
              comparisonItem[entry.key],
            ),
            severity: _determineSeverity(entry.value),
            recommendation: _generateRecommendation(
              entry.key,
              userProfile[entry.key],
              comparisonItem[entry.key],
            ),
            userValue: _formatValue(userProfile[entry.key]),
            requiredValue: _formatValue(comparisonItem[entry.key]),
          ),
        );
      }
    }

    // Step 4: Calculate overall score
    final overallScore = scores.values.isEmpty
        ? 0.0
        : scores.values.reduce((a, b) => a + b) / weights.length * 100;

    // Step 5: Generate AI recommendation
    final aiRec = _generateAIRecommendation(
      overallScore,
      matchingFactors,
      mismatchingFactors,
      domainType,
    );

    // Step 6: Calculate confidence
    final confidence = _calculateConfidence(
      matchingFactors.length,
      mismatchingFactors.length,
      overallScore,
    );

    return ComparisonResult(
      id: _uuid.v4(),
      itemId: comparisonItem['id']?.toString() ?? _uuid.v4(),
      itemTitle: comparisonItem['title']?.toString() ?? 'Untitled',
      overallScore: overallScore,
      matchingFactors: matchingFactors,
      mismatchingFactors: mismatchingFactors,
      aiRecommendation: aiRec,
      confidence: confidence,
      timestamp: DateTime.now(),
      metadata: {
        'domainType': domainType.name,
        'criteriaCount': weights.length,
      },
    );
  }

  double _calculateSimilarity(
      dynamic userVal, dynamic itemVal, String criterion) {
    if (userVal == null || itemVal == null) return 0.0;

    // List comparison (skills, features, etc.)
    if (userVal is List && itemVal is List) {
      return _calculateListSimilarity(userVal, itemVal);
    }

    // Numeric comparison (experience, salary, age, etc.)
    if (userVal is num && itemVal is num) {
      return _calculateNumericSimilarity(
          userVal.toDouble(), itemVal.toDouble());
    }

    // Range comparison
    if (itemVal is Map &&
        itemVal.containsKey('min') &&
        itemVal.containsKey('max')) {
      final value = userVal is num ? userVal.toDouble() : 0.0;
      return _calculateRangeSimilarity(value, itemVal['min'], itemVal['max']);
    }

    // String comparison (exact or fuzzy)
    if (userVal is String && itemVal is String) {
      return _calculateStringSimilarity(userVal, itemVal);
    }

    // Default: exact match
    return userVal == itemVal ? 1.0 : 0.0;
  }

  double _calculateListSimilarity(List userList, List itemList) {
    if (itemList.isEmpty) return 1.0;

    final userSet = userList.map((e) => e.toString().toLowerCase()).toSet();
    final itemSet = itemList.map((e) => e.toString().toLowerCase()).toSet();

    final intersection = userSet.intersection(itemSet).length;
    return intersection / itemSet.length;
  }

  double _calculateNumericSimilarity(double userVal, double itemVal) {
    if (itemVal == 0) return userVal == 0 ? 1.0 : 0.0;
    final diff = (userVal - itemVal).abs();
    final avgVal = (userVal + itemVal) / 2;
    return (1 - (diff / avgVal)).clamp(0.0, 1.0);
  }

  double _calculateRangeSimilarity(double value, dynamic min, dynamic max) {
    final minVal = (min as num).toDouble();
    final maxVal = (max as num).toDouble();

    if (value >= minVal && value <= maxVal) return 1.0;
    if (value < minVal) {
      final diff = minVal - value;
      return (1 - (diff / minVal)).clamp(0.0, 1.0);
    }
    final diff = value - maxVal;
    return (1 - (diff / maxVal)).clamp(0.0, 1.0);
  }

  double _calculateStringSimilarity(String userVal, String itemVal) {
    final user = userVal.toLowerCase().trim();
    final item = itemVal.toLowerCase().trim();

    if (user == item) return 1.0;
    if (user.contains(item) || item.contains(user)) return 0.8;

    // Simple Levenshtein approximation
    final maxLen = user.length > item.length ? user.length : item.length;
    if (maxLen == 0) return 1.0;

    int distance = 0;
    for (int i = 0; i < maxLen; i++) {
      if (i >= user.length || i >= item.length || user[i] != item[i]) {
        distance++;
      }
    }

    return (1 - distance / maxLen).clamp(0.0, 1.0);
  }

  ImportanceLevel _determineImportance(double weight) {
    if (weight >= 0.25) return ImportanceLevel.high;
    if (weight >= 0.15) return ImportanceLevel.medium;
    return ImportanceLevel.low;
  }

  Severity _determineSeverity(double score) {
    if (score < 0.30) return Severity.critical;
    if (score < 0.50) return Severity.medium;
    return Severity.low;
  }

  String _formatCriterionName(String criterion) {
    return criterion
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String? _formatValue(dynamic value) {
    if (value == null) return null;
    if (value is List) return value.join(', ');
    if (value is Map) return value.toString();
    return value.toString();
  }

  String _generateMatchExplanation(
      String criterion, dynamic userVal, dynamic itemVal) {
    if (userVal is List && itemVal is List) {
      final matches = (userVal.toSet().intersection(itemVal.toSet())).length;
      return 'Match: $matches/${itemVal.length} criteria met';
    }
    if (userVal is num && itemVal is num) {
      return 'Your value: $userVal, Required: $itemVal';
    }
    return 'Criteria satisfied';
  }

  String _describeGap(String criterion, dynamic userVal, dynamic itemVal) {
    if (userVal is List && itemVal is List) {
      final missing = itemVal.toSet().difference(userVal.toSet()).toList();
      return 'Missing: ${missing.take(3).join(", ")}${missing.length > 3 ? "..." : ""}';
    }
    if (userVal is num && itemVal is num) {
      final diff = (itemVal as num) - (userVal as num);
      return diff > 0 ? 'Need $diff more' : 'Exceeds by ${diff.abs()}';
    }
    return 'Does not match requirement';
  }

  String _generateRecommendation(
      String criterion, dynamic userVal, dynamic itemVal) {
    if (userVal is List && itemVal is List) {
      final missing =
          itemVal.toSet().difference(userVal.toSet()).take(2).toList();
      return 'Consider acquiring: ${missing.join(", ")}';
    }
    return 'Work on improving this criterion';
  }

  AIRecommendation _generateAIRecommendation(
    double overallScore,
    List<MatchingFactor> matching,
    List<MismatchingFactor> mismatching,
    DomainType domainType,
  ) {
    String summary;
    String decision;
    List<String> pros = [];
    List<String> cons = [];

    if (overallScore >= 75) {
      summary =
          'Excellent match! This option aligns very well with your profile.';
      decision = 'Strongly Recommended';
    } else if (overallScore >= 50) {
      summary =
          'Good match with some gaps. Consider your priorities carefully.';
      decision = 'Recommended with Considerations';
    } else {
      summary =
          'Limited match. Significant gaps exist that may require attention.';
      decision = 'Not Recommended';
    }

    // Generate pros from matching factors
    for (var match in matching.take(4)) {
      pros.add('${match.factor}: ${match.explanation}');
    }

    // Generate cons from mismatching factors
    for (var mismatch in mismatching.take(4)) {
      cons.add('${mismatch.factor}: ${mismatch.gap}');
    }

    return AIRecommendation(
      summary: summary,
      pros: pros,
      cons: cons,
      decision: decision,
      alternatives: _generateAlternatives(domainType),
    );
  }

  List<String> _generateAlternatives(DomainType domainType) {
    switch (domainType) {
      case DomainType.job:
        return [
          'Consider similar roles in related industries',
          'Look for positions with flexible requirements',
          'Explore companies with strong training programs',
        ];
      case DomainType.marriage:
        return [
          'Expand search criteria slightly',
          'Consider profiles from nearby locations',
          'Look for compatible values over exact matches',
        ];
      case DomainType.product:
        return [
          'Check alternative brands with similar features',
          'Consider refurbished or previous generation models',
          'Wait for seasonal sales or discounts',
        ];
      default:
        return [
          'Broaden your search criteria',
          'Consider compromise on less critical factors',
          'Seek expert advice for better matches',
        ];
    }
  }

  double _calculateConfidence(int matchCount, int mismatchCount, double score) {
    final totalFactors = matchCount + mismatchCount;
    if (totalFactors == 0) return 0.5;

    final factorConfidence = matchCount / totalFactors;
    final scoreConfidence = score / 100;

    return (factorConfidence * 0.6 + scoreConfidence * 0.4).clamp(0.0, 1.0);
  }
}
