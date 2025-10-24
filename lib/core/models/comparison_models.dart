import 'package:equatable/equatable.dart';

enum ImportanceLevel { high, medium, low }

enum Severity { critical, medium, low }

class MatchingFactor extends Equatable {
  final String factor;
  final double score;
  final String explanation;
  final ImportanceLevel importance;
  final String? userValue;
  final String? requiredValue;

  const MatchingFactor({
    required this.factor,
    required this.score,
    required this.explanation,
    required this.importance,
    this.userValue,
    this.requiredValue,
  });

  @override
  List<Object?> get props => [
        factor,
        score,
        explanation,
        importance,
        userValue,
        requiredValue,
      ];

  Map<String, dynamic> toJson() => {
        'factor': factor,
        'score': score,
        'explanation': explanation,
        'importance': importance.name,
        'userValue': userValue,
        'requiredValue': requiredValue,
      };

  factory MatchingFactor.fromJson(Map<String, dynamic> json) => MatchingFactor(
        factor: json['factor'] as String,
        score: (json['score'] as num).toDouble(),
        explanation: json['explanation'] as String,
        importance: ImportanceLevel.values.firstWhere(
          (e) => e.name == json['importance'],
          orElse: () => ImportanceLevel.medium,
        ),
        userValue: json['userValue'] as String?,
        requiredValue: json['requiredValue'] as String?,
      );
}

class MismatchingFactor extends Equatable {
  final String factor;
  final String gap;
  final Severity severity;
  final String recommendation;
  final String? userValue;
  final String? requiredValue;

  const MismatchingFactor({
    required this.factor,
    required this.gap,
    required this.severity,
    required this.recommendation,
    this.userValue,
    this.requiredValue,
  });

  @override
  List<Object?> get props => [
        factor,
        gap,
        severity,
        recommendation,
        userValue,
        requiredValue,
      ];

  Map<String, dynamic> toJson() => {
        'factor': factor,
        'gap': gap,
        'severity': severity.name,
        'recommendation': recommendation,
        'userValue': userValue,
        'requiredValue': requiredValue,
      };

  factory MismatchingFactor.fromJson(Map<String, dynamic> json) =>
      MismatchingFactor(
        factor: json['factor'] as String,
        gap: json['gap'] as String,
        severity: Severity.values.firstWhere(
          (e) => e.name == json['severity'],
          orElse: () => Severity.medium,
        ),
        recommendation: json['recommendation'] as String,
        userValue: json['userValue'] as String?,
        requiredValue: json['requiredValue'] as String?,
      );
}

class AIRecommendation extends Equatable {
  final String summary;
  final List<String> pros;
  final List<String> cons;
  final String decision;
  final List<String> alternatives;

  const AIRecommendation({
    required this.summary,
    required this.pros,
    required this.cons,
    required this.decision,
    required this.alternatives,
  });

  @override
  List<Object?> get props => [summary, pros, cons, decision, alternatives];

  Map<String, dynamic> toJson() => {
        'summary': summary,
        'pros': pros,
        'cons': cons,
        'decision': decision,
        'alternatives': alternatives,
      };

  factory AIRecommendation.fromJson(Map<String, dynamic> json) =>
      AIRecommendation(
        summary: json['summary'] as String,
        pros: List<String>.from(json['pros'] as List),
        cons: List<String>.from(json['cons'] as List),
        decision: json['decision'] as String,
        alternatives: List<String>.from(json['alternatives'] as List),
      );
}

class ComparisonResult extends Equatable {
  final String id;
  final String itemId;
  final String itemTitle;
  final double overallScore;
  final List<MatchingFactor> matchingFactors;
  final List<MismatchingFactor> mismatchingFactors;
  final AIRecommendation aiRecommendation;
  final double confidence;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const ComparisonResult({
    required this.id,
    required this.itemId,
    required this.itemTitle,
    required this.overallScore,
    required this.matchingFactors,
    required this.mismatchingFactors,
    required this.aiRecommendation,
    required this.confidence,
    required this.timestamp,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        itemId,
        itemTitle,
        overallScore,
        matchingFactors,
        mismatchingFactors,
        aiRecommendation,
        confidence,
        timestamp,
        metadata,
      ];

  Map<String, dynamic> toJson() => {
        'id': id,
        'itemId': itemId,
        'itemTitle': itemTitle,
        'overallScore': overallScore,
        'matchingFactors': matchingFactors.map((f) => f.toJson()).toList(),
        'mismatchingFactors':
            mismatchingFactors.map((f) => f.toJson()).toList(),
        'aiRecommendation': aiRecommendation.toJson(),
        'confidence': confidence,
        'timestamp': timestamp.toIso8601String(),
        'metadata': metadata,
      };

  factory ComparisonResult.fromJson(Map<String, dynamic> json) =>
      ComparisonResult(
        id: json['id'] as String,
        itemId: json['itemId'] as String,
        itemTitle: json['itemTitle'] as String,
        overallScore: (json['overallScore'] as num).toDouble(),
        matchingFactors: (json['matchingFactors'] as List)
            .map((f) => MatchingFactor.fromJson(f as Map<String, dynamic>))
            .toList(),
        mismatchingFactors: (json['mismatchingFactors'] as List)
            .map((f) => MismatchingFactor.fromJson(f as Map<String, dynamic>))
            .toList(),
        aiRecommendation: AIRecommendation.fromJson(
            json['aiRecommendation'] as Map<String, dynamic>),
        confidence: (json['confidence'] as num).toDouble(),
        timestamp: DateTime.parse(json['timestamp'] as String),
        metadata: json['metadata'] as Map<String, dynamic>?,
      );
}
