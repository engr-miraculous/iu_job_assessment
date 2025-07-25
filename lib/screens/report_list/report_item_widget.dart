// widgets/report_item_widget.dart (Enhanced version)
import 'package:flutter/material.dart';
import 'package:iu_job_assessment/models/report_model.dart';
import 'package:iu_job_assessment/utils/app_colors.dart';
import 'package:iu_job_assessment/services/report_service.dart';

class ReportItemWidget extends StatelessWidget {
  final Report report;
  final bool? isUserCreated;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ReportItemWidget({
    super.key,
    required this.report,
    this.isUserCreated,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool userCreated =
        isUserCreated ?? ReportService.isUserCreatedReportSync(report.id);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: userCreated ? 3 : 1,
      child: ListTile(
        onTap: onTap,
        title: Text(
          report.type,
          style: TextStyle(
            fontWeight: userCreated ? FontWeight.bold : FontWeight.w600,
            fontSize: 16,
            color: userCreated ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              report.location,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: userCreated
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            if (report.description.isNotEmpty) ...[
              Text(
                report.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
            ],
            Row(
              children: [
                _buildStatusChip(),
                const SizedBox(width: 8),
                if (userCreated) _buildUserCreatedBadge(),
              ],
            ),
          ],
        ),
        trailing: _buildTrailing(context, userCreated),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildStatusChip() {
    Color statusColor;
    switch (report.status.toLowerCase()) {
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      case 'verified':
        statusColor = Colors.blue;
        break;
      case 'submitted':
        statusColor = Colors.purple;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.5)),
      ),
      child: Text(
        report.status,
        style: TextStyle(
          color: statusColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildUserCreatedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.save_outlined, size: 10, color: AppColors.primary),
          const SizedBox(width: 2),
          const Text(
            'SAVED',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrailing(BuildContext context, bool userCreated) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          report.referenceNumber,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: userCreated ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatDate(report.createdAt),
          style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
        ),
        if (userCreated && onDelete != null) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.delete_outline,
                size: 16,
                color: Colors.red.shade400,
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Loading placeholder widget for report items
class LoadingReportItemWidget extends StatelessWidget {
  const LoadingReportItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade300,
          child: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
            ),
          ),
        ),
        title: Container(
          height: 16,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Container(
              height: 12,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 20,
              width: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
        trailing: Container(
          height: 40,
          width: 60,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        isThreeLine: true,
      ),
    );
  }
}
