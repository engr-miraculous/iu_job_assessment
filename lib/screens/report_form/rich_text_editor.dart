import 'package:flutter/material.dart';
import 'package:iu_job_assessment/utils/app_colors.dart';

/// Rich text editor with formatting toolbar
class RichTextEditor extends StatefulWidget {
  final String? initialValue;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;

  const RichTextEditor({
    super.key,
    this.initialValue,
    this.hintText,
    this.onChanged,
    this.validator,
  });

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderline = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _controller.addListener(() {
      widget.onChanged?.call(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Formatting toolbar
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _FormatButton(
                icon: Icons.format_bold,
                isActive: _isBold,
                onPressed: () => setState(() => _isBold = !_isBold),
              ),
              _FormatButton(
                icon: Icons.format_italic,
                isActive: _isItalic,
                onPressed: () => setState(() => _isItalic = !_isItalic),
              ),
              _FormatButton(
                icon: Icons.format_underlined,
                isActive: _isUnderline,
                onPressed: () => setState(() => _isUnderline = !_isUnderline),
              ),
              _FormatButton(
                icon: Icons.format_quote,
                isActive: false,
                onPressed: () {
                  // Insert quote formatting
                  _insertText('> ');
                },
              ),
              _FormatButton(
                icon: Icons.format_list_bulleted,
                isActive: false,
                onPressed: () {
                  // Insert bullet point
                  _insertText('• ');
                },
              ),
              _FormatButton(
                icon: Icons.format_list_numbered,
                isActive: false,
                onPressed: () {
                  // Insert numbered list
                  _insertText('1. ');
                },
              ),
              _FormatButton(
                icon: Icons.link,
                isActive: false,
                onPressed: () {
                  // Insert link placeholder
                  _insertText('[Link text](url)');
                },
              ),
              _FormatButton(
                icon: Icons.image,
                isActive: false,
                onPressed: () {
                  // Insert image placeholder
                  _insertText('![Alt text](image_url)');
                },
              ),
              _FormatButton(
                icon: Icons.visibility,
                isActive: false,
                onPressed: () {
                  // Toggle preview mode
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Preview mode coming soon'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              _FormatButton(
                icon: Icons.help_outline,
                isActive: false,
                onPressed: () {
                  // Show formatting help
                  _showFormattingHelp(context);
                },
              ),
            ],
          ),
        ),
        // Text input field
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          maxLines: 8,
          minLines: 8,
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hintText ?? 'Enter description...',
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
            filled: true,
            fillColor: Colors.white,
          ),
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
      ],
    );
  }

  /// Insert text at cursor position
  void _insertText(String text) {
    final currentPosition = _controller.selection.start;
    final currentText = _controller.text;

    if (currentPosition >= 0) {
      final newText =
          currentText.substring(0, currentPosition) +
          text +
          currentText.substring(currentPosition);

      _controller.text = newText;
      _controller.selection = TextSelection.collapsed(
        offset: currentPosition + text.length,
      );
    } else {
      _controller.text = currentText + text;
    }

    _focusNode.requestFocus();
  }

  /// Show formatting help dialog
  void _showFormattingHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Formatting Help'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '**Bold text**',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '*Italic text*',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              Text('• Bullet points'),
              Text('1. Numbered lists'),
              Text('> Quotes'),
              Text('[Link text](url)'),
              Text('![Alt text](image_url)'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

/// Individual format button widget
class _FormatButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onPressed;

  const _FormatButton({
    required this.icon,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withAlpha(25) : null,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isActive ? AppColors.primary : Colors.grey.shade600,
        ),
      ),
    );
  }
}
