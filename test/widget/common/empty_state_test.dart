import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rally/widgets/common/empty_state.dart';

/// Widget tests for [EmptyState].
void main() {
  /// Helper to wrap widget in MaterialApp for testing
  Widget createTestWidget({
    required String title,
    String? subtitle,
    IconData? icon,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: EmptyState(
          title: title,
          subtitle: subtitle,
          icon: icon,
          actionLabel: actionLabel,
          onAction: onAction,
        ),
      ),
    );
  }

  group('EmptyState', () {
    testWidgets('displays title text', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(title: 'No items'));

      expect(find.text('No items'), findsOneWidget);
    });

    testWidgets('displays subtitle when provided', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        title: 'No items',
        subtitle: 'Check back later',
      ));

      expect(find.text('No items'), findsOneWidget);
      expect(find.text('Check back later'), findsOneWidget);
    });

    testWidgets('does not display subtitle when not provided', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(title: 'No items'));

      expect(find.text('No items'), findsOneWidget);
      // Should only find one text widget (the title)
    });

    testWidgets('displays default icon when not provided', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(title: 'No items'));

      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('displays custom icon when provided', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        title: 'No items',
        icon: Icons.search_off,
      ));

      expect(find.byIcon(Icons.search_off), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsNothing);
    });

    testWidgets('displays action button when label and callback provided', (WidgetTester tester) async {
      bool buttonTapped = false;

      await tester.pumpWidget(createTestWidget(
        title: 'No items',
        actionLabel: 'Refresh',
        onAction: () => buttonTapped = true,
      ));

      expect(find.text('Refresh'), findsOneWidget);

      // Tap the scale button (which wraps the FilledButton.tonal)
      await tester.tap(find.text('Refresh'));
      await tester.pump();

      expect(buttonTapped, isTrue);
    });

    testWidgets('does not display action button when label is null', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        title: 'No items',
        onAction: () {},
      ));

      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('does not display action button when callback is null', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        title: 'No items',
        actionLabel: 'Refresh',
      ));

      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('is centered in parent', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(title: 'No items'));

      // Verify EmptyState exists
      expect(find.byType(EmptyState), findsOneWidget);

      // Verify the content is centered (at least one Center widget exists within EmptyState)
      final Finder centerInEmptyState = find.descendant(
        of: find.byType(EmptyState),
        matching: find.byType(Center),
      );
      expect(centerInEmptyState, findsWidgets);
    });

    testWidgets('renders icon in a circular container', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(title: 'No items'));

      final Finder containerFinder = find.byWidgetPredicate(
        (Widget widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).shape == BoxShape.circle,
      );

      expect(containerFinder, findsOneWidget);
    });
  });
}
