import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iu_job_assessment/providers/location_picker_provider.dart';
import 'package:iu_job_assessment/utils/app_colors.dart';

/// Widget to handle location errors gracefully
class LocationErrorWidget extends ConsumerWidget {
  final String error;

  const LocationErrorWidget({super.key, required this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_off, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Location Error',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.error),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(locationPickerProvider.notifier)
                      .initializeLocation();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(color: AppColors.background),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Permission request dialog
class LocationPermissionDialog extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onCancel;

  const LocationPermissionDialog({
    super.key,
    required this.onRetry,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Location Permission Required'),
      content: const Text(
        'This app needs location permission to help you select locations for reports. Please grant permission in your device settings.',
      ),
      actions: [
        TextButton(onPressed: onCancel, child: const Text('Cancel')),
        ElevatedButton(
          onPressed: onRetry,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text(
            'Grant Permission',
            style: TextStyle(color: AppColors.background),
          ),
        ),
      ],
    );
  }
}
