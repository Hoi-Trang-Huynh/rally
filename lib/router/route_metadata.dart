import 'package:flutter/material.dart';

import '../i18n/generated/translations.g.dart';
import 'app_router.dart';

/// Typedef for a function that builds breadcrumbs for a route.
/// Takes BuildContext to access translations.
typedef BreadcrumbBuilder = List<String> Function(BuildContext context);

/// Typedef for a function that builds a title for a route.
/// Takes BuildContext and the current URI to extract query parameters.
typedef TitleBuilder = String Function(BuildContext context, Uri uri);

/// Metadata for a route, containing all display and navigation information.
///
/// This centralizes route information that was previously scattered across
/// multiple methods in MainShell (breadcrumbs, title, parent route, etc.).
class RouteMetadata {
  /// Creates a new [RouteMetadata] instance.
  const RouteMetadata({
    required this.pattern,
    this.parentRoute,
    this.breadcrumbBuilder,
    this.titleBuilder,
    this.isNested = false,
  });

  /// RegExp pattern to match this route.
  final RegExp pattern;

  /// Parent route path for back navigation.
  /// If null, pressing back will use default behavior.
  final String? parentRoute;

  /// Function to build breadcrumbs for this route.
  /// If null, default breadcrumbs will be used.
  final BreadcrumbBuilder? breadcrumbBuilder;

  /// Function to build title for this route.
  /// If null, default title will be used.
  final TitleBuilder? titleBuilder;

  /// Whether this route is nested and requires special back navigation.
  final bool isNested;
}

/// Registry of all route metadata in the app.
///
/// Add new routes here instead of hardcoding in MainShell.
/// The registry is searched in order, so more specific patterns should come first.
class RouteMetadataRegistry {
  RouteMetadataRegistry._();

  /// All registered route metadata.
  /// Order matters: more specific patterns should come first.
  static final List<RouteMetadata> _routes = <RouteMetadata>[
    // Nested route: User profile under explore
    RouteMetadata(
      pattern: RegExp(r'^/explore/user/'),
      parentRoute: AppRoutes.explore,
      isNested: true,
      breadcrumbBuilder: (BuildContext context) {
        final Translations t = Translations.of(context);
        return <String>['Rally', t.nav.explore, t.nav.profile];
      },
      titleBuilder: (BuildContext context, Uri uri) {
        // Try to get username from query params
        final String? username = uri.queryParameters['username'];
        if (username != null && username.isNotEmpty) {
          return username;
        }
        // Fallback to generic profile title
        return Translations.of(context).nav.profile;
      },
    ),

    // Add more nested routes here as needed:
    // Example for future chat conversation route:
    // RouteMetadata(
    //   pattern: RegExp(r'^/chat/conversation/'),
    //   parentRoute: AppRoutes.chat,
    //   isNested: true,
    //   breadcrumbBuilder: (context) => ['Rally', t.nav.chat, 'Conversation'],
    //   titleBuilder: (context, uri) => uri.queryParameters['name'] ?? 'Chat',
    // ),
  ];

  /// Find metadata for a given location.
  /// Returns null if no matching metadata is found.
  static RouteMetadata? fromLocation(String location) {
    for (final RouteMetadata metadata in _routes) {
      if (metadata.pattern.hasMatch(location)) {
        return metadata;
      }
    }
    return null;
  }

  /// Check if a location is a nested route.
  static bool isNestedRoute(String location) {
    final RouteMetadata? metadata = fromLocation(location);
    return metadata?.isNested ?? false;
  }

  /// Get the parent route for a given location.
  /// Returns null if not a nested route or no parent defined.
  static String? getParentRoute(String location) {
    final RouteMetadata? metadata = fromLocation(location);
    return metadata?.parentRoute;
  }

  /// Get breadcrumbs for a location.
  /// Returns default breadcrumbs if no metadata found.
  static List<String> getBreadcrumbs(BuildContext context, String location) {
    final RouteMetadata? metadata = fromLocation(location);
    if (metadata?.breadcrumbBuilder != null) {
      return metadata!.breadcrumbBuilder!(context);
    }
    // Default: just Rally
    return <String>['Rally'];
  }

  /// Get title for a location.
  /// Returns null if no custom title defined (caller should use default).
  static String? getTitle(BuildContext context, String location, Uri uri) {
    final RouteMetadata? metadata = fromLocation(location);
    if (metadata?.titleBuilder != null) {
      return metadata!.titleBuilder!(context, uri);
    }
    return null;
  }
}
