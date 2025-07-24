import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iu_job_assessment/models/media_models.dart';
import 'package:iu_job_assessment/providers/media_provider.dart';
import 'package:iu_job_assessment/screens/report_form/media_widgets/media_thumbnail_grid.dart';
import 'package:iu_job_assessment/screens/report_form/media_widgets/media_viewer_screen.dart';
import 'package:iu_job_assessment/utils/app_colors.dart';

class MediaGridWidget extends ConsumerWidget {
  final List<MediaItem> mediaItems;
  final bool showAddButton;
  final VoidCallback? onAddPressed;

  const MediaGridWidget({
    super.key,
    required this.mediaItems,
    this.showAddButton = true,
    this.onAddPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (mediaItems.isEmpty && !showAddButton) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showAddButton) _buildAddButton(context),
        if (mediaItems.isNotEmpty) ...[
          if (showAddButton) const SizedBox(height: 16),
          _buildMediaGrid(context, ref),
        ],
      ],
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return InkWell(
      onTap: onAddPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.textSecondary.withAlpha(25),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.textSecondary),
        ),
        child: Row(
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              color: Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              mediaItems.isEmpty
                  ? 'Add photos or videos'
                  : 'Add more photos or videos',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaGrid(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: mediaItems.length,
      itemBuilder: (context, index) {
        return MediaThumbnailWidget(
          mediaItem: mediaItems[index],
          index: index,
          onRemove: () => _handleRemoveMedia(ref, index),
          onTap: () => _handleMediaTap(context, index),
        );
      },
    );
  }

  void _handleRemoveMedia(WidgetRef ref, int index) {
    ref.read(mediaProvider.notifier).removeMediaItem(index);
  }

  void _handleMediaTap(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MediaViewerScreen(mediaItems: mediaItems, initialIndex: index),
      ),
    );
  }
}
