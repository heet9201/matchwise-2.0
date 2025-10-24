import '../constants/domain_types.dart';

class ComparisonSuggestion {
  final ComparisonTarget primarySuggestion;
  final List<ComparisonTarget> alternatives;
  final double confidence;
  final String explanation;

  ComparisonSuggestion({
    required this.primarySuggestion,
    required this.alternatives,
    required this.confidence,
    required this.explanation,
  });
}

class ComparisonSuggester {
  /// Suggests what to compare the detected content against
  Future<ComparisonSuggestion> suggestComparison(
      ContentType contentType) async {
    // Simulate AI processing
    await Future.delayed(const Duration(milliseconds: 500));

    switch (contentType) {
      case ContentType.resume:
        return ComparisonSuggestion(
          primarySuggestion: ComparisonTarget.jobDescriptions,
          alternatives: [
            ComparisonTarget.custom,
          ],
          confidence: 0.95,
          explanation:
              'Resumes are typically compared with job descriptions to find suitable positions.',
        );

      case ContentType.jobDescription:
        return ComparisonSuggestion(
          primarySuggestion: ComparisonTarget.resumes,
          alternatives: [
            ComparisonTarget.custom,
          ],
          confidence: 0.93,
          explanation:
              'Job descriptions are compared with candidate resumes to find the best fit.',
        );

      case ContentType.biodata:
        return ComparisonSuggestion(
          primarySuggestion: ComparisonTarget.biodatas,
          alternatives: [
            ComparisonTarget.custom,
          ],
          confidence: 0.94,
          explanation:
              'Biodata profiles are compared to find compatible marriage partners.',
        );

      case ContentType.productSpec:
        return ComparisonSuggestion(
          primarySuggestion: ComparisonTarget.products,
          alternatives: [
            ComparisonTarget.custom,
          ],
          confidence: 0.92,
          explanation:
              'Compare your product requirements with available products to find the best match.',
        );

      case ContentType.propertyListing:
        return ComparisonSuggestion(
          primarySuggestion: ComparisonTarget.properties,
          alternatives: [
            ComparisonTarget.custom,
          ],
          confidence: 0.91,
          explanation:
              'Compare your property preferences with available listings.',
        );

      case ContentType.educationProgram:
        return ComparisonSuggestion(
          primarySuggestion: ComparisonTarget.programs,
          alternatives: [
            ComparisonTarget.custom,
          ],
          confidence: 0.90,
          explanation:
              'Compare your educational goals with available programs.',
        );

      case ContentType.custom:
      case ContentType.unknown:
        return ComparisonSuggestion(
          primarySuggestion: ComparisonTarget.custom,
          alternatives: [],
          confidence: 0.50,
          explanation:
              'Please manually select what you want to compare this with.',
        );
    }
  }

  /// Get domain-specific comparison weights
  Map<String, double> getWeights(DomainType domainType) {
    switch (domainType) {
      case DomainType.job:
        return {
          'skills': 0.30,
          'experience': 0.25,
          'education': 0.15,
          'location': 0.10,
          'salary': 0.10,
          'other': 0.10,
        };

      case DomainType.marriage:
        return {
          'core_values': 0.25,
          'family': 0.20,
          'education': 0.15,
          'career': 0.15,
          'lifestyle': 0.15,
          'other': 0.10,
        };

      case DomainType.product:
        return {
          'must_have_features': 0.40,
          'budget': 0.25,
          'nice_to_have_features': 0.20,
          'brand': 0.10,
          'other': 0.05,
        };

      case DomainType.realEstate:
        return {
          'location': 0.30,
          'budget': 0.25,
          'size': 0.20,
          'amenities': 0.15,
          'other': 0.10,
        };

      case DomainType.education:
        return {
          'program_fit': 0.30,
          'reputation': 0.25,
          'cost': 0.20,
          'location': 0.15,
          'other': 0.10,
        };

      case DomainType.custom:
      case DomainType.unknown:
        return {
          'criterion_1': 0.25,
          'criterion_2': 0.25,
          'criterion_3': 0.25,
          'criterion_4': 0.25,
        };
    }
  }
}
