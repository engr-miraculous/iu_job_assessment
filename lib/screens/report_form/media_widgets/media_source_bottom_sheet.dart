import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iu_job_assessment/providers/media_provider.dart';
import 'package:iu_job_assessment/utils/app_colors.dart';

class MediaSourceBottomSheet extends ConsumerWidget {
  const MediaSourceBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            'Add Media',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Camera and Gallery options
          Row(
            children: [
              Expanded(
                child: _MediaSourceButton(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () => _handleCameraSelection(context, ref),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _MediaSourceButton(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () => _handleGallerySelection(context, ref),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _handleCameraSelection(
    BuildContext context,
    WidgetRef ref,
  ) async {
    // Show camera options dialog
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera'),
        content: const Text('What would you like to capture?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'photo'),
            child: const Text('Photo'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'video'),
            child: const Text('Video'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (result == null) return;

    // Close bottom sheet
    Navigator.pop(context);

    // Capture from camera
    if (result == 'photo') {
      await ref.read(mediaProvider.notifier).captureFromCamera(isVideo: false);
    } else if (result == 'video') {
      await ref.read(mediaProvider.notifier).captureFromCamera(isVideo: true);
    }
  }

  Future<void> _handleGallerySelection(
    BuildContext context,
    WidgetRef ref,
  ) async {
    // Close bottom sheet
    Navigator.pop(context);

    // Select from gallery
    await ref.read(mediaProvider.notifier).selectFromGallery();
  }
}

class _MediaSourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MediaSourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.background),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
