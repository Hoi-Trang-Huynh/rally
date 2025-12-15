import 'package:flutter/material.dart';
import 'package:rally/i18n/generated/translations.g.dart';
import 'package:rally/utils/validation_constants.dart';

/// A widget that displays password requirements with real-time validation.
///
/// Shows a list of password rules with icons that change from gray to green
/// as the user types and meets each requirement.
class PasswordRequirements extends StatelessWidget {
  /// Creates a new [PasswordRequirements] widget.
  const PasswordRequirements({super.key, required this.password});

  /// The current password value to validate against.
  final String password;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _PasswordRuleItem(
          text: t.validation.passwordRule.minLength(minLength: PasswordValidation.minLength),
          isMet: PasswordValidation.hasMinLength(password),
          colorScheme: colorScheme,
        ),
        _PasswordRuleItem(
          text: t.validation.passwordRule.uppercase,
          isMet: PasswordValidation.hasUppercase(password),
          colorScheme: colorScheme,
        ),
        _PasswordRuleItem(
          text: t.validation.passwordRule.lowercase,
          isMet: PasswordValidation.hasLowercase(password),
          colorScheme: colorScheme,
        ),
        _PasswordRuleItem(
          text: t.validation.passwordRule.number,
          isMet: PasswordValidation.hasDigit(password),
          colorScheme: colorScheme,
        ),
      ],
    );
  }
}

/// A single password rule item with icon and text.
class _PasswordRuleItem extends StatelessWidget {
  const _PasswordRuleItem({required this.text, required this.isMet, required this.colorScheme});

  final String text;
  final bool isMet;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: <Widget>[
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 18,
            color: isMet ? Colors.green : colorScheme.outline,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isMet ? Colors.green : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
