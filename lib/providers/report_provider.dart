import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iu_job_assessment/models/report_model.dart';

/// Provider for managing reports state with pagination
final reportsProvider = StateNotifierProvider<ReportsNotifier, ReportsState>(
  (ref) => ReportsNotifier(),
);

/// StateNotifier for managing reports with pagination
class ReportsNotifier extends StateNotifier<ReportsState> {
  ReportsNotifier() : super(const ReportsState.initial());

  static const int _pageSize = 10;
  static const int _totalReports = 123; // Simulated total

  /// Load initial reports
  Future<void> loadInitialReports() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate API delay
      final reports = _generateMockReports(0, _pageSize);

      state = state.copyWith(
        reports: reports,
        isLoading: false,
        currentPage: 1,
        hasMore: reports.length == _pageSize && reports.length < _totalReports,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load reports: $e',
      );
    }
  }

  /// Load more reports (pagination)
  Future<void> loadMoreReports() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    try {
      await Future.delayed(
        const Duration(milliseconds: 800),
      ); // Simulate API delay

      final startIndex = state.currentPage * _pageSize;
      final newReports = _generateMockReports(startIndex, _pageSize);

      final allReports = [...state.reports, ...newReports];

      state = state.copyWith(
        reports: allReports,
        isLoading: false,
        currentPage: state.currentPage + 1,
        hasMore: allReports.length < _totalReports,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load more reports: $e',
      );
    }
  }

  /// Refresh reports (pull to refresh)
  Future<void> refreshReports() async {
    state = const ReportsState.initial();
    await loadInitialReports();
  }

  /// Add new report (for the _buildAddReportButton)
  Future<void> addReport({
    required String type,
    required String location,
  }) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      final newReport = Report(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: type,
        location: location,
        status: 'Pending',
        referenceNumber: 'REF${Random().nextInt(10000)}',
        createdAt: DateTime.now(),
      );

      // Add to beginning of list
      final updatedReports = [newReport, ...state.reports];

      state = state.copyWith(reports: updatedReports);
    } catch (e) {
      state = state.copyWith(error: 'Failed to add report: $e');
    }
  }

  void addReportFromForm(Report report) {
    final updatedReports = [report, ...state.reports];
    state = state.copyWith(reports: updatedReports);
  }

  /// Generate mock reports for simulation
  List<Report> _generateMockReports(int startIndex, int count) {
    final List<String> reportTypes = [
      'Incident Report',
      'Maintenance Request',
      'Safety Inspection',
      'Equipment Check',
      'Environmental Report',
      'Security Report',
    ];

    final List<String> locations = [
      'Building A - Floor 1',
      'Building B - Floor 2',
      'Parking Lot C',
      'Main Entrance',
      'Cafeteria',
      'Server Room',
      'Conference Room 301',
      'Storage Area',
      'Reception',
      'Loading Dock',
    ];

    final List<String> statuses = [
      'Pending',
      'In Progress',
      'Completed',
      'Cancelled',
    ];
    final random = Random();

    return List.generate(count, (index) {
      final actualIndex = startIndex + index;
      if (actualIndex >= _totalReports) return null;

      final createdAt = DateTime.now().subtract(
        Duration(days: random.nextInt(30), hours: random.nextInt(24)),
      );

      return Report(
        id: 'report_${actualIndex + 1}',
        type: reportTypes[random.nextInt(reportTypes.length)],
        location: locations[random.nextInt(locations.length)],
        status: statuses[random.nextInt(statuses.length)],
        referenceNumber: 'REF${1000 + actualIndex}',
        createdAt: createdAt,
      );
    }).whereType<Report>().toList();
  }
}

/// Provider for getting total reports count
final totalReportsProvider = Provider<int>((ref) {
  return 123; // Could be dynamic based on API response
});

/// Provider for checking if reports list is empty
final isReportsEmptyProvider = Provider<bool>((ref) {
  final reportsState = ref.watch(reportsProvider);
  return reportsState.reports.isEmpty && !reportsState.isLoading;
});
