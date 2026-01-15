import 'package:flutter/material.dart';

import '../utils/responsive.dart';

/// Responsive spacing constants for consistent layout across the app.
///
/// All spacing values scale based on screen size using [Responsive].
/// Use these instead of hardcoded pixel values for padding and margins.
///
/// Usage:
/// ```dart
/// Padding(
///   padding: AppSpacing.screenPadding(context),
///   child: ...
/// )
/// ```
class AppSpacing {
  /// Extra small spacing (4dp base).
  static double xs(BuildContext context) => Responsive.w(context, 4);

  /// Small spacing (8dp base).
  static double sm(BuildContext context) => Responsive.w(context, 8);

  /// Medium spacing (16dp base).
  static double md(BuildContext context) => Responsive.w(context, 16);

  /// Large spacing (24dp base).
  static double lg(BuildContext context) => Responsive.w(context, 24);

  /// Extra large spacing (32dp base).
  static double xl(BuildContext context) => Responsive.w(context, 32);

  /// Extra extra large spacing (48dp base).
  static double xxl(BuildContext context) => Responsive.w(context, 48);

  // ─────────────────────────────────────────────────────────────────────────
  // Common Edge Insets
  // ─────────────────────────────────────────────────────────────────────────

  /// Standard screen padding (horizontal: 24, vertical: 16).
  static EdgeInsets screenPadding(BuildContext context) => EdgeInsets.symmetric(
    horizontal: Responsive.w(context, 24),
    vertical: Responsive.h(context, 16),
  );

  /// Horizontal-only screen padding (24dp each side).
  static EdgeInsets screenPaddingHorizontal(BuildContext context) =>
      EdgeInsets.symmetric(horizontal: Responsive.w(context, 24));

  /// Card content padding (16dp all sides).
  static EdgeInsets cardPadding(BuildContext context) => EdgeInsets.all(Responsive.w(context, 16));

  /// List item padding (horizontal: 16, vertical: 12).
  static EdgeInsets listItemPadding(BuildContext context) => EdgeInsets.symmetric(
    horizontal: Responsive.w(context, 16),
    vertical: Responsive.h(context, 12),
  );

  /// Button content padding (horizontal: 24, vertical: 16).
  static EdgeInsets buttonPadding(BuildContext context) => EdgeInsets.symmetric(
    horizontal: Responsive.w(context, 24),
    vertical: Responsive.h(context, 16),
  );

  /// Input field content padding (horizontal: 16, vertical: 16).
  static EdgeInsets inputPadding(BuildContext context) => EdgeInsets.symmetric(
    horizontal: Responsive.w(context, 16),
    vertical: Responsive.h(context, 16),
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Vertical Spacing Widgets
  // ─────────────────────────────────────────────────────────────────────────

  /// Extra small vertical gap (4dp base).
  static Widget vXs(BuildContext context) => SizedBox(height: Responsive.h(context, 4));

  /// Small vertical gap (8dp base).
  static Widget vSm(BuildContext context) => SizedBox(height: Responsive.h(context, 8));

  /// Medium vertical gap (16dp base).
  static Widget vMd(BuildContext context) => SizedBox(height: Responsive.h(context, 16));

  /// Large vertical gap (24dp base).
  static Widget vLg(BuildContext context) => SizedBox(height: Responsive.h(context, 24));

  /// Extra large vertical gap (32dp base).
  static Widget vXl(BuildContext context) => SizedBox(height: Responsive.h(context, 32));

  // ─────────────────────────────────────────────────────────────────────────
  // Horizontal Spacing Widgets
  // ─────────────────────────────────────────────────────────────────────────

  /// Extra small horizontal gap (4dp base).
  static Widget hXs(BuildContext context) => SizedBox(width: Responsive.w(context, 4));

  /// Small horizontal gap (8dp base).
  static Widget hSm(BuildContext context) => SizedBox(width: Responsive.w(context, 8));

  /// Medium horizontal gap (16dp base).
  static Widget hMd(BuildContext context) => SizedBox(width: Responsive.w(context, 16));

  /// Large horizontal gap (24dp base).
  static Widget hLg(BuildContext context) => SizedBox(width: Responsive.w(context, 24));
}
