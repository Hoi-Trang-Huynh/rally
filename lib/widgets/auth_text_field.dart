import 'package:flutter/material.dart';

/// A standardized text field used in auth screens.
///
/// Supports password visibility toggle when [obscureText] is true.
class AuthTextField extends StatefulWidget {
  /// Creates a new [AuthTextField].
  const AuthTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
  });

  /// The text editing controller.
  final TextEditingController controller;

  /// The label text for the field.
  final String labelText;

  /// Error text to display below the field.
  final String? errorText;

  /// Whether to obscure text (for passwords).
  final bool obscureText;

  /// The keyboard type for the field.
  final TextInputType? keyboardType;

  /// Callback when text changes.
  final ValueChanged<String>? onChanged;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return TextField(
      controller: widget.controller,
      obscureText: widget.obscureText && _obscured,
      keyboardType: widget.keyboardType,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: widget.labelText,
        border: const OutlineInputBorder(),
        errorText: widget.errorText,
        suffixIcon:
            widget.obscureText
                ? IconButton(
                  icon: Icon(
                    _obscured ? Icons.visibility_off : Icons.visibility,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscured = !_obscured;
                    });
                  },
                )
                : null,
      ),
    );
  }
}
