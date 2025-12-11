import 'package:flutter/material.dart';

/// AppTextStyles provides text style definitions for the Rally app.
///
/// Includes label, paragraph, headline, and overline styles, using the app's color scheme.
class AppTextStyles {
  // Heading Styles
  /// Heading H1 style (fontSize: 36, lineHeight: 44, -2% tracking).
  /// Used for the largest page titles and hero text.
  static TextStyle headingH1(BuildContext context) {
    return TextStyle(
      fontSize: 36,
      height: 44 / 36,
      letterSpacing: -0.02 * 36, // -2% tracking
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Heading H2 style (fontSize: 32, lineHeight: 40, -2% tracking).
  /// Used for major section headers and large titles.
  static TextStyle headingH2(BuildContext context) {
    return TextStyle(
      fontSize: 32,
      height: 40 / 32,
      letterSpacing: -0.02 * 32, // -2% tracking
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Heading H3 style (fontSize: 28, lineHeight: 36, -2% tracking).
  /// Used for sub-section headers and medium titles.
  static TextStyle headingH3(BuildContext context) {
    return TextStyle(
      fontSize: 28,
      height: 36 / 28,
      letterSpacing: -0.02 * 28, // -2% tracking
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Heading H4 style (fontSize: 24, lineHeight: 32).
  /// Used for smaller section headers and card titles.
  static TextStyle headingH4(BuildContext context) {
    return TextStyle(
      fontSize: 24,
      height: 32 / 24,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Heading H5 style (fontSize: 20, lineHeight: 28).
  /// Used for small headers and emphasized text.
  static TextStyle headingH5(BuildContext context) {
    return TextStyle(
      fontSize: 20,
      height: 28 / 20,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Heading H6 style (fontSize: 18, lineHeight: 24).
  /// Used for the smallest headers and supporting titles.
  static TextStyle headingH6(BuildContext context) {
    return TextStyle(
      fontSize: 18,
      height: 24 / 18,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Large label style (fontSize: 16, lineHeight: 18).
  /// Used for prominent labels and form fields.
  static TextStyle labelLarge(BuildContext context) {
    return TextStyle(
      fontSize: 16,
      height: 18 / 16, // lineHeight / fontSize
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Medium label style (fontSize: 14, lineHeight: 16).
  /// Used for secondary labels and UI elements.
  static TextStyle labelMedium(BuildContext context) {
    return TextStyle(
      fontSize: 14,
      height: 16 / 14,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Small label style (fontSize: 12, lineHeight: 16).
  /// Used for captions and less prominent labels.
  static TextStyle labelSmall(BuildContext context) {
    return TextStyle(
      fontSize: 12,
      height: 16 / 12,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Extra small label style (fontSize: 10, lineHeight: 14).
  /// Used for micro-labels and helper text.
  static TextStyle labelXSmall(BuildContext context) {
    return TextStyle(
      fontSize: 10,
      height: 14 / 10,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Large paragraph style (fontSize: 18, lineHeight: 28).
  /// Used for main body text and large content blocks.
  static TextStyle paragraphLarge(BuildContext context) {
    return TextStyle(
      fontSize: 18,
      height: 28 / 18,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Medium paragraph style (fontSize: 16, lineHeight: 24).
  /// Used for standard body text.
  static TextStyle paragraphMedium(BuildContext context) {
    return TextStyle(
      fontSize: 16,
      height: 24 / 16,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Small paragraph style (fontSize: 14, lineHeight: 20).
  /// Used for secondary body text and notes.
  static TextStyle paragraphSmall(BuildContext context) {
    return TextStyle(
      fontSize: 14,
      height: 20 / 14,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Extra small paragraph style (fontSize: 12, lineHeight: 20).
  /// Used for footnotes and small content blocks.
  static TextStyle paragraphXSmall(BuildContext context) {
    return TextStyle(
      fontSize: 12,
      height: 20 / 12,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Large headline style (fontSize: 28, fontWeight: bold).
  /// Used for main titles and section headers. Adapts to locale.
  static TextStyle headlineLarge(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    return TextStyle(
      fontSize: _getHeadlineSize(locale.languageCode),
      fontWeight: FontWeight.bold,
      height: 1.2,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Overline style with fontSize 14.
  /// Used for uppercase labels and section markers.
  static TextStyle overline14(BuildContext context) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.5,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Overline style with fontSize 12.
  /// Used for small uppercase labels and section markers.
  static TextStyle overline12(BuildContext context) {
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.5,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Returns the headline font size for the given language code.
  static double _getHeadlineSize(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 28.0;
      case 'vn':
        return 28.0;
      default:
        return 28.0;
    }
  }
}
