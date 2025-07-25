// screens/report_details/widgets/report_media_section.dart
import 'package:flutter/material.dart';
import 'package:iu_job_assessment/models/report_model.dart';
import 'package:iu_job_assessment/models/media_models.dart';
import 'package:iu_job_assessment/screens/report_form/media_widgets/media_viewer_screen.dart';
import 'package:iu_job_assessment/utils/app_colors.dart';

/// Widget to display media section in report details
class ReportMediaSection extends StatelessWidget {
  final Report report;

  const ReportMediaSection({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return _buildMediaContent(context);
  }

  /// Build media content based on availability
  Widget _buildMediaContent(BuildContext context) {
    if (report.media.isEmpty) {
      return _buildNoMediaPlaceholder();
    }

    return _buildMediaGrid(context);
  }

  /// Build placeholder when no media is available
  Widget _buildNoMediaPlaceholder() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textSecondary.withAlpha(76),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 48,
            color: AppColors.textSecondary.withAlpha(153),
          ),
          const SizedBox(height: 8),
          Text(
            'No media attached',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary.withAlpha(153),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Build media grid using existing thumbnail widget
  Widget _buildMediaGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: report.media.length,
      itemBuilder: (context, index) {
        return ReportMediaThumbnailWidget(
          mediaItem: report.media[index],
          index: index,
          onTap: () => _handleMediaTap(context, index),
        );
      },
    );
  }

  /// Handle media tap to show viewer
  void _handleMediaTap(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MediaViewerScreen(mediaItems: report.media, initialIndex: index),
      ),
    );
  }
}

/// Custom thumbnail widget for report media (read-only version)
class ReportMediaThumbnailWidget extends StatelessWidget {
  final MediaItem mediaItem;
  final int index;
  final VoidCallback? onTap;

  const ReportMediaThumbnailWidget({
    super.key,
    required this.mediaItem,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // Main content
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: _buildMediaContent(),
            ),
          ),

          // GPS coordinates indicator
          if (mediaItem.coordinates != null)
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.black.withAlpha(160),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                  size: 12,
                ),
              ),
            ),

          // Media type indicator for videos
          if (mediaItem.type == MediaType.video)
            Positioned.fill(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.black.withAlpha(160),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: AppColors.background,
                    size: 24,
                  ),
                ),
              ),
            ),

          // Tap indicator overlay
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onTap,
                child: Container(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaContent() {
    if (mediaItem.type == MediaType.image) {
      return Image.asset(
        'assets/Splash.png', // Use asset for now, will be replaced with actual thumbnail
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      );
    } else {
      // For videos, show thumbnail with play button
      return Container(
        color: AppColors.surface,
        child: const Center(
          child: Icon(
            Icons.video_file,
            color: AppColors.textSecondary,
            size: 32,
          ),
        ),
      );
    }
  }

  Widget _buildErrorWidget() {
    return Container(
      color: AppColors.surface,
      child: Icon(
        mediaItem.type == MediaType.image
            ? Icons.broken_image
            : Icons.video_file,
        color: AppColors.textSecondary,
        size: 32,
      ),
    );
  }
}
