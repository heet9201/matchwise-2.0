enum DomainType {
  job,
  marriage,
  product,
  realEstate,
  education,
  custom,
  unknown
}

extension DomainTypeExtension on DomainType {
  String get displayName {
    switch (this) {
      case DomainType.job:
        return 'Job Matching';
      case DomainType.marriage:
        return 'Marriage Biodata';
      case DomainType.product:
        return 'Product Comparison';
      case DomainType.realEstate:
        return 'Real Estate';
      case DomainType.education:
        return 'Education';
      case DomainType.custom:
        return 'Custom Domain';
      case DomainType.unknown:
        return 'Unknown';
    }
  }

  String get icon {
    switch (this) {
      case DomainType.job:
        return '💼';
      case DomainType.marriage:
        return '💍';
      case DomainType.product:
        return '💻';
      case DomainType.realEstate:
        return '🏠';
      case DomainType.education:
        return '🎓';
      case DomainType.custom:
        return '⭐';
      case DomainType.unknown:
        return '❓';
    }
  }

  String get description {
    switch (this) {
      case DomainType.job:
        return 'Compare resumes with job descriptions';
      case DomainType.marriage:
        return 'Find compatible biodata matches';
      case DomainType.product:
        return 'Compare products against your needs';
      case DomainType.realEstate:
        return 'Find your perfect property';
      case DomainType.education:
        return 'Choose the right educational program';
      case DomainType.custom:
        return 'Create your own comparison criteria';
      case DomainType.unknown:
        return 'Unknown comparison type';
    }
  }
}

enum ContentType {
  resume,
  jobDescription,
  biodata,
  productSpec,
  propertyListing,
  educationProgram,
  custom,
  unknown
}

extension ContentTypeExtension on ContentType {
  String get displayName {
    switch (this) {
      case ContentType.resume:
        return 'Resume/CV';
      case ContentType.jobDescription:
        return 'Job Description';
      case ContentType.biodata:
        return 'Biodata';
      case ContentType.productSpec:
        return 'Product Specification';
      case ContentType.propertyListing:
        return 'Property Listing';
      case ContentType.educationProgram:
        return 'Education Program';
      case ContentType.custom:
        return 'Custom Document';
      case ContentType.unknown:
        return 'Unknown';
    }
  }

  DomainType get suggestedDomain {
    switch (this) {
      case ContentType.resume:
        return DomainType.job;
      case ContentType.jobDescription:
        return DomainType.job;
      case ContentType.biodata:
        return DomainType.marriage;
      case ContentType.productSpec:
        return DomainType.product;
      case ContentType.propertyListing:
        return DomainType.realEstate;
      case ContentType.educationProgram:
        return DomainType.education;
      case ContentType.custom:
        return DomainType.custom;
      case ContentType.unknown:
        return DomainType.unknown;
    }
  }
}

enum ComparisonTarget {
  jobDescriptions,
  resumes,
  biodatas,
  products,
  properties,
  programs,
  custom
}

extension ComparisonTargetExtension on ComparisonTarget {
  String get displayName {
    switch (this) {
      case ComparisonTarget.jobDescriptions:
        return 'Job Descriptions';
      case ComparisonTarget.resumes:
        return 'Resumes';
      case ComparisonTarget.biodatas:
        return 'Biodatas';
      case ComparisonTarget.products:
        return 'Products';
      case ComparisonTarget.properties:
        return 'Properties';
      case ComparisonTarget.programs:
        return 'Educational Programs';
      case ComparisonTarget.custom:
        return 'Custom Items';
    }
  }

  String get icon {
    switch (this) {
      case ComparisonTarget.jobDescriptions:
        return '💼';
      case ComparisonTarget.resumes:
        return '📄';
      case ComparisonTarget.biodatas:
        return '💍';
      case ComparisonTarget.products:
        return '💻';
      case ComparisonTarget.properties:
        return '🏠';
      case ComparisonTarget.programs:
        return '🎓';
      case ComparisonTarget.custom:
        return '⭐';
    }
  }
}
