import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rally/widgets/common/empty_state.dart';
import 'package:rally/widgets/common/error_state.dart';

/// Widget tests for [ErrorState].
void main() {
  /// Helper to wrap widget in MaterialApp for testing
  Widget createTestWidget({
    required String error,
    VoidCallback? onRetry,
    String? retryLabel,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ErrorState(
          error: error,
          onRetry: onRetry,
          retryLabel: retryLabel,
        ),
      ),
    );
  }

  group('ErrorState', () {
    testWidgets('displays "Oops!" title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(error: 'Something went wrong'));

      expect(find.text('Oops!'), findsOneWidget);
    });

    testWidgets('displays error message as subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(error: 'Network error'));

      expect(find.text('Network error'), findsOneWidget);
    });

    testWidgets('displays error_outline_rounded icon', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(error: 'Error'));

      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('displays default "Retry" button label', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        error: 'Error',
        onRetry: () {},
      ));

      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('displays custom retry label when provided', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        error: 'Error',
        onRetry: () {},
        retryLabel: 'Try Again',
      ));

      expect(find.text('Try Again'), findsOneWidget);
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('calls onRetry when retry button tapped', (WidgetTester tester) async {
      bool retryTapped = false;

      await tester.pumpWidget(createTestWidget(
        error: 'Error',
        onRetry: () => retryTapped = true,
      ));

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(retryTapped, isTrue);
    });

    testWidgets('wraps EmptyState internally', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(error: 'Error'));

      expect(find.byType(EmptyState), findsOneWidget);
    });

    testWidgets('does not show retry button when onRetry is null', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(error: 'Error'));

      expect(find.byType(FilledButton), findsNothing);
    });
  });
}
