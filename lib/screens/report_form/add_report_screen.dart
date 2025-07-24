import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iu_job_assessment/models/location_model.dart';
import 'package:iu_job_assessment/providers/media_provider.dart';
import 'package:iu_job_assessment/providers/report_form_provider.dart';
import 'package:iu_job_assessment/screens/report_form/location_field_button.dart';
import 'package:iu_job_assessment/screens/report_form/media_widgets/report_form_photos_section.dart';
import 'package:iu_job_assessment/screens/report_form/report_category_selector.dart';
import 'package:iu_job_assessment/screens/report_form/rich_text_editor.dart';
import 'package:iu_job_assessment/utils/app_colors.dart';

/// Main screen for adding a new report
class AddReportScreen extends ConsumerStatefulWidget {
  const AddReportScreen({super.key});

  @override
  ConsumerState<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends ConsumerState<AddReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _photosController = TextEditingController();
  LocationData? _selectedLocation;

  @override
  void initState() {
    super.initState();
    // Reset form when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reportFormProvider.notifier).resetForm();
      ref.read(mediaProvider.notifier).clearAllMedia();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _photosController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  /// Build the app bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      leading: const SizedBox.shrink(),
      actions: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
        ),
      ],
      title: const Text(
        'Add Report',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  /// Build the main body content
  Widget _buildBody() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category selector
                  const ReportCategorySelector(),
                  const SizedBox(height: 24),

                  // "Other" category note
                  Consumer(
                    builder: (context, ref, child) {
                      final isOtherSelected = ref.watch(
                        isOtherCategorySelectedProvider,
                      );
                      if (!isOtherSelected) return const SizedBox.shrink();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.error.withAlpha(100),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "If answering 'Other', please provide details in the description.",
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Location field
                  _buildSectionTitle('Location'),
                  const SizedBox(height: 8),
                  LocationFieldButton(
                    selectedLocation: _selectedLocation,
                    onLocationSelected: (location) {
                      setState(() {
                        _selectedLocation = location;
                      });
                      ref
                          .read(reportFormProvider.notifier)
                          .updateLocation(location.displayAddress);
                    },
                    validator: (location) {
                      if (location == null) {
                        return 'Please select a location';
                      }
                      return null;
                    },
                    showError: false, // Will be handled by form validation
                  ),
                  const SizedBox(height: 24),

                  // Description field
                  _buildSectionTitle('Description'),
                  const SizedBox(height: 8),
                  RichTextEditor(
                    hintText: 'Value',
                    onChanged: (value) {
                      ref
                          .read(reportFormProvider.notifier)
                          .updateDescription(value);
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a description';
                      }

                      // Extra validation for "Other" category
                      final isOtherSelected = ref.read(
                        isOtherCategorySelectedProvider,
                      );
                      if (isOtherSelected && value.trim().length < 10) {
                        return 'Please provide more details for "Other" category';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Media field
                  ReportFormPhotosSection(
                    onPhotosChanged: (mediaItems) {
                      ref
                          .read(reportFormProvider.notifier)
                          .updateMedia(mediaItems);
                    },
                    validator: (mediaItems) {
                      final isOtherSelected = ref.read(
                        isOtherCategorySelectedProvider,
                      );
                      if (isOtherSelected &&
                          (mediaItems == null || mediaItems.isEmpty)) {
                        return 'Please add at least one photo or video for "Other" category';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Bottom buttons
          _buildBottomButtons(),
        ],
      ),
    );
  }

  /// Build section title
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
    );
  }

  /// Build bottom action buttons
  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Cancel button
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                side: BorderSide(color: Colors.grey.shade300),
                backgroundColor: AppColors.background,
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Submit button
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final isFormValid = ref.watch(isFormValidProvider);
                final isSubmitting = ref.watch(isSubmittingProvider);

                return ElevatedButton(
                  onPressed: (isFormValid && !isSubmitting)
                      ? _handleSubmit
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.background,
                            ),
                          ),
                        )
                      : const Text(
                          'Submit report',
                          style: TextStyle(
                            color: AppColors.background,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Handle form submission
  Future<void> _handleSubmit() async {
    // Validate location
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Set submitting state
    ref.read(isSubmittingProvider.notifier).state = true;

    try {
      // Submit the report
      final success = await ref
          .read(reportFormProvider.notifier)
          .submitReport(ref);

      if (success && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Report submitted successfully!',
              style: TextStyle(color: AppColors.background),
            ),
            backgroundColor: Colors.green.shade600,
            duration: const Duration(seconds: 2),
          ),
        );

        // Clear the media items from the media provider
        ref.read(mediaProvider.notifier).clearAllMedia();

        // Navigate back to previous screen
        Navigator.of(context).pop();
      } else if (mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to submit report. Please try again.',
              style: TextStyle(color: AppColors.background),
            ),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString()}',
              style: const TextStyle(color: AppColors.background),
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      // Reset submitting state
      if (mounted) {
        ref.read(isSubmittingProvider.notifier).state = false;
      }
    }
  }
}
