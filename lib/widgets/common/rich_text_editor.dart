import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:rally/utils/responsive.dart';

/// A reusable rich text editor widget with an inline compact toolbar.
///
/// Supports: Bold, Italic, Bullet List, Numbered List.
/// The toolbar is positioned inside the text box for a cleaner UI.
class RichTextEditor extends StatefulWidget {
  /// Creates a new [RichTextEditor].
  const RichTextEditor({
    required this.controller,
    this.hintText = '',
    this.maxLines = 6,
    this.minLines = 3,
    this.focusNode,
    this.readOnly = false,
    this.showToolbar = true,
    this.toolbarPosition = ToolbarPosition.top,
    super.key,
  });

  /// The Quill controller for managing editor content.
  final QuillController controller;

  /// Placeholder text when the editor is empty.
  final String hintText;

  /// Maximum number of lines to display.
  final int maxLines;

  /// Minimum number of lines to display.
  final int minLines;

  /// Optional focus node for the editor.
  final FocusNode? focusNode;

  /// Whether the editor is read-only.
  final bool readOnly;

  /// Whether to show the formatting toolbar.
  final bool showToolbar;

  /// Position of the toolbar (top or bottom of editor).
  final ToolbarPosition toolbarPosition;

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

/// Position of the toolbar within the editor.
enum ToolbarPosition {
  /// Toolbar at the top of the editor.
  top,

  /// Toolbar at the bottom of the editor.
  bottom,
}

class _RichTextEditorState extends State<RichTextEditor> {
  @override
  void initState() {
    super.initState();
    // Listen to controller changes to update toolbar button states
    widget.controller.addListener(_onControllerChange);
  }

  @override
  void didUpdateWidget(covariant RichTextEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChange);
      widget.controller.addListener(_onControllerChange);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChange);
    super.dispose();
  }

  void _onControllerChange() {
    // Trigger rebuild to update toolbar button active states
    if (mounted) {
      setState(() {});
    }
  }

  bool _isAttributeActive(Attribute<dynamic> attribute) {
    final Style style = widget.controller.getSelectionStyle();
    if (attribute == Attribute.ul) {
      return style.attributes.containsKey(Attribute.list.key) &&
          style.attributes[Attribute.list.key]?.value == 'bullet';
    }
    if (attribute == Attribute.ol) {
      return style.attributes.containsKey(Attribute.list.key) &&
          style.attributes[Attribute.list.key]?.value == 'ordered';
    }
    return style.attributes.containsKey(attribute.key);
  }

  void _toggleAttribute(Attribute<dynamic> attribute) {
    if (attribute == Attribute.ul || attribute == Attribute.ol) {
      final bool isActive = _isAttributeActive(attribute);
      if (isActive) {
        widget.controller.formatSelection(Attribute.clone(Attribute.list, null));
      } else {
        widget.controller.formatSelection(attribute);
      }
    } else {
      final bool isActive = _isAttributeActive(attribute);
      widget.controller.formatSelection(isActive ? Attribute.clone(attribute, null) : attribute);
    }
    // Force rebuild after toggling to reflect changes immediately
    setState(() {});
  }

  Widget _buildToolbar(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(context, 8),
        vertical: Responsive.h(context, 6),
      ),
      decoration: BoxDecoration(
        border:
            widget.toolbarPosition == ToolbarPosition.top
                ? Border(bottom: BorderSide(color: colorScheme.outline.withValues(alpha: 0.15)))
                : Border(top: BorderSide(color: colorScheme.outline.withValues(alpha: 0.15))),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _ToolbarButton(
            icon: Icons.format_bold,
            isActive: _isAttributeActive(Attribute.bold),
            onTap: () => _toggleAttribute(Attribute.bold),
          ),
          _ToolbarButton(
            icon: Icons.format_italic,
            isActive: _isAttributeActive(Attribute.italic),
            onTap: () => _toggleAttribute(Attribute.italic),
          ),
          SizedBox(width: Responsive.w(context, 4)),
          Container(
            width: 1,
            height: Responsive.h(context, 20),
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
          SizedBox(width: Responsive.w(context, 4)),
          _ToolbarButton(
            icon: Icons.format_list_bulleted,
            isActive: _isAttributeActive(Attribute.ul),
            onTap: () => _toggleAttribute(Attribute.ul),
          ),
          _ToolbarButton(
            icon: Icons.format_list_numbered,
            isActive: _isAttributeActive(Attribute.ol),
            onTap: () => _toggleAttribute(Attribute.ol),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final bool showToolbarWidget = widget.showToolbar && !widget.readOnly;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Toolbar at top
          if (showToolbarWidget && widget.toolbarPosition == ToolbarPosition.top)
            _buildToolbar(colorScheme),

          // Editor
          Container(
            constraints: BoxConstraints(
              minHeight: Responsive.h(context, widget.minLines * 24),
              maxHeight: Responsive.h(context, widget.maxLines * 24),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.w(context, 16),
              vertical: Responsive.h(context, 12),
            ),
            child: QuillEditor.basic(
              controller: widget.controller,
              focusNode: widget.focusNode,
              config: QuillEditorConfig(
                placeholder: widget.hintText,
                padding: EdgeInsets.zero,
                expands: false,
                autoFocus: false,
                scrollable: true,
                customStyles: DefaultStyles(
                  paragraph: DefaultTextBlockStyle(
                    textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface) ??
                        const TextStyle(),
                    HorizontalSpacing.zero,
                    VerticalSpacing.zero,
                    VerticalSpacing.zero,
                    null,
                  ),
                  placeHolder: DefaultTextBlockStyle(
                    textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ) ??
                        const TextStyle(),
                    HorizontalSpacing.zero,
                    VerticalSpacing.zero,
                    VerticalSpacing.zero,
                    null,
                  ),
                ),
              ),
            ),
          ),

          // Toolbar at bottom
          if (showToolbarWidget && widget.toolbarPosition == ToolbarPosition.bottom)
            _buildToolbar(colorScheme),
        ],
      ),
    );
  }
}

/// A single toolbar button with active state indication.
class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({required this.icon, required this.isActive, required this.onTap});

  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Responsive.w(context, 6)),
        child: Container(
          padding: EdgeInsets.all(Responsive.w(context, 8)),
          decoration: BoxDecoration(
            color: isActive ? colorScheme.primary.withValues(alpha: 0.15) : null,
            borderRadius: BorderRadius.circular(Responsive.w(context, 6)),
          ),
          child: Icon(
            icon,
            size: Responsive.w(context, 18),
            color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
