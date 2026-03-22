import 'package:flutter/material.dart';
import 'package:rally/i18n/generated/translations.g.dart';
import 'package:rally/models/enums.dart';
import 'package:rally/themes/app_colors.dart';

/// Helper to get translated text and status-related colors from [ParticipationStatus].
class ParticipationStatusHelper {
  /// Returns the background color for the status badge.
  static Color statusColor(ParticipationStatus status, ColorScheme colorScheme) {
    switch (status) {
      case ParticipationStatus.invited:
        return colorScheme.surfaceContainerHighest;
      case ParticipationStatus.joined:
        return AppColors.statusActiveBg; // Reusing active styling for joined
      case ParticipationStatus.declined:
      case ParticipationStatus.left:
        return colorScheme.errorContainer;
    }
  }

  /// Returns the foreground (text) color for the status badge.
  static Color statusTextColor(ParticipationStatus status, ColorScheme colorScheme) {
    switch (status) {
      case ParticipationStatus.invited:
        return colorScheme.onSurfaceVariant;
      case ParticipationStatus.joined:
        return AppColors.statusActiveText; // Reusing active styling for joined
      case ParticipationStatus.declined:
      case ParticipationStatus.left:
        return colorScheme.onErrorContainer;
    }
  }

  /// Returns the translated label for the given [ParticipationStatus].
  static String statusLabel(ParticipationStatus status, Translations t) {
    switch (status) {
      case ParticipationStatus.invited:
        return t.rally.common.participationStatus.invited;
      case ParticipationStatus.joined:
        return t.rally.common.participationStatus.joined;
      case ParticipationStatus.declined:
        return t.rally.common.participationStatus.declined;
      case ParticipationStatus.left:
        return t.rally.common.participationStatus.left;
    }
  }
}
