import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iu_job_assessment/models/report_model.dart';
import 'package:iu_job_assessment/utils/app_colors.dart';

/// Individual report item widget
class ReportItemWidget extends StatelessWidget {
  final Report report;
  final VoidCallback? onTap;

  const ReportItemWidget({super.key, required this.report, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 4),
              _buildLocation(),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the header row with report type and status
  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                report.type,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatDate(report.createdAt),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatDateTime(report.createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            _buildStatusChip(),
          ],
        ),
      ],
    );
  }

  /// Build location text
  Widget _buildLocation() {
    return Text(
      report.location,
      style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
    );
  }

  /// Build status chip with appropriate color
  Widget _buildStatusChip() {
    Color statusColor;
    Color backgroundColor;

    switch (report.status.toLowerCase()) {
      case 'completed':
        statusColor = Colors.green.shade700;
        backgroundColor = Colors.green.shade50;
        break;
      case 'in progress':
        statusColor = Colors.orange.shade700;
        backgroundColor = Colors.orange.shade50;
        break;
      case 'cancelled':
        statusColor = Colors.grey.shade700;
        backgroundColor = Colors.grey.shade100;
        break;
      case 'pending':
      default:
        statusColor = AppColors.error;
        backgroundColor = AppColors.error.withOpacity(0.1);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '(Status ${report.referenceNumber})',
        style: TextStyle(
          fontSize: 12,
          color: statusColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Format date for display (e.g., "Dec 15, 2024")
  String _formatDate(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy').format(dateTime);
  }

  /// Format time for display (e.g., "2:30 PM")
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }
}

/// Loading item widget for pagination
class LoadingReportItemWidget extends StatelessWidget {
  const LoadingReportItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShimmer(width: 150, height: 16),
                      const SizedBox(height: 4),
                      _buildShimmer(width: 80, height: 12),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildShimmer(width: 60, height: 12),
                    const SizedBox(height: 4),
                    _buildShimmer(width: 90, height: 20),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildShimmer(width: 200, height: 14),
          ],
        ),
      ),
    );
  }

  /// Build shimmer placeholder
  Widget _buildShimmer({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
