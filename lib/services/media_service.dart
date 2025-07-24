import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;

class MediaProcessingService {
  // Process image with GPS coordinates overlay
  Future<String> processImageWithOverlay(
    String imagePath,
    String? coordinates,
  ) async {
    if (coordinates == null) {
      // If no coordinates, just copy the original file
      return await _copyImageFile(imagePath);
    }

    try {
      // Read the original image
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        throw MediaProcessingException('Could not decode image');
      }

      // Create a copy to draw on
      final processedImage = img.Image.from(originalImage);

      // Add GPS coordinates and timestamp overlay
      await _addTextOverlay(processedImage, coordinates);

      // Save the processed image
      final processedPath = await _saveProcessedImage(
        processedImage,
        imagePath,
      );

      return processedPath;
    } catch (e) {
      debugPrint('Error processing image overlay: $e');
      // Fallback: just copy the original file
      return await _copyImageFile(imagePath);
    }
  }

  // Add text overlay to image
  Future<void> _addTextOverlay(img.Image image, String coordinates) async {
    final timestamp = DateTime.now().toString().substring(0, 19);
    final overlayText = 'GPS: $coordinates\n$timestamp';

    // Calculate position for overlay (bottom-left corner with padding)
    final x = 10;
    final y = image.height - 80;

    // Draw semi-transparent background for better text visibility
    img.fillRect(
      image,
      x1: x - 5,
      y1: y - 5,
      x2: x + 300, // Approximate width
      y2: y + 70, // Approximate height
      color: img.ColorRgba8(0, 0, 0, 180), // Semi-transparent black
    );

    // Draw the text in white
    img.drawString(
      image,
      overlayText,
      font: img.arial14,
      x: x,
      y: y,
      color: img.ColorRgb8(255, 255, 255),
    );
  }

  // Save processed image
  Future<String> _saveProcessedImage(
    img.Image image,
    String originalPath,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = path.basename(originalPath);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final processedPath = path.join(
      directory.path,
      'processed_${timestamp}_$fileName',
    );

    final processedFile = File(processedPath);

    // Determine format and encode accordingly
    final extension = path.extension(originalPath).toLowerCase();
    List<int> encodedImage;

    switch (extension) {
      case '.jpg':
      case '.jpeg':
        encodedImage = img.encodeJpg(image, quality: 85);
        break;
      case '.png':
        encodedImage = img.encodePng(image);
        break;
      default:
        encodedImage = img.encodeJpg(image, quality: 85);
        break;
    }

    await processedFile.writeAsBytes(encodedImage);
    return processedPath;
  }

  // Copy image file without processing
  Future<String> _copyImageFile(String originalPath) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = path.basename(originalPath);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final newPath = path.join(directory.path, 'image_${timestamp}_$fileName');

    await File(originalPath).copy(newPath);
    return newPath;
  }

  // Copy video file (coordinates stored separately in MediaItem)
  Future<String> copyVideoFile(String videoPath) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = path.basename(videoPath);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final newPath = path.join(directory.path, 'video_${timestamp}_$fileName');

    try {
      await File(videoPath).copy(newPath);
      return newPath;
    } catch (e) {
      throw MediaProcessingException('Failed to copy video file: $e');
    }
  }

  // Get thumbnail for video (first frame)
  Future<String?> generateVideoThumbnail(String videoPath) async {
    // This would require video_thumbnail package
    // For now, I'm returning null and handle it in the UI
    // TODO: Implement video thumbnail generation
    return null;
  }

  // Compress image if needed
  Future<String> compressImage(String imagePath, {int quality = 85}) async {
    try {
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        throw MediaProcessingException(
          'Could not decode image for compression',
        );
      }

      // Resize if image is too large
      img.Image processedImage = originalImage;
      if (originalImage.width > 1920 || originalImage.height > 1920) {
        processedImage = img.copyResize(
          originalImage,
          width: originalImage.width > originalImage.height ? 1920 : null,
          height: originalImage.height > originalImage.width ? 1920 : null,
        );
      }

      // Save compressed image
      final directory = await getApplicationDocumentsDirectory();
      final fileName = path.basename(imagePath);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final compressedPath = path.join(
        directory.path,
        'compressed_${timestamp}_$fileName',
      );

      final compressedFile = File(compressedPath);
      final encodedImage = img.encodeJpg(processedImage, quality: quality);
      await compressedFile.writeAsBytes(encodedImage);

      return compressedPath;
    } catch (e) {
      throw MediaProcessingException('Failed to compress image: $e');
    }
  }

  // Clean up old processed files
  Future<void> cleanupOldFiles({int maxAgeInDays = 7}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final cutoffDate = DateTime.now().subtract(Duration(days: maxAgeInDays));

      final files = directory.listSync();
      for (final file in files) {
        if (file is File) {
          final fileName = path.basename(file.path);
          if (fileName.startsWith('processed_') ||
              fileName.startsWith('image_') ||
              fileName.startsWith('video_') ||
              fileName.startsWith('compressed_')) {
            final fileStat = await file.stat();
            if (fileStat.modified.isBefore(cutoffDate)) {
              await file.delete();
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error cleaning up old files: $e');
    }
  }

  // Get file size
  Future<int> getFileSize(String filePath) async {
    final file = File(filePath);
    return await file.length();
  }

  // Format file size for display
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

// Custom exception for media processing errors
class MediaProcessingException implements Exception {
  final String message;

  MediaProcessingException(this.message);

  @override
  String toString() => 'MediaProcessingException: $message';
}
