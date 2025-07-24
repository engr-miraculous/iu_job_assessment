import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iu_job_assessment/models/media_models.dart';
import 'package:iu_job_assessment/services/location_service.dart';
import 'package:iu_job_assessment/services/media_service.dart';
import 'package:path/path.dart' as path;

// Media provider for managing media items
class MediaNotifier extends StateNotifier<MediaState> {
  final LocationService _locationService;
  final MediaProcessingService _mediaProcessingService;
  final ImagePicker _picker = ImagePicker();

  MediaNotifier(this._locationService, this._mediaProcessingService)
    : super(const MediaState());

  // Add media from camera
  Future<void> captureFromCamera({required bool isVideo}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      XFile? file;
      if (isVideo) {
        file = await _picker.pickVideo(
          source: ImageSource.camera,
          maxDuration: const Duration(minutes: 5),
        );
      } else {
        file = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
        );
      }

      if (file != null) {
        await _processAndAddMedia([file], MediaSource.camera);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error accessing camera: $e',
      );
    }
  }

  // Add media from gallery
  Future<void> selectFromGallery() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final files = await _picker.pickMultipleMedia(imageQuality: 85);

      if (files.isNotEmpty) {
        await _processAndAddMedia(files, MediaSource.gallery);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error accessing gallery: $e',
      );
    }
  }

  // Process and add media files
  Future<void> _processAndAddMedia(
    List<XFile> files,
    MediaSource source,
  ) async {
    try {
      final processedMedia = <MediaItem>[];

      for (final file in files) {
        final mediaItem = await _processMediaFile(file);
        if (mediaItem != null) {
          processedMedia.add(mediaItem);
        }
      }

      final updatedItems = [...state.items, ...processedMedia];
      state = state.copyWith(
        items: updatedItems,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error processing media: $e',
      );
    }
  }

  // Process individual media file
  Future<MediaItem?> _processMediaFile(XFile file) async {
    try {
      // Get current location
      String? coordinates;
      try {
        final position = await _locationService.getCurrentPosition();
        coordinates =
            '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
      } catch (e) {
        debugPrint('Could not get location: $e');
      }

      // Determine media type
      final isVideo = _isVideoFile(file.path);
      final mediaType = isVideo ? MediaType.video : MediaType.image;

      String processedPath;

      if (mediaType == MediaType.image) {
        processedPath = await _mediaProcessingService.processImageWithOverlay(
          file.path,
          coordinates,
        );
      } else {
        processedPath = await _mediaProcessingService.copyVideoFile(file.path);
      }

      return MediaItem(
        path: processedPath,
        type: mediaType,
        coordinates: coordinates,
        createdAt: DateTime.now(),
        originalPath: file.path,
      );
    } catch (e) {
      debugPrint('Error processing media file: $e');
      return null;
    }
  }

  // Remove media item
  void removeMediaItem(int index) {
    if (index >= 0 && index < state.items.length) {
      final updatedItems = [...state.items];
      updatedItems.removeAt(index);
      state = state.copyWith(items: updatedItems);
    }
  }

  // Clear all media
  void clearAllMedia() {
    state = state.copyWith(items: []);
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Helper method to check if file is video
  bool _isVideoFile(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return ['.mp4', '.mov', '.avi', '.mkv', '.3gp'].contains(extension);
  }

  // Set initial media (for editing scenarios)
  void setInitialMedia(List<MediaItem> items) {
    state = state.copyWith(items: items);
  }
}

// Providers
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final mediaProcessingServiceProvider = Provider<MediaProcessingService>((ref) {
  return MediaProcessingService();
});

final mediaProvider = StateNotifierProvider<MediaNotifier, MediaState>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  final mediaProcessingService = ref.watch(mediaProcessingServiceProvider);
  return MediaNotifier(locationService, mediaProcessingService);
});

// Convenience providers
final mediaItemsProvider = Provider<List<MediaItem>>((ref) {
  return ref.watch(mediaProvider).items;
});

final isMediaLoadingProvider = Provider<bool>((ref) {
  return ref.watch(mediaProvider).isLoading;
});

final mediaErrorProvider = Provider<String?>((ref) {
  return ref.watch(mediaProvider).error;
});
