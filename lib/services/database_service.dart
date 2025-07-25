// lib/services/database_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:iu_job_assessment/models/media_models.dart';
import 'package:iu_job_assessment/models/report_model.dart';
import 'package:iu_job_assessment/services/database_service.dart'
    show ReportData, ReportsCompanion;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database_service.g.dart';

/// TypeConverter for storing a List<MediaItem> as a JSON string in the database.
class MediaListConverter extends TypeConverter<List<MediaItem>, String> {
  const MediaListConverter();

  @override
  List<MediaItem> fromSql(String fromDb) {
    if (fromDb.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decoded = json.decode(fromDb) as List;
      return decoded
          .map((item) => MediaItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (err) {
      print('Error decoding media list from DB: $err');
      return [];
    }
  }

  @override
  String toSql(List<MediaItem> value) {
    return json.encode(value.map((item) => item.toJson()).toList());
  }
}

/// Drift table for Reports
@DataClassName('ReportData')
class Reports extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get location => text()();
  TextColumn get status => text()();
  TextColumn get referenceNumber => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get media => text()
      .map(const MediaListConverter())
      .withDefault(const Constant('[]'))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Database class using Drift
@DriftDatabase(tables: [Reports])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  /// Convert generated Drift ReportData class to main Report model
  Report _toAppReport(ReportData row) {
    // <-- Updated parameter type
    return Report(
      id: row.id,
      type: row.type,
      location: row.location,
      status: row.status,
      referenceNumber: row.referenceNumber,
      description: row.description,
      media: row.media,
      createdAt: row.createdAt,
    );
  }

  /// Get all reports ordered by creation date (newest first)
  Future<List<Report>> getAllReports() async {
    final query = select(reports)
      ..orderBy([(r) => OrderingTerm.desc(r.createdAt)]);
    final List<ReportData> rows = await query.get();
    return rows.map(_toAppReport).toList();
  }

  /// Get reports with pagination
  Future<List<Report>> getReportsWithPagination({
    int offset = 0,
    int limit = 10,
  }) async {
    final query = select(reports)
      ..orderBy([(r) => OrderingTerm.desc(r.createdAt)])
      ..limit(limit, offset: offset);
    final List<ReportData> rows = await query.get();
    return rows.map(_toAppReport).toList();
  }

  /// Insert or update a report
  Future<void> insertOrUpdateReport(Report report) async {
    await into(reports).insertOnConflictUpdate(
      ReportsCompanion(
        id: Value(report.id),
        type: Value(report.type),
        location: Value(report.location),
        status: Value(report.status),
        referenceNumber: Value(report.referenceNumber),
        description: Value(report.description),
        media: Value(report.media),
        createdAt: Value(report.createdAt),
      ),
    );
  }

  /// Delete a report by ID
  Future<void> deleteReportById(String reportId) async {
    await (delete(reports)..where((r) => r.id.equals(reportId))).go();
  }

  /// Get report by ID
  Future<Report?> getReportById(String reportId) async {
    final query = select(reports)..where((r) => r.id.equals(reportId));
    final row = await query.getSingleOrNull();
    return row != null ? _toAppReport(row) : null;
  }

  /// Check if report exists
  Future<bool> reportExists(String reportId) async {
    final query = selectOnly(reports)
      ..addColumns([reports.id])
      ..where(reports.id.equals(reportId));
    final result = await query.getSingleOrNull();
    return result != null;
  }

  /// Get total count of reports
  Future<int> getTotalReportsCount() async {
    final countExp = reports.id.count();
    final query = selectOnly(reports)..addColumns([countExp]);
    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  /// Search reports
  Future<List<Report>> searchReports(String searchTerm) async {
    final query = select(reports)
      ..where(
        (r) =>
            r.type.like('%$searchTerm%') |
            r.location.like('%$searchTerm%') |
            r.description.like('%$searchTerm%'),
      )
      ..orderBy([(r) => OrderingTerm.desc(r.createdAt)]);
    final List<ReportData> rows = await query.get();
    return rows.map(_toAppReport).toList();
  }

  /// Clear all reports
  Future<void> clearAllReports() async {
    await delete(reports).go();
  }
}

/// Database service wrapper
class DatabaseService {
  static AppDatabase? _database;

  /// Initialize database
  static Future<void> initialize() async {
    _database = AppDatabase();
  }

  /// Get database instance
  static AppDatabase get database {
    if (_database == null) {
      throw Exception(
        'Database not initialized. Call DatabaseService.initialize() first.',
      );
    }
    return _database!;
  }

  /// Save a report
  static Future<void> saveReport(Report report) async {
    await database.insertOrUpdateReport(report);
  }

  /// Get all persisted reports
  static Future<List<Report>> getPersistedReports() async {
    return await database.getAllReports();
  }

  /// Get persisted reports count
  static Future<int> getPersistedReportsCount() async {
    return await database.getTotalReportsCount();
  }

  /// Delete a report
  static Future<void> deleteReport(String reportId) async {
    await database.deleteReportById(reportId);
  }

  /// Check if report exists
  static Future<bool> reportExists(String reportId) async {
    return await database.reportExists(reportId);
  }

  /// Get report by ID
  static Future<Report?> getReport(String reportId) async {
    return await database.getReportById(reportId);
  }

  /// Clear all reports
  static Future<void> clearAllReports() async {
    await database.clearAllReports();
  }

  /// Search reports
  static Future<List<Report>> searchReports(String query) async {
    return await database.searchReports(query);
  }

  /// Close database
  static Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}

/// Database connection setup
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'reports.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
