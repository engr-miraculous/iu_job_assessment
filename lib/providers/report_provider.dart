import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iu_job_assessment/models/report_model.dart';
import 'package:iu_job_assessment/services/report_service.dart';

/// Provider for managing reports state with pagination and persistence
final reportsProvider = StateNotifierProvider<ReportsNotifier, ReportsState>(
  (ref) => ReportsNotifier(),
);

/// StateNotifier for managing reports with pagination and persistence
class ReportsNotifier extends StateNotifier<ReportsState> {
  ReportsNotifier() : super(const ReportsState.initial());

  static const int _pageSize = 10;

  /// Load initial reports (persisted + first page of mock reports)
  Future<void> loadInitialReports() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate API delay

      // Get persisted reports first
      final persistedReports = await ReportService.getPersistedReports();

      // Generate first page of mock reports
      final mockReports = ReportService.generateMockReports(0, _pageSize);

      // Combine reports with persisted ones at the top
      final allReports = [...persistedReports, ...mockReports];

      // Calculate total reports count
      final totalReports = await ReportService.getTotalReportsCount();

      state = state.copyWith(
        reports: allReports,
        isLoading: false,
        currentPage: 1,
        hasMore: allReports.length < totalReports,
        totalReports: totalReports,
        persistedCount: persistedReports.length,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load reports: $e',
      );
    }
  }

  /// Load more reports (pagination for mock reports only)
  Future<void> loadMoreReports() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    try {
      await Future.delayed(
        const Duration(milliseconds: 800),
      ); // Simulate API delay

      // Calculate the amount of mock reports that have been loaded
      final currentMockReportsCount =
          state.reports.length - state.persistedCount;
      final startIndex = currentMockReportsCount;

      final newMockReports = ReportService.generateMockReports(
        startIndex,
        _pageSize,
      );

      // Add new mock reports to existing reports
      final allReports = [...state.reports, ...newMockReports];

      state = state.copyWith(
        reports: allReports,
        isLoading: false,
        currentPage: state.currentPage + 1,
        hasMore: allReports.length < state.totalReports,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load more reports: $e',
      );
    }
  }

  /// Refresh reports (reload persisted + reset mock reports)
  Future<void> refreshReports() async {
    state = const ReportsState.initial();
    await loadInitialReports();
  }

  /// Add report from form (saves to persistent storage)
  Future<void> addReportFromForm(Report report) async {
    try {
      // Save to persistent storage
      await ReportService.saveUserReport(report);

      // Add to beginning of list (before mock reports)
      final updatedReports = [report, ...state.reports];

      // Update state with new totals
      final newTotalReports = state.totalReports + 1;
      final newPersistedCount = state.persistedCount + 1;

      state = state.copyWith(
        reports: updatedReports,
        totalReports: newTotalReports,
        persistedCount: newPersistedCount,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to save report: $e');
    }
  }

  /// Delete a user-created report
  Future<void> deleteReport(String reportId) async {
    try {
      if (await ReportService.isUserCreatedReport(reportId)) {
        await ReportService.deleteUserReport(reportId);

        // Remove from state
        final updatedReports = state.reports
            .where((r) => r.id != reportId)
            .toList();
        final newTotalReports = state.totalReports - 1;
        final newPersistedCount = state.persistedCount - 1;

        state = state.copyWith(
          reports: updatedReports,
          totalReports: newTotalReports,
          persistedCount: newPersistedCount,
        );
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete report: $e');
    }
  }

  /// Clear all user reports
  Future<void> clearAllUserReports() async {
    try {
      await ReportService.clearAllUserReports();

      // Remove only user reports from state, keep mock reports
      final mockReports = state.reports
          .where((r) => !ReportService.isUserCreatedReportSync(r.id))
          .toList();
      final newTotalReports = state.totalReports - state.persistedCount;

      state = state.copyWith(
        reports: mockReports,
        totalReports: newTotalReports,
        persistedCount: 0,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to clear user reports: $e');
    }
  }

  /// Search reports
  Future<void> searchReports(String query) async {
    if (query.trim().isEmpty) {
      await refreshReports();
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final searchResults = await ReportService.searchReports(
        query,
        mockReports: state.reports
            .where((r) => !ReportService.isUserCreatedReportSync(r.id))
            .toList(),
      );

      state = state.copyWith(
        reports: searchResults,
        isLoading: false,
        hasMore: false, // No pagination for search results
        currentPage: 1,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to search reports: $e',
      );
    }
  }
}

/// Provider for getting total reports count (including persisted and potential mock)
final totalReportsProvider = Provider<int>((ref) {
  final reportsState = ref.watch(reportsProvider);
  return reportsState.totalReports;
});

/// Provider for getting actual loaded reports count
final loadedReportsProvider = Provider<int>((ref) {
  final reportsState = ref.watch(reportsProvider);
  return reportsState.reports.length;
});

/// Provider for checking if reports list is empty
final isReportsEmptyProvider = Provider<bool>((ref) {
  final reportsState = ref.watch(reportsProvider);
  return reportsState.reports.isEmpty && !reportsState.isLoading;
});

/// Provider for getting persisted reports count
final persistedReportsProvider = Provider<int>((ref) {
  final reportsState = ref.watch(reportsProvider);
  return reportsState.persistedCount;
});

/// Provider for checking if there are any persisted reports
final hasPersistedReportsProvider = Provider<bool>((ref) {
  final reportsState = ref.watch(reportsProvider);
  return reportsState.persistedCount > 0;
});

/// Provider for search functionality
final searchQueryProvider = StateProvider<String>((ref) => '');
