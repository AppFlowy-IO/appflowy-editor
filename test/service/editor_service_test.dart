import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
      final size = tester.getSize(find.byType(AppFlowyEditor));
      expect(size, const Size(800, 600));
      await editor.dispose();
    });

    testWidgets('with shrinkWrap true and wrapper with scroll view',
        (tester) async {
      final editor = tester.editor
        ..addParagraphs(
          1000,
          initialText: 'Hello',
        );
      await editor.startTesting(
        shrinkWrap: true,
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
