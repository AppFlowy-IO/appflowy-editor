import 'package:appflowy_editor/src/service/context_menu/context_menu.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:appflowy_editor/appflowy_editor.dart';

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
    void rightClick() {
      GestureBinding.instance.handlePointerEvent(
        const PointerDownEvent(
          buttons: kSecondaryMouseButton,
        ),
      );

      GestureBinding.instance.handlePointerEvent(
        const PointerUpEvent(),
      );
    }

    testWidgets('context menu test', (tester) async {
      final editor = tester.editor
        ..addParagraph(initialText: 'Welcome to AppFlowy');
      await editor.startTesting();
      expect(find.byType(ContextMenu), findsNothing);
      rightClick();
      await tester.pump();
      expect(find.byType(ContextMenu), findsOneWidget);
      await editor.dispose();
    });

    testWidgets('context menu cut test ', (tester) async {
      final editor = tester.editor
        ..addParagraph(initialText: 'Welcome to AppFlowy');
      await editor.startTesting();
      expect(
        find.text('Welcome to AppFlowy', findRichText: true),
        findsOneWidget,
      );
      await editor.updateSelection(
        Selection(
          start: Position(path: [0], offset: 0),
          end: Position(path: [0], offset: 18),
        ),
      );
      final text =
          editor.editorState.getTextInSelection(editor.selection).join('/n');
      rightClick();
      await tester.pump();
      final cutButton = find.text('Cut');
      expect(cutButton, findsOneWidget);
      await tester.tap(cutButton);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      expect(
        find.text('Welcome to AppFlowy', findRichText: true),
        findsNothing,
      );
      final clipBoardData = await AppFlowyClipboard.getData();
      expect(clipBoardData.text, text);
      await editor.dispose();
    });

    testWidgets('context menu copy and paste test', (tester) async {
      final editor = tester.editor
        ..addParagraph(initialText: 'Welcome to AppFlowy');
      editor.addParagraph(initialText: 'Hello');
      await editor.startTesting();
      expect(
        find.text('Welcome to AppFlowy', findRichText: true),
        findsOneWidget,
      );
      await editor.updateSelection(
        Selection(
          start: Position(path: [1], offset: 0),
          end: Position(path: [1], offset: 5),
        ),
      );
      final text =
          editor.editorState.getTextInSelection(editor.selection).join('/n');
      rightClick();
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
      expect(clipBoardData.text, text);
      await editor.updateSelection(
        Selection(
          start: Position(path: [0], offset: 0),
          end: Position(path: [0], offset: 7),
        ),
      );
      rightClick();
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
