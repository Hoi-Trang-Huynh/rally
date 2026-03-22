import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// A widget that renders rich text content (Quill Delta JSON) or plain text.
class RallyRichTextViewer extends StatefulWidget {
  /// The content to display. Can be a JSON string (Quill Delta) or plain text.
  final String content;

  /// Optional text style for the fallback plain text.
  final TextStyle? style;

  /// Creates a [RallyRichTextViewer].
  const RallyRichTextViewer({super.key, required this.content, this.style});

  @override
  State<RallyRichTextViewer> createState() => _RallyRichTextViewerState();
}

class _RallyRichTextViewerState extends State<RallyRichTextViewer> {
  QuillController? _controller;
  bool _isRichText = false;

  @override
  void initState() {
    super.initState();
    _parseContent();
  }

  @override
  void didUpdateWidget(covariant RallyRichTextViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content) {
      _parseContent();
    }
  }

  void _parseContent() {
    try {
      if (widget.content.trim().startsWith('[') || widget.content.trim().startsWith('{')) {
        final dynamic json = jsonDecode(widget.content);
        final Document doc = Document.fromJson(json as List<dynamic>);
        _controller = QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true,
        );
        _isRichText = true;
      } else {
        _isRichText = false;
      }
    } catch (e) {
      // Fallback to plain text if parsing fails
      _isRichText = false;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isRichText && _controller != null) {
      return QuillEditor.basic(
        controller: _controller!,
        config: QuillEditorConfig(
          autoFocus: false,
          expands: false,
          padding: EdgeInsets.zero,
          scrollable: false, // Let parent scroll
          customStyles: DefaultStyles(
            paragraph: DefaultTextBlockStyle(
              widget.style ?? Theme.of(context).textTheme.bodyLarge!,
              HorizontalSpacing.zero,
              VerticalSpacing.zero,
              VerticalSpacing.zero,
              null,
            ),
          ),
        ),
      );
    }

    return Text(widget.content, style: widget.style ?? Theme.of(context).textTheme.bodyLarge);
  }
}
