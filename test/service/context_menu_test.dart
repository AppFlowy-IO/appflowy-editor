import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../infra/clipboard_test.dart';
import '../new/infra/testable_editor.dart';

void main() async {
  late MockClipboard mockClipboard;
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockClipboard = const MockClipboard(html: null, text: null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (message) async {
      switch (message.method) {
        case "Clipboard.getData":
          return mockClipboard.getData;
        case "Clipboard.setData":
          final args = message.arguments as Map<String, dynamic>;
          mockClipboard = mockClipboard.copyWith(
            text: args['text'],
          );
      }
      return null;
    });
  });
  group('context menu test', () {
    void rightClickAt(Offset position) {
      GestureBinding.instance.handlePointerEvent(
        PointerDownEvent(
          position: position,
          buttons: kSecondaryMouseButton,
        ),
      );

      GestureBinding.instance.handlePointerEvent(
        const PointerUpEvent(),
      );
    }

    testWidgets('context menu test', (tester) async {
      const text = 'Welcome to AppFlowy';
      final editor = tester.editor..addParagraph(initialText: text);
      await editor.startTesting();
      expect(find.byType(ContextMenu), findsNothing);
      await editor.updateSelection(
        Selection.single(path: [0], startOffset: 0, endOffset: text.length),
      );
      final position = tester.getCenter(find.text(text, findRichText: true));
      rightClickAt(position);
      await tester.pump();
      expect(find.byType(ContextMenu), findsOneWidget);
      await editor.dispose();
    });

    testWidgets('context menu copy and paste test', (tester) async {
      const text = 'Welcome to AppFlowy';
      final editor = tester.editor
        ..addParagraph(initialText: text)
        ..addParagraph(initialText: 'Hello');
      await editor.startTesting();
      expect(
        find.text(text, findRichText: true),
        findsOneWidget,
      );
      await editor.updateSelection(
        Selection(
          start: Position(path: [1], offset: 0),
          end: Position(path: [1], offset: 5),
        ),
      );
      final copiedText =
          editor.editorState.getTextInSelection(editor.selection).join('/n');
      final position = tester.getCenter(find.text('Hello', findRichText: true));
      rightClickAt(position);
      await tester.pump();
      final copyButton = find.text('Copy');
      expect(copyButton, findsOneWidget);
      await tester.tap(copyButton);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      expect(
        find.text('Welcome to AppFlowy', findRichText: true),
        findsOneWidget,
      );
      final clipBoardData = await AppFlowyClipboard.getData();
      expect(clipBoardData.text, copiedText);
      await editor.updateSelection(
        Selection(
          start: Position(path: [0], offset: 0),
          end: Position(path: [0], offset: 7),
        ),
      );
      final newPosition =
          tester.getTopLeft(find.text(text, findRichText: true));
      rightClickAt(newPosition);
      await tester.pump();
      final pasteButton = find.text('Paste');
      expect(pasteButton, findsOneWidget);
      await tester.tap(pasteButton);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      expect(
        find.text('Hello to AppFlowy', findRichText: true),
        findsOneWidget,
      );
      await editor.dispose();
    });
  });
}
