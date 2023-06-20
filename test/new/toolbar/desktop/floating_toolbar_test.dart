import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../util/util.dart';
import '../../infra/testable_editor.dart';

void main() async {
  group('floating toolbar', () {
    const text = 'Welcome to AppFlowy Editor 🔥!';

    testWidgets(
        'select the first line of the document, the toolbar should not be blocked',
        (tester) async {
      final editor = tester.editor..addParagraphs(3, initialText: text);
      await editor.startTesting(
        withFloatingToolbar: true,
      );

      final selection = Selection.single(
        path: [0],
        startOffset: 0,
        endOffset: text.length,
      );
      await editor.updateSelection(selection);
      await tester.pumpAndSettle();

      final floatingToolbar = find.byType(FloatingToolbarWidget);
      expect(floatingToolbar, findsOneWidget);
      expect(tester.getTopLeft(floatingToolbar).dy >= 0, true);
      await editor.dispose();
    });
  });
}
