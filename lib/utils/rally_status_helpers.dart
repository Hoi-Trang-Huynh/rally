import 'package:flutter/material.dart';
import 'package:rally/i18n/generated/translations.g.dart';
import 'package:rally/models/enums.dart';
import 'package:rally/themes/app_colors.dart';

/// Helper to get status-related colors and translated text from [RallyStatus].
class RallyStatusHelper {
  /// Returns the background color for the status badge.
  static Color statusColor(RallyStatus status, ColorScheme colorScheme) {
    switch (status) {
      case RallyStatus.active:
        return AppColors.statusActiveBg;
      case RallyStatus.inactive:
        return AppColors.statusInactiveBg;
      case RallyStatus.completed:
        return AppColors.statusCompletedBg;
      case RallyStatus.draft:
        return colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
      case RallyStatus.archived:
        return colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
    }
  }

  /// Returns the foreground (text) color for the status badge.
  static Color statusTextColor(RallyStatus status, ColorScheme colorScheme) {
    switch (status) {
      case RallyStatus.active:
        return AppColors.statusActiveText;
      case RallyStatus.inactive:
        return AppColors.statusInactiveText;
      case RallyStatus.completed:
        return AppColors.statusCompletedText;
      case RallyStatus.draft:
        return colorScheme.onSurfaceVariant;
      case RallyStatus.archived:
        return colorScheme.onSurfaceVariant.withValues(alpha: 0.7);
    }
  }

  /// Returns the translated label for the given [RallyStatus].
  static String statusLabel(RallyStatus status, Translations t) {
    switch (status) {
      case RallyStatus.draft:
        return t.rally.status.draft;
      case RallyStatus.active:
        return t.rally.status.active;
      case RallyStatus.inactive:
        return t.rally.status.inactive;
      case RallyStatus.completed:
        return t.rally.status.completed;
      case RallyStatus.archived:
        return t.rally.status.archived;
    }
  }
}
