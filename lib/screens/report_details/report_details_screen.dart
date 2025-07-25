import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iu_job_assessment/models/report_model.dart';
import 'package:iu_job_assessment/screens/report_details/report_map_widget.dart';
import 'package:iu_job_assessment/screens/report_details/report_media_section_widget.dart';
import 'package:iu_job_assessment/utils/app_colors.dart';
import 'package:intl/intl.dart';

/// Provider for the current report being viewed
final currentReportProvider = StateProvider<Report?>((ref) => null);

/// Report details screen showing full report information
class ReportDetailsScreen extends ConsumerWidget {
  final Report report;

  const ReportDetailsScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Set the current report in the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentReportProvider.notifier).state = report;
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: _buildBody(),
    );
  }

  /// Build the app bar with title and edit button
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
      ),
      title: const Text(
        'Report',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        TextButton(
          onPressed: () {
            // TODO: Navigate to edit screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Edit functionality coming soon')),
            );
          },
          child: const Text(
            'Edit',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// Build the main body content
  Widget _buildBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReportHeader(),
          const SizedBox(height: 2),
          _buildMapSection(),
          const SizedBox(height: 2),
          _buildStatusDateSection(),
          const SizedBox(height: 24),
          _buildDescriptionSection(),
          const SizedBox(height: 24),
          ReportMediaSection(report: report),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Build report header with type and location
  Widget _buildReportHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(0),
      padding: EdgeInsets.symmetric(vertical: 16),
      color: AppColors.black,
      child: Text(
        '(${_getFormattedReportType()}) ${report.location}',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          color: AppColors.surface,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Build the map section
  Widget _buildMapSection() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ReportMapWidget(report: report),
      ),
    );
  }

  /// Build status and date section
  Widget _buildStatusDateSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.surface,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '(${report.status})',
                  style: TextStyle(
                    fontSize: 16,
                    color: _getStatusColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Date submitted',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getFormattedDate(),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build description section
  Widget _buildDescriptionSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            report.description.isNotEmpty
                ? report.description
                : 'No description provided.',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Get formatted report type
  String _getFormattedReportType() {
    final category = ReportCategories.findById(report.type);
    return category?.name.replaceAll('\n', ' ') ?? report.type;
  }

  /// Get status color
  Color _getStatusColor() {
    switch (report.status.toLowerCase()) {
      case 'pending':
      case 'submitted':
        return AppColors.error;
      case 'in progress':
        return Colors.orange;
      case 'completed':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }

  /// Get formatted date
  String _getFormattedDate() {
    return DateFormat('d MMM yyyy, h:mm a').format(report.createdAt);
  }
}
