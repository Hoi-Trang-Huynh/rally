import 'package:flutter/material.dart';

/// A standardized text field used in auth screens.
class AuthTextField extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        errorText: errorText,
      ),
    );
  }
}
