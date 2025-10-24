import '../constants/domain_types.dart';

class DetectionResult {
  final ContentType contentType;
  final double confidence;
  final Map<String, dynamic> extractedFields;
  final List<String> keywords;

  DetectionResult({
    required this.contentType,
    required this.confidence,
    required this.extractedFields,
    required this.keywords,
  });
}

class ContentDetector {
  /// Detects content type from text or file
  Future<DetectionResult> detectContentType(String content) async {
    // Simulate AI processing
    await Future.delayed(const Duration(milliseconds: 800));

    final lowerContent = content.toLowerCase();

    // Resume/CV Detection
    if (_isResume(lowerContent)) {
      return DetectionResult(
        contentType: ContentType.resume,
        confidence: 0.92,
        extractedFields: _extractResumeFields(content),
        keywords: ['resume', 'cv', 'experience', 'skills', 'education'],
      );
    }

    // Job Description Detection
    if (_isJobDescription(lowerContent)) {
      return DetectionResult(
        contentType: ContentType.jobDescription,
        confidence: 0.89,
        extractedFields: _extractJobFields(content),
        keywords: ['job', 'position', 'requirements', 'responsibilities'],
      );
    }

    // Biodata Detection
    if (_isBiodata(lowerContent)) {
      return DetectionResult(
        contentType: ContentType.biodata,
        confidence: 0.91,
        extractedFields: _extractBiodataFields(content),
        keywords: ['biodata', 'marriage', 'family', 'partner'],
      );
    }

    // Product Spec Detection
    if (_isProductSpec(lowerContent)) {
      return DetectionResult(
        contentType: ContentType.productSpec,
        confidence: 0.87,
        extractedFields: _extractProductFields(content),
        keywords: ['product', 'specifications', 'features', 'price'],
      );
    }

    // Property Listing Detection
    if (_isPropertyListing(lowerContent)) {
      return DetectionResult(
        contentType: ContentType.propertyListing,
        confidence: 0.88,
        extractedFields: _extractPropertyFields(content),
        keywords: ['property', 'bedrooms', 'location', 'rent'],
      );
    }

    // Education Program Detection
    if (_isEducationProgram(lowerContent)) {
      return DetectionResult(
        contentType: ContentType.educationProgram,
        confidence: 0.86,
        extractedFields: _extractEducationFields(content),
        keywords: ['degree', 'university', 'course', 'program'],
      );
    }

    // Default: Unknown
    return DetectionResult(
      contentType: ContentType.unknown,
      confidence: 0.50,
      extractedFields: {},
      keywords: [],
    );
  }

  bool _isResume(String content) {
    final resumeIndicators = [
      'resume',
      'curriculum vitae',
      'cv',
      'work experience',
      'professional experience',
      'employment history',
      'technical skills',
      'education',
      'achievements',
      'objective',
      'summary',
    ];

    int matches = 0;
    for (final indicator in resumeIndicators) {
      if (content.contains(indicator)) matches++;
    }

    return matches >= 3;
  }

  bool _isJobDescription(String content) {
    final jobIndicators = [
      'job description',
      'job title',
      'position',
      'responsibilities',
      'requirements',
      'qualifications',
      'we are looking for',
      'seeking',
      'candidate',
      'apply',
    ];

    int matches = 0;
    for (final indicator in jobIndicators) {
      if (content.contains(indicator)) matches++;
    }

    return matches >= 3;
  }

  bool _isBiodata(String content) {
    final biodataIndicators = [
      'biodata',
      'matrimonial',
      'marriage',
      'groom',
      'bride',
      'family',
      'caste',
      'religion',
      'height',
      'complexion',
      'partner preferences',
    ];

    int matches = 0;
    for (final indicator in biodataIndicators) {
      if (content.contains(indicator)) matches++;
    }

    return matches >= 2;
  }

  bool _isProductSpec(String content) {
    final productIndicators = [
      'product',
      'specifications',
      'features',
      'price',
      'model',
      'brand',
      'warranty',
      'dimensions',
      'weight',
      'technical specs',
    ];

    int matches = 0;
    for (final indicator in productIndicators) {
      if (content.contains(indicator)) matches++;
    }

    return matches >= 3;
  }

