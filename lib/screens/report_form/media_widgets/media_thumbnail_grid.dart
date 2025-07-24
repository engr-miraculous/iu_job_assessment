import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iu_job_assessment/models/media_models.dart';
import 'package:iu_job_assessment/utils/app_colors.dart';
import 'package:video_player/video_player.dart';

class MediaThumbnailWidget extends StatelessWidget {
  final MediaItem mediaItem;
  final int index;
  final VoidCallback onRemove;
  final VoidCallback? onTap;

  const MediaThumbnailWidget({
    super.key,
    required this.mediaItem,
    required this.index,
    required this.onRemove,
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

          // Remove button
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.close,
                  color: AppColors.background,
                  size: 16,
                ),
              ),
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
        ],
      ),
    );
  }

  Widget _buildMediaContent() {
    if (mediaItem.type == MediaType.image) {
      return Image.file(
        File(mediaItem.path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      );
    } else {
      // For videos, show thumbnail
      return VideoThumbnailWidget(
        videoPath: mediaItem.path,
        errorBuilder: _buildErrorWidget,
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

// Video Thumbnail Widget
class VideoThumbnailWidget extends StatefulWidget {
  final String videoPath;
  final Widget Function()? errorBuilder;

  const VideoThumbnailWidget({
    super.key,
    required this.videoPath,
    this.errorBuilder,
  });

  @override
  State<VideoThumbnailWidget> createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.file(File(widget.videoPath));
      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return widget.errorBuilder?.call() ?? _buildDefaultError();
    }

    if (!_isInitialized || _controller == null) {
      return Container(
        color: AppColors.surface,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: VideoPlayer(_controller!),
    );
  }

  Widget _buildDefaultError() {
    return Container(
      color: AppColors.surface,
      child: const Center(
        child: Icon(Icons.video_file, color: AppColors.textSecondary, size: 32),
      ),
    );
  }
}
