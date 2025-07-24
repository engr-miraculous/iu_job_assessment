import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iu_job_assessment/models/media_models.dart';
import 'package:iu_job_assessment/utils/app_colors.dart';
import 'package:video_player/video_player.dart';

class MediaViewerScreen extends StatefulWidget {
  final List<MediaItem> mediaItems;
  final int initialIndex;

  const MediaViewerScreen({
    super.key,
    required this.mediaItems,
    this.initialIndex = 0,
  });

  @override
  State<MediaViewerScreen> createState() => _MediaViewerScreenState();
}

class _MediaViewerScreenState extends State<MediaViewerScreen> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        iconTheme: const IconThemeData(color: AppColors.background),
        title: Text(
          '${_currentIndex + 1} of ${widget.mediaItems.length}',
          style: const TextStyle(color: AppColors.background),
        ),
        actions: [
          IconButton(
            onPressed: _showMediaInfo,
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: widget.mediaItems.length,
        itemBuilder: (context, index) {
          return MediaViewerPage(mediaItem: widget.mediaItems[index]);
        },
      ),
      bottomNavigationBar: widget.mediaItems.length > 1
          ? Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.mediaItems.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentIndex
                          ? AppColors.background
                          : AppColors.background.withAlpha(115),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  void _showMediaInfo() {
    final mediaItem = widget.mediaItems[_currentIndex];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => MediaInfoBottomSheet(mediaItem: mediaItem),
    );
  }
}

class MediaViewerPage extends StatelessWidget {
  final MediaItem mediaItem;

  const MediaViewerPage({super.key, required this.mediaItem});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: mediaItem.type == MediaType.image
          ? _buildImageViewer()
          : _buildVideoViewer(),
    );
  }

  Widget _buildImageViewer() {
    return InteractiveViewer(
      child: Image.file(
        File(mediaItem.path),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, color: AppColors.background, size: 64),
                SizedBox(height: 16),
                Text(
                  'Unable to load image',
                  style: TextStyle(color: AppColors.background),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoViewer() {
    return FullScreenVideoPlayer(videoPath: mediaItem.path);
  }
}

class FullScreenVideoPlayer extends StatefulWidget {
  final String videoPath;

  const FullScreenVideoPlayer({super.key, required this.videoPath});

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _showControls = true;

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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppColors.background, size: 64),
            SizedBox(height: 16),
            Text(
              'Unable to load video',
              style: TextStyle(color: AppColors.background),
            ),
          ],
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.background),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _showControls = !_showControls;
        });
      },
      child: Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            ),
          ),
          if (_showControls)
            Positioned.fill(
              child: Container(
                color: AppColors.black.withAlpha(70),
                child: Center(
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        if (_controller!.value.isPlaying) {
                          _controller!.pause();
                        } else {
                          _controller!.play();
                        }
                      });
                    },
                    icon: Icon(
                      _controller!.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: AppColors.background,
                      size: 64,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MediaInfoBottomSheet extends StatelessWidget {
  final MediaItem mediaItem;

  const MediaInfoBottomSheet({super.key, required this.mediaItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            'Media Info',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Info items
          _buildInfoItem(
            'Type',
            mediaItem.type == MediaType.image ? 'Image' : 'Video',
          ),
          const SizedBox(height: 16),

          _buildInfoItem('Created', _formatDateTime(mediaItem.createdAt)),
          const SizedBox(height: 16),

          if (mediaItem.coordinates != null) ...[
            _buildInfoItem('GPS Coordinates', mediaItem.coordinates!),
            const SizedBox(height: 16),
          ],

          _buildInfoItem('File Path', mediaItem.path),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
