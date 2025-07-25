import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iu_job_assessment/models/media_models.dart';
import 'package:iu_job_assessment/models/report_model.dart';
import 'package:iu_job_assessment/providers/report_provider.dart';

/// State notifier for managing report form data
class ReportFormProvider extends StateNotifier<ReportFormData> {
  ReportFormProvider() : super(const ReportFormData());

  /// Update selected category
  void updateCategory(ReportCategory? category) {
    state = state.copyWith(category: category);
  }

  /// Update location
  void updateLocation(String location) {
    state = state.copyWith(location: location);
  }

  /// Update description
  void updateDescription(String description) {
    state = state.copyWith(description: description);
  }

  void updateMedia(List<MediaItem> media) {
    state = state.copyWith(media: media);
  }

  void addMediaItem(MediaItem item) {
    final updated = [...state.media, item];
    state = state.copyWith(media: updated);
  }

  void removeMediaItem(MediaItem item) {
    final updated = state.media.where((m) => m != item).toList();
    state = state.copyWith(media: updated);
  }

  /// Reset form to initial state
  void resetForm() {
    state = const ReportFormData();
  }

  /// Submit the report
  Future<bool> submitReport(WidgetRef ref) async {
    if (!state.isValid) {
      return false;
    }

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // Create a Report object with media
    final report = Report(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: state.category?.name ?? 'Unknown',
      location: state.location,
      status: 'Pending',
      referenceNumber: 'REF${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      media: state.media,
      description: state.description,
    );

    // Add to in-memory reports list
    ref.read(reportsProvider.notifier).addReportFromForm(report);

    resetForm();
    return true;
  }
}

/// Provider for the report form Provider
final reportFormProvider =
    StateNotifierProvider<ReportFormProvider, ReportFormData>(
      (ref) => ReportFormProvider(),
    );

/// Provider for form validation state
final isFormValidProvider = Provider<bool>((ref) {
  final formData = ref.watch(reportFormProvider);
  return formData.isValid;
});

/// Provider for checking if "Other" category is selected
final isOtherCategorySelectedProvider = Provider<bool>((ref) {
  final formData = ref.watch(reportFormProvider);
  return formData.category?.id == 'other';
});

/// Provider for form submission state
final isSubmittingProvider = StateProvider<bool>((ref) => false);
