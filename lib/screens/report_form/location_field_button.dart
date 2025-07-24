import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iu_job_assessment/models/location_model.dart';
import 'package:iu_job_assessment/screens/location_picker/location_picker_screen.dart';
import 'package:iu_job_assessment/utils/app_colors.dart';

/// Location field button that opens location picker when tapped
class LocationFieldButton extends ConsumerWidget {
  final LocationData? selectedLocation;
  final ValueChanged<LocationData>? onLocationSelected;
  final String? Function(LocationData?)? validator;
  final bool showError;
  final String? errorText;

  const LocationFieldButton({
    super.key,
    this.selectedLocation,
    this.onLocationSelected,
    this.validator,
    this.showError = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasError =
        showError && (errorText != null || _getValidationError() != null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _openLocationPicker(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasError ? Colors.red : AppColors.textSecondary,
                width: hasError ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: selectedLocation != null
                      ? AppColors.primary
                      : Colors.grey.shade500,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (selectedLocation != null) ...[
                        Text(
                          selectedLocation!.displayAddress,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (selectedLocation!.shortAddress !=
                            selectedLocation!.displayAddress)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              selectedLocation!.shortAddress,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                      ] else
                        Text(
                          'Tap to select location',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade500,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                  size: 24,
                ),
              ],
            ),
          ),
        ),

        // Error message
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              errorText ?? _getValidationError() ?? '',
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  /// Open location picker screen
  Future<void> _openLocationPicker(BuildContext context) async {
    final result = await Navigator.of(context).push<LocationData>(
      MaterialPageRoute(
        builder: (context) =>
            LocationPickerScreen(initialLocation: selectedLocation),
        fullscreenDialog: true,
      ),
    );

    if (result != null && onLocationSelected != null) {
      onLocationSelected!(result);
    }
  }

  /// Get validation error message
  String? _getValidationError() {
    if (validator != null) {
      return validator!(selectedLocation);
    }
    return null;
  }
}
