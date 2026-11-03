import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../new/infra/testable_editor.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('Testing Scroll With Gestures', () {
    testWidgets('Test Gesture Scroll', (tester) async {
      final editor = tester.editor;
      for (var i = 0; i < 100; i++) {
        editor.addParagraph(initialText: '$i');
      }
      editor.addParagraph(initialText: 'mark');
      for (var i = 100; i < 200; i++) {
        editor.addParagraph(initialText: '$i');
      }
      await editor.startTesting();
      final listFinder = find.byType(Scrollable);
      final itemFinder = find.text('mark', findRichText: true);
      await tester.scrollUntilVisible(
        itemFinder,
        500.0,
        scrollable: listFinder,
      );
      expect(itemFinder, findsOneWidget);
      await editor.dispose();
    });

    testWidgets('remote document updates do not request local auto-scroll',
        (tester) async {
      final editor = tester.editor;
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        editor.editorState.dispose();
      });

      for (var i = 0; i < 3; i++) {
        editor.addParagraph(initialText: 'paragraph $i');
      }
      await editor.startTesting();
      await editor.updateSelection(
        Selection.collapsed(
          Position(path: [0]),
        ),
      );

      final localSelection = editor.selection;
      final autoScroller = editor.editorState.autoScroller;
      expect(autoScroller, isNotNull);
      if (autoScroller == null) {
        return;
      }
      autoScroller.stopAutoScroll();
      expect(autoScroller.lastOffset, isNull);

      final remotelyEditedNode = editor.nodeAtPath([1]);
      expect(remotelyEditedNode, isNotNull);
      if (remotelyEditedNode == null) {
        return;
      }
      final transaction = editor.editorState.transaction
        ..updateNode(
          remotelyEditedNode,
          {
            ParagraphBlockKeys.delta:
                (Delta()..insert('updated remotely')).toJson(),
          },
        );

      await editor.editorState.apply(transaction, isRemote: true);
      await tester.pump();

      expect(editor.selection, localSelection);
      expect(autoScroller.lastOffset, isNull);
    });
  });
}
