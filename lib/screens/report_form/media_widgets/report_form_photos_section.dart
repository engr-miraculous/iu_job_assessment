import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iu_job_assessment/models/media_models.dart';
import 'package:iu_job_assessment/screens/report_form/media_widgets/media_field.dart';

class ReportFormPhotosSection extends ConsumerStatefulWidget {
  final Function(List<MediaItem>) onPhotosChanged;
  final String? Function(List<MediaItem>?)? validator;
  final List<MediaItem> initialPhotos;
  final bool enabled;

  const ReportFormPhotosSection({
    super.key,
    required this.onPhotosChanged,
    this.validator,
    this.initialPhotos = const [],
    this.enabled = true,
  });

  @override
  ConsumerState<ReportFormPhotosSection> createState() =>
      _ReportFormPhotosSectionState();
}

class _ReportFormPhotosSectionState
    extends ConsumerState<ReportFormPhotosSection> {
  final GlobalKey<MediaFieldState> _photosFieldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Media (optional)'),
        const SizedBox(height: 8),
        MediaField(
          key: _photosFieldKey,
          initialMedia: widget.initialPhotos,
          onMediaChanged: widget.onPhotosChanged,
          validator: widget.validator,
          enabled: widget.enabled,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade800,
      ),
    );
  }

  // Method to trigger validation externally
  String? validate() {
    return _photosFieldKey.currentState?.validate();
  }

  // Method to clear validation error
  void clearValidationError() {
    _photosFieldKey.currentState?.clearValidationError();
  }
}