  bool _isPropertyListing(String content) {
    final propertyIndicators = [
      'property',
      'apartment',
      'house',
      'flat',
      'bedroom',
      'bathroom',
      'sqft',
      'rent',
      'sale',
      'location',
      'amenities',
    ];

    int matches = 0;
    for (final indicator in propertyIndicators) {
      if (content.contains(indicator)) matches++;
    }

    return matches >= 3;
  }

  bool _isEducationProgram(String content) {
    final educationIndicators = [
      'university',
      'college',
      'degree',
      'bachelor',
      'master',
      'program',
      'course',
      'curriculum',
      'semester',
      'admission',
      'tuition',
    ];

    int matches = 0;
    for (final indicator in educationIndicators) {
      if (content.contains(indicator)) matches++;
    }

    return matches >= 3;
  }

  Map<String, dynamic> _extractResumeFields(String content) {
    // Mock extraction - in production, this would use NLP
    return {
      'name': _extractPattern(content, r'name[:\s]+([a-zA-Z\s]+)', 'John Doe'),
      'email': _extractPattern(
          content, r'[\w\.-]+@[\w\.-]+\.\w+', 'john@example.com'),
      'phone': _extractPattern(content, r'\d{10}', '1234567890'),
      'skills': ['Python', 'Flutter', 'React', 'Node.js', 'Docker'],
      'experience_years': 5,
      'education': 'Bachelor of Technology',
      'current_role': 'Software Engineer',
      'location': 'San Francisco, CA',
    };
  }

  Map<String, dynamic> _extractJobFields(String content) {
    return {
      'title': 'Software Engineer',
      'company': 'Google Inc.',
      'location': 'Mountain View, CA',
      'required_skills': [
        'Python',
        'JavaScript',
        'AWS',
        'Docker',
        'Kubernetes'
      ],
      'experience_required': {'min': 3, 'max': 7},
      'education_required': 'Bachelor\'s Degree',
      'salary_range': {'min': 120000, 'max': 180000},
      'job_type': 'Full-time',
    };
  }

  Map<String, dynamic> _extractBiodataFields(String content) {
    return {
      'name': 'Sample Name',
      'age': 28,
      'height': '5\'8"',
      'education': 'Bachelor\'s Degree',
      'occupation': 'Software Engineer',
      'family_type': 'Nuclear',
      'religion': 'Not specified',
      'location': 'Mumbai, India',
      'preferences': {
        'age_range': {'min': 25, 'max': 32},
        'education_level': 'Graduate',
        'occupation_type': 'Professional',
      },
    };
  }

  Map<String, dynamic> _extractProductFields(String content) {
    return {
      'title': 'MacBook Pro 14"',
      'brand': 'Apple',
      'price': 1999.99,
      'features': ['M2 Pro chip', '16GB RAM', '512GB SSD', 'Liquid Retina XDR'],
      'category': 'Laptop',
      'rating': 4.8,
      'warranty': '1 year',
    };
  }

  Map<String, dynamic> _extractPropertyFields(String content) {
    return {
      'title': '2 BHK Apartment',
      'location': 'Downtown',
      'bedrooms': 2,
      'bathrooms': 2,
      'area_sqft': 1200,
      'price': 2500,
      'type': 'Rent',
      'amenities': ['Parking', 'Gym', 'Swimming Pool'],
    };
  }

  Map<String, dynamic> _extractEducationFields(String content) {
    return {
      'title': 'Master of Computer Science',
      'university': 'Stanford University',
      'duration': '2 years',
      'tuition': 50000,
      'location': 'Stanford, CA',
      'specializations': ['AI', 'Machine Learning', 'Data Science'],
    };
  }

  String _extractPattern(String content, String pattern, String defaultValue) {
    final regex = RegExp(pattern, caseSensitive: false);
    final match = regex.firstMatch(content);
    return match != null ? match.group(1) ?? defaultValue : defaultValue;
  }
}
