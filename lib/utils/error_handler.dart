import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rally/services/api_client.dart';

/// Global error handler for the Rally application.
///
/// Provides centralized error handling for:
/// - Flutter framework errors
/// - Dart async errors
/// - API errors
///
/// Usage:
/// ```dart
/// void main() {
///   ErrorHandler.initialize();
///   runApp(MyApp());
/// }
/// ```
class ErrorHandler {
  ErrorHandler._();

  static bool _initialized = false;

  /// List of error listeners for custom error handling.
  static final List<void Function(Object error, StackTrace? stack)> _listeners =
      <void Function(Object error, StackTrace? stack)>[];

  /// Initializes global error handling.
  ///
  /// Should be called once at app startup, before [runApp].
  static void initialize() {
    if (_initialized) return;
    _initialized = true;

    // Handle Flutter framework errors
    FlutterError.onError = _handleFlutterError;

    // Handle errors not caught by Flutter (async errors in zones)
    PlatformDispatcher.instance.onError = _handlePlatformError;
  }

  /// Adds a listener for error events.
  ///
  /// Useful for analytics or crash reporting services.
  static void addListener(void Function(Object error, StackTrace? stack) listener) {
    _listeners.add(listener);
  }

  /// Removes a previously added listener.
  static void removeListener(void Function(Object error, StackTrace? stack) listener) {
    _listeners.remove(listener);
  }

  /// Handles Flutter framework errors.
  static void _handleFlutterError(FlutterErrorDetails details) {
    // Log to console in debug mode
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    }

    // Notify listeners
    _notifyListeners(details.exception, details.stack);

    // Log structured error
    _logError(
      'FlutterError',
      details.exception,
      details.stack,
      context: details.context?.toString(),
    );
  }

  /// Handles platform errors (uncaught async errors).
  static bool _handlePlatformError(Object error, StackTrace stack) {
    // Log to console in debug mode
    if (kDebugMode) {
      debugPrint('Platform Error: $error');
      debugPrint('Stack trace:\n$stack');
    }

    // Notify listeners
    _notifyListeners(error, stack);

    // Log structured error
    _logError('PlatformError', error, stack);

    // Return true to prevent the error from propagating
    // Return false to let it propagate (crash in release mode)
    return true;
  }

  /// Handles errors manually reported from the app.
  ///
  /// Use this to report caught errors that should be logged.
  static void reportError(
    Object error, {
    StackTrace? stack,
    String? context,
  }) {
    // Get stack trace if not provided
    stack ??= StackTrace.current;

    // Notify listeners
    _notifyListeners(error, stack);

    // Log structured error
    _logError('ReportedError', error, stack, context: context);
  }

  /// Logs an error with structured information.
  static void _logError(
    String type,
    Object error,
    StackTrace? stack, {
    String? context,
  }) {
    final StringBuffer buffer = StringBuffer()
      ..writeln('═══════════════════════════════════════════════════════════')
      ..writeln('ERROR [$type]')
      ..writeln('═══════════════════════════════════════════════════════════')
      ..writeln('Time: ${DateTime.now().toIso8601String()}')
      ..writeln('Error: $error')
      ..writeln('Type: ${error.runtimeType}');

    if (context != null) {
      buffer.writeln('Context: $context');
    }

    // Add specific info for known error types
    if (error is ApiException) {
      buffer
        ..writeln('API Status Code: ${error.statusCode}')
        ..writeln('API Message: ${error.message}');
    }

    if (stack != null) {
      buffer
        ..writeln('───────────────────────────────────────────────────────────')
        ..writeln('Stack Trace:')
        ..writeln(stack.toString().split('\n').take(10).join('\n'))
        ..writeln('... (truncated)');
    }

    buffer.writeln('═══════════════════════════════════════════════════════════');

    debugPrint(buffer.toString());
  }

  /// Notifies all registered listeners of an error.
  static void _notifyListeners(Object error, StackTrace? stack) {
    for (final void Function(Object error, StackTrace? stack) listener in _listeners) {
      try {
        listener(error, stack);
      } catch (e) {
        // Prevent listener errors from causing cascading failures
        debugPrint('Error in error listener: $e');
      }
    }
  }

  /// Runs a function in an error-handling zone.
  ///
  /// Useful for wrapping initialization code or critical sections.
  static Future<T?> runGuarded<T>(Future<T> Function() fn, {String? context}) async {
    try {
      return await fn();
    } catch (error, stack) {
      reportError(error, stack: stack, context: context);
      return null;
    }
  }

  /// Runs a synchronous function with error handling.
  static T? runGuardedSync<T>(T Function() fn, {String? context}) {
    try {
      return fn();
    } catch (error, stack) {
      reportError(error, stack: stack, context: context);
      return null;
    }
  }
}

/// Extension on [BuildContext] for showing error snackbars.
extension ErrorSnackbar on BuildContext {
  /// Shows an error snackbar with optional retry action.
  void showErrorSnackbar(
    String message, {
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 4),
  }) {
    final ThemeData theme = Theme.of(this);

    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: theme.colorScheme.error,
        duration: duration,
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: theme.colorScheme.onError,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  /// Shows a user-friendly error message based on the error type.
  void showErrorForException(Object error, {VoidCallback? onRetry}) {
    String message;

    if (error is ApiException) {
      switch (error.statusCode) {
        case 401:
          message = 'Session expired. Please log in again.';
        case 403:
          message = 'You don\'t have permission to do this.';
        case 404:
          message = 'The requested item was not found.';
        case 429:
          message = 'Too many requests. Please wait a moment.';
        case >= 500:
          message = 'Server error. Please try again later.';
        default:
          message = error.message;
      }
    } else if (error is TimeoutException) {
      message = 'Request timed out. Please check your connection.';
    } else {
      message = 'Something went wrong. Please try again.';
    }

    showErrorSnackbar(message, onRetry: onRetry);
  }
}
