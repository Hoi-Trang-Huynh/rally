import 'package:flutter/material.dart';
import 'package:rally/i18n/generated/translations.g.dart';
import 'package:rally/models/enums.dart';

/// Helper to get translated text and role-related colors from [ParticipantRole].
class ParticipantRoleHelper {
  /// Returns the background color for the role badge.
  static Color roleColor(ParticipantRole role, ColorScheme colorScheme) {
    switch (role) {
      case ParticipantRole.owner:
        return colorScheme.primaryContainer;
      case ParticipantRole.editor:
        return colorScheme.secondaryContainer;
      case ParticipantRole.participant:
        return colorScheme.surfaceContainerHighest;
    }
  }

  /// Returns the foreground (text) color for the role badge.
  static Color roleTextColor(ParticipantRole role, ColorScheme colorScheme) {
    switch (role) {
      case ParticipantRole.owner:
        return colorScheme.onPrimaryContainer;
      case ParticipantRole.editor:
        return colorScheme.onSecondaryContainer;
      case ParticipantRole.participant:
        return colorScheme.onSurfaceVariant;
    }
  }

  /// Returns the translated label for the given [ParticipantRole].
  static String roleLabel(ParticipantRole role, Translations t) {
    switch (role) {
      case ParticipantRole.owner:
        return t.rally.common.role.owner;
      case ParticipantRole.editor:
        return t.rally.common.role.editor;
      case ParticipantRole.participant:
        return t.rally.common.role.participant;
    }
  }
}
