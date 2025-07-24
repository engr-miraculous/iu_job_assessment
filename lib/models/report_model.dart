/// Data model for Report entity
class Report {
  final String id;
  final String type;
  final String location;
  final String status;
  final String referenceNumber;
  final DateTime createdAt;

  const Report({
    required this.id,
    required this.type,
    required this.location,
    required this.status,
    required this.referenceNumber,
    required this.createdAt,
  });

  /// Create Report from JSON (might not be useful since we're not
  ///  integrating API)
  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as String,
      type: json['type'] as String,
      location: json['location'] as String,
      status: json['status'] as String,
      referenceNumber: json['referenceNumber'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convert Report to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'location': location,
      'status': status,
      'referenceNumber': referenceNumber,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create copy with updated fields
  Report copyWith({
    String? id,
    String? type,
    String? location,
    String? status,
    String? referenceNumber,
    DateTime? createdAt,
  }) {
    return Report(
      id: id ?? this.id,
      type: type ?? this.type,
      location: location ?? this.location,
      status: status ?? this.status,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Report && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Report(id: $id, type: $type, location: $location, status: $status)';
  }
}

/// State class for paginated reports
class ReportsState {
  final List<Report> reports;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final int currentPage;

  const ReportsState({
    required this.reports,
    required this.isLoading,
    required this.hasMore,
    this.error,
    required this.currentPage,
  });

  /// Initial state
  const ReportsState.initial()
    : reports = const [],
      isLoading = false,
      hasMore = true,
      error = null,
      currentPage = 0;

  /// Loading state
  ReportsState copyWith({
    List<Report>? reports,
    bool? isLoading,
    bool? hasMore,
    String? error,
    int? currentPage,
  }) {
    return ReportsState(
      reports: reports ?? this.reports,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  String toString() {
    return 'ReportsState(reports: ${reports.length}, isLoading: $isLoading, hasMore: $hasMore, currentPage: $currentPage)';
  }
}

/// Model classes for report Categories
class ReportCategory {
  final String id;
  final String name;
  final String iconPath;
  final bool requiresDescription;

  const ReportCategory({
    required this.id,
    required this.name,
    required this.iconPath,
    this.requiresDescription = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportCategory &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Available report categories
class ReportCategories {
  static const List<ReportCategory> categories = [
    ReportCategory(
      id: 'dumped_rubbish',
      name: 'Dumped\nRubbish',
      iconPath: 'assets/icons/dumped_rubbish.png',
    ),
    ReportCategory(
      id: 'graffiti_vandalism',
      name: 'Graffiti or\nVandalism',
      iconPath: 'assets/icons/graffiti.png',
    ),
    ReportCategory(
      id: 'pedestrian_hazard',
      name: 'Pedestrian\nHazard',
      iconPath: 'assets/icons/pedestrian.png',
    ),
    ReportCategory(
      id: 'traffic_hazard',
      name: 'Traffic\nHazard',
      iconPath: 'assets/icons/traffic.png',
    ),
    ReportCategory(
      id: 'other',
      name: 'Other',
      iconPath: 'assets/icons/other.png',
      requiresDescription: true,
    ),
  ];

  static ReportCategory? findById(String id) {
    try {
      return categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }
}

/// Report form data model
class ReportFormData {
  final ReportCategory? category;
  final String location;
  final String description;
  final List<String> photos;

  const ReportFormData({
    this.category,
    this.location = '',
    this.description = '',
    this.photos = const [],
  });

  ReportFormData copyWith({
    ReportCategory? category,
    String? location,
    String? description,
    List<String>? photos,
  }) {
    return ReportFormData(
      category: category ?? this.category,
      location: location ?? this.location,
      description: description ?? this.description,
      photos: photos ?? this.photos,
    );
  }

  /// Check if the form is valid for submission
  bool get isValid {
    if (category == null ||
        location.trim().isEmpty ||
        description.trim().isEmpty) {
      return false;
    }

    // If "Other" category is selected, ensure description provides details
    if (category!.requiresDescription && description.trim().length < 10) {
      return false;
    }

    return true;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportFormData &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          location == other.location &&
          description == other.description &&
          photos.length == other.photos.length;

  @override
  int get hashCode => Object.hash(category, location, description, photos);
}
