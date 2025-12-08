import 'dart:async';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../new/infra/testable_editor.dart';

void main() {
  group('Selection update performance test', () {
    testWidgets(
      'single paragraph without children - baseline performance test',
      (tester) async {
        // Create a single paragraph without children
        final editor = tester.editor
          ..addParagraph(initialText: 'Single paragraph');
        await editor.startTesting();

        final editorState = editor.editorState;

        // Setup selection change listener
        final selectionUpdatedCompleter = Completer<void>();
        final stopwatch = Stopwatch();

        void selectionListener() {
          if (stopwatch.isRunning && editorState.selection != null) {
            stopwatch.stop();
            selectionUpdatedCompleter.complete();
          }
        }

        editorState.selectionNotifier.addListener(selectionListener);

        // Find the paragraph (at path [0])
        final paragraph = editor.nodeAtPath([0]);
        expect(paragraph, isNotNull, reason: 'Paragraph should exist');

        final finder = find.byKey(paragraph!.key);
        expect(finder, findsOneWidget, reason: 'Paragraph should be rendered');

        final rect = tester.getRect(finder);

        // Start measuring time
        stopwatch.start();

        // Tap the paragraph
        await tester.tapAt(rect.centerLeft);
        await tester.pump(); // Pump once to process the tap

        // Wait for selection to update (with timeout)
        await selectionUpdatedCompleter.future.timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            stopwatch.stop();
            fail(
              'Selection did not update within timeout. '
              'Elapsed: ${stopwatch.elapsedMilliseconds}ms',
            );
          },
        );

        // Verify selection was updated correctly
        expect(editorState.selection, isNotNull);
        expect(editorState.selection!.start.path, [0]);

        final elapsedMs = stopwatch.elapsedMilliseconds;

        // Print the result
        debugPrint('\n${'=' * 60}');
        debugPrint('PERFORMANCE TEST RESULT - BASELINE');
        debugPrint('=' * 60);
        debugPrint('Document structure: Single paragraph (no children)');
        debugPrint('Tapped: Paragraph (path [0])');
        debugPrint('Selection update time: ${elapsedMs}ms');
        debugPrint('=' * 60 + '\n');

        // Performance assertion - should be very fast
        expect(
          elapsedMs,
          lessThan(150),
          reason: 'Single paragraph selection should be very fast (<150ms)',
        );

        // Cleanup
        editorState.selectionNotifier.removeListener(selectionListener);
        await editor.dispose();
      },
    );

    testWidgets(
      'paragraph with 1000 children - tap first child and measure selection update time',
      (tester) async {
        // Create 1000 child paragraphs
        final children = <Node>[];
        for (int i = 0; i < 1000; i++) {
          children.add(paragraphNode(text: 'Child paragraph $i'));
        }

        // Create a paragraph node with 1000 children
        final parentNode = paragraphNode(
          text: 'Parent paragraph',
          children: children,
        );

        final editor = tester.editor..addNode(parentNode);
        await editor.startTesting();

        final editorState = editor.editorState;

        // Setup selection change listener
        final selectionUpdatedCompleter = Completer<void>();
        final stopwatch = Stopwatch();

        void selectionListener() {
          if (stopwatch.isRunning && editorState.selection != null) {
            stopwatch.stop();
            selectionUpdatedCompleter.complete();
          }
        }

        editorState.selectionNotifier.addListener(selectionListener);

        // Find the first child (at path [0, 0])
        final firstChild = editor.nodeAtPath([0, 0]);
        expect(firstChild, isNotNull, reason: 'First child should exist');

        final finder = find.byKey(firstChild!.key);
        expect(
          finder,
          findsOneWidget,
          reason: 'First child should be rendered',
        );

        final rect = tester.getRect(finder);

        // Start measuring time
        stopwatch.start();

        // Tap the first child
        await tester.tapAt(rect.centerLeft);
        await tester.pump(); // Pump once to process the tap

        // Wait for selection to update (with timeout)
        await selectionUpdatedCompleter.future.timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            stopwatch.stop();
            fail(
              'Selection did not update within timeout. '
              'Elapsed: ${stopwatch.elapsedMilliseconds}ms',
            );
          },
        );

        // Verify selection was updated correctly
        expect(editorState.selection, isNotNull);
        expect(editorState.selection!.start.path, [0, 0]);

        final elapsedMs = stopwatch.elapsedMilliseconds;

        // Print the result
        debugPrint('\n${'=' * 60}');
        debugPrint('PERFORMANCE TEST RESULT');
        debugPrint('=' * 60);
        debugPrint('Total children: 1000');
        debugPrint('Tapped: First child (path [0, 0])');
        debugPrint('Selection update time: ${elapsedMs}ms');
        debugPrint('=' * 60 + '\n');

        // Performance assertion - selection should update within reasonable time
        expect(
          elapsedMs,
          lessThan(500),
          reason: 'Selection update should complete in less than 500ms',
        );

        // Cleanup
        editorState.selectionNotifier.removeListener(selectionListener);
        await editor.dispose();
      },
    );

    testWidgets(
      'paragraph with 1000 children - scroll and tap last child',
      (tester) async {
        // Create 1000 child paragraphs
        final children = <Node>[];
        for (int i = 0; i < 1000; i++) {
          children.add(paragraphNode(text: 'Child paragraph $i'));
        }

        // Create a paragraph node with 1000 children
        final parentNode = paragraphNode(
          text: 'Parent paragraph',
          children: children,
        );

        final editor = tester.editor..addNode(parentNode);
        await editor.startTesting();

        final editorState = editor.editorState;
        final scrollService = editorState.service.scrollService;

        // Scroll to the bottom to bring last child into view
        if (scrollService != null) {
          await tester.pumpAndSettle();
          scrollService.scrollTo(scrollService.maxScrollExtent);
          await tester.pumpAndSettle(const Duration(milliseconds: 500));
        }

        // Setup selection change listener
        final selectionUpdatedCompleter = Completer<void>();
        final stopwatch = Stopwatch();

        void selectionListener() {
          if (stopwatch.isRunning && editorState.selection != null) {
            stopwatch.stop();
            selectionUpdatedCompleter.complete();
          }
        }

        editorState.selectionNotifier.addListener(selectionListener);

        // Find the last child (at path [0, 999])
        final lastChild = editor.nodeAtPath([0, 999]);
        expect(lastChild, isNotNull, reason: 'Last child should exist');

        final finder = find.byKey(lastChild!.key);
        expect(finder, findsOneWidget, reason: 'Last child should be rendered');

        final rect = tester.getRect(finder);

        // Start measuring time
        stopwatch.start();

        // Tap the last child
        await tester.tapAt(rect.centerLeft);
        await tester.pump(); // Pump once to process the tap

        // Wait for selection to update (with timeout)
        await selectionUpdatedCompleter.future.timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            stopwatch.stop();
            fail(
              'Selection did not update within timeout. '
              'Elapsed: ${stopwatch.elapsedMilliseconds}ms',
            );
          },
        );

        // Verify selection was updated correctly
        expect(editorState.selection, isNotNull);
        expect(editorState.selection!.start.path, [0, 999]);

        final elapsedMs = stopwatch.elapsedMilliseconds;

        // Performance assertion - selection should update within reasonable time
        expect(
          elapsedMs,
          lessThan(500),
          reason: 'Selection update should complete in less than 500ms',
        );

        // Cleanup
        editorState.selectionNotifier.removeListener(selectionListener);
        await editor.dispose();
      },
    );
  });
}
