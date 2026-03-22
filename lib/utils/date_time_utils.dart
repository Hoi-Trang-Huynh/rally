import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rally/i18n/generated/translations.g.dart';

/// Utility class for date and time formatting.
class DateTimeUtils {
  /// Returns a localized relative time string (e.g., "Updated 2h ago").
  static String formatRelativeTime(BuildContext context, DateTime dateTime) {
    final Duration difference = DateTime.now().difference(dateTime);
    final Translations t = Translations.of(context);

    if (difference.inDays > 365) {
      final int years = (difference.inDays / 365).floor();
      return t.rally.common.timeAgo.years.replaceAll('{count}', years.toString());
    } else if (difference.inDays > 30) {
      final int months = (difference.inDays / 30).floor();
      return t.rally.common.timeAgo.months.replaceAll('{count}', months.toString());
    } else if (difference.inDays > 0) {
      return t.rally.common.timeAgo.days.replaceAll('{count}', difference.inDays.toString());
    } else if (difference.inHours > 0) {
      return t.rally.common.timeAgo.hours.replaceAll('{count}', difference.inHours.toString());
    } else if (difference.inMinutes > 0) {
      return t.rally.common.timeAgo.minutes.replaceAll('{count}', difference.inMinutes.toString());
    } else {
      return t.rally.common.timeAgo.justNow;
    }
  }

  /// Returns a formatted date range (e.g., "Apr 29 - May 5").
  static String formatDateRange(DateTime start, DateTime end, {String format = 'MMM d'}) {
    final DateFormat formatter = DateFormat(format);
    return '${formatter.format(start)} - ${formatter.format(end)}';
  }

  /// Returns a localized greeting based on the current time of day.
  static String getGreeting(BuildContext context) {
    final int hour = DateTime.now().hour;
    final Translations t = Translations.of(context);

    if (hour < 12) {
      return t.rally.common.greeting.morning;
    } else if (hour < 17) {
      return t.rally.common.greeting.afternoon;
    } else {
      return t.rally.common.greeting.evening;
    }
  }
}
