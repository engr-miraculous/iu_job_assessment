import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iu_job_assessment/models/report_model.dart';

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

  /// Update photos list
  void updatePhotos(List<String> photos) {
    state = state.copyWith(photos: photos);
  }

  /// Add a photo to the list
  void addPhoto(String photoPath) {
    final updatedPhotos = [...state.photos, photoPath];
    state = state.copyWith(photos: updatedPhotos);
  }

  /// Remove a photo from the list
  void removePhoto(String photoPath) {
    final updatedPhotos = state.photos
        .where((photo) => photo != photoPath)
        .toList();
    state = state.copyWith(photos: updatedPhotos);
  }

  /// Reset form to initial state
  void resetForm() {
    state = const ReportFormData();
  }

  /// Submit the report (mock implementation)
  Future<bool> submitReport() async {
    if (!state.isValid) {
      return false;
    }

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock successful submission
    // In a real app, this would make an API call
    resetForm();
    return true;
  }
}

/// Provider for the report form controller
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
