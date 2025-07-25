// services/report_service.dart
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:iu_job_assessment/models/report_model.dart';
import 'package:iu_job_assessment/models/media_models.dart';
import 'package:iu_job_assessment/services/database_service.dart';

/// Service for handling report-related business logic
class ReportService {
  static const int _totalMockReports = 123;

  /// Save a user-created report to persistent storage
  static Future<void> saveUserReport(Report report) async {
    await DatabaseService.saveReport(report);
  }

  /// Get all persisted user reports sorted by creation date (newest first)
  static Future<List<Report>> getPersistedReports() async {
    return await DatabaseService.getPersistedReports();
  }

  /// Get total reports count (persisted + mock)
  static Future<int> getTotalReportsCount() async {
    final persistedCount = await DatabaseService.getPersistedReportsCount();
    return persistedCount + _totalMockReports;
  }

  /// Get persisted reports count
  static Future<int> getPersistedReportsCount() async {
    return await DatabaseService.getPersistedReportsCount();
  }

  /// Check if report is user-created (persisted)
  static Future<bool> isUserCreatedReport(String reportId) async {
    // User reports typically have a specific prefix or pattern
    if (reportId.startsWith('user_') || reportId.startsWith('form_')) {
      return await DatabaseService.reportExists(reportId);
    }
    return false;
  }

  /// Check if report exists in database (synchronous version for quick checks)
  static bool isUserCreatedReportSync(String reportId) {
    return reportId.startsWith('user_') || reportId.startsWith('form_');
  }

  /// Generate mock reports for simulation
  static List<Report> generateMockReports(int startIndex, int count) {
    final List<String> reportTypes = ReportCategories.categories
        .map((category) => category.name.replaceAll('\n', ' '))
        .toList();

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
      'Submitted',
      'Verified',
      'Completed',
      'Rejected',
      'Pending',
    ];

    final random = Random();

    return List.generate(count, (index) {
      final actualIndex = startIndex + index;
      if (actualIndex >= _totalMockReports) return null;

      final createdAt = DateTime.now().subtract(
        Duration(days: random.nextInt(30), hours: random.nextInt(24)),
      );

      return Report(
        id: 'mock_report_${actualIndex + 1}',
        type: reportTypes[random.nextInt(reportTypes.length)],
        location: locations[random.nextInt(locations.length)],
        status: statuses[random.nextInt(statuses.length)],
        referenceNumber: 'REF${1000 + actualIndex}',
        description:
            "Lorem ipsum dolor sit amet consectetur adipisicing elit. Quisquam, doloremque.",
        media: [
          MediaItem(
            path: 'assets/Splash.png',
            type: MediaType.image,
            coordinates: '37.7749,-122.4194',
            createdAt: createdAt,
            originalPath: 'assets/Splash.png',
          ),
        ],
        createdAt: createdAt,
      );
    }).whereType<Report>().toList();
  }

  /// Delete a user report
  static Future<void> deleteUserReport(String reportId) async {
    if (await isUserCreatedReport(reportId)) {
      await DatabaseService.deleteReport(reportId);
    }
  }

  /// Clear all user reports
  static Future<void> clearAllUserReports() async {
    await DatabaseService.clearAllReports();
  }

  /// Search reports (both persisted and mock)
  static Future<List<Report>> searchReports(
    String query, {
    List<Report>? mockReports,
  }) async {
    final persistedResults = await DatabaseService.searchReports(query);

    // Also search in mock reports if provided
    final List<Report> mockResults = [];
    if (mockReports != null) {
      mockResults.addAll(
        mockReports
            .where(
              (report) =>
                  report.type.toLowerCase().contains(query.toLowerCase()) ||
                  report.location.toLowerCase().contains(query.toLowerCase()) ||
                  report.description.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .toList(),
      );
    }

    // Combine and sort by creation date
    final allResults = [...persistedResults, ...mockResults];
    allResults.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return allResults;
  }

  /// Get report by ID (checks both persisted and mock)
  static Future<Report?> getReportById(String reportId) async {
    if (isUserCreatedReportSync(reportId)) {
      return await DatabaseService.getReport(reportId);
    }
    return null; // Mock reports are generated on-demand
  }

  /// Export user reports
  static Future<List<Map<String, dynamic>>> exportUserReports() async {
    final reports = await getPersistedReports();
    return reports.map((report) => report.toJson()).toList();
  }

  /// Import user reports
  static Future<void> importUserReports(
    List<Map<String, dynamic>> reportsJson,
  ) async {
    for (final json in reportsJson) {
      try {
        final report = Report.fromJson(json);
        await saveUserReport(report);
      } catch (e) {
        // Log error but continue with other reports
        debugPrint('Failed to import report: $e');
      }
    }
  }
}
