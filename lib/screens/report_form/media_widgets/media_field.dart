import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iu_job_assessment/models/media_models.dart';
import 'package:iu_job_assessment/providers/media_provider.dart';
import 'package:iu_job_assessment/screens/report_form/media_widgets/media_grid_widget.dart';
import 'package:iu_job_assessment/screens/report_form/media_widgets/media_source_bottom_sheet.dart';

class MediaField extends ConsumerStatefulWidget {
  final List<MediaItem> initialMedia;
  final Function(List<MediaItem>) onMediaChanged;
  final String? Function(List<MediaItem>?)? validator;
  final bool enabled;

  const MediaField({
    super.key,
    this.initialMedia = const [],
    required this.onMediaChanged,
    this.validator,
    this.enabled = true,
  });

  @override
  ConsumerState<MediaField> createState() => MediaFieldState();
}

class MediaFieldState extends ConsumerState<MediaField> {
  String? _errorText;

  @override
  void initState() {
    super.initState();
    // Set initial media if provided
    if (widget.initialMedia.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(mediaProvider.notifier).setInitialMedia(widget.initialMedia);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to media state changes
    ref.listen<MediaState>(mediaProvider, (previous, next) {
      // Notify parent of media changes
      widget.onMediaChanged(next.items);

      // Handle validation
      if (widget.validator != null) {
        final error = widget.validator!(next.items);
        setState(() {
          _errorText = error;
        });
      }

      // Show error snackbar if there's an error
      if (next.error != null && previous?.error != next.error) {
        _showErrorSnackBar(next.error!);
        ref.read(mediaProvider.notifier).clearError();
      }
    });

    final mediaState = ref.watch(mediaProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Media grid with add button
        MediaGridWidget(
          mediaItems: mediaState.items,
          showAddButton: widget.enabled,
          onAddPressed: widget.enabled ? _showMediaSourceBottomSheet : null,
        ),

        // Loading indicator
        if (mediaState.isLoading) ...[
          const SizedBox(height: 16),
          const Center(child: CircularProgressIndicator()),
        ],

        // Validation error
        if (_errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            _errorText!,
            style: TextStyle(color: Colors.red.shade600, fontSize: 12),
          ),
        ],
      ],
    );
  }

  void _showMediaSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const MediaSourceBottomSheet(),
    );
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Method to trigger validation externally (e.g., on form submit)
  String? validate() {
    if (widget.validator != null) {
      final mediaItems = ref.read(mediaItemsProvider);
      final error = widget.validator!(mediaItems);
      setState(() {
        _errorText = error;
      });
      return error;
    }
    return null;
  }

  // Method to clear validation error
  void clearValidationError() {
    setState(() {
      _errorText = null;
    });
  }
}
