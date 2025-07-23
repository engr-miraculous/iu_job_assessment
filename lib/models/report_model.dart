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
