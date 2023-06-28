import 'package:flutter_test/flutter_test.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import '../new/infra/testable_editor.dart';

void main() {
  group('AppFlowyEditor tests', () {
    testWidgets('without autoFocus false', (tester) async {
      final editor = tester.editor..addParagraph(initialText: 'Hello');
      await editor.startTesting(autoFocus: false);
      final selection = editor.selection;
      expect(selection != null, false);
      await editor.dispose();
    });

    testWidgets('with autoFocus true', (tester) async {
      final editor = tester.editor..addParagraph(initialText: 'Hello');
      await editor.startTesting(autoFocus: true);
      final selection = editor.selection;
      expect(selection != null, true);
      await editor.dispose();
    });

    testWidgets('with shrinkWrap false', (tester) async {
      final editor = tester.editor
        ..addParagraphs(
          1000,
          initialText: 'Hello',
        );
      await editor.startTesting(shrinkWrap: false);
      await editor.dispose();
    });

    testWidgets('with shrinkWrap true', (tester) async {
      final editor = tester.editor
        ..addParagraphs(
          1000,
          initialText: 'Hello',
        );
      await editor.startTesting(shrinkWrap: true);
      expect(
        tester.takeException(),
        isInstanceOf<ArgumentError>(),
      );
    });

    testWidgets('with shrinkWrap true and wrapper with scroll view',
        (tester) async {
      final scrollController = ScrollController();
      final editor = tester.editor
        ..addParagraphs(
          1000,
          initialText: 'Hello',
        );
      await editor.startTesting(
        shrinkWrap: true,
        scrollController: scrollController,
        wrapper: (child) => SingleChildScrollView(
          child: IntrinsicHeight(
            child: child,
          ),
        ),
      );
      final size = tester.getSize(find.byType(AppFlowyEditor));
      expect(size.height > 1000, true);
    });
  });
}
