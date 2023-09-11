import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../infra/testable_editor.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('page_up_down_handler_test.dart', () {
    testWidgets('Presses PageUp and pageDown key in large document',
        (tester) async {
      const text = 'Welcome to Appflowy 😁';
      final editor = tester.editor..addParagraphs(1000, initialText: text);
      await editor.startTesting();
      await editor.updateSelection(
        Selection.single(path: [0], startOffset: 0),
      );

      final scrollService = editor.editorState.service.scrollService!;
      final page = scrollService.page!;
      final onePageHeight = scrollService.onePageHeight!;

      // Pressing the pageDown key continuously.
      var currentOffsetY = 0.0;
      for (int i = 1; i <= page; i++) {
        await editor.pressKey(
          key: LogicalKeyboardKey.pageDown,
        );
        if (i == page) {
          currentOffsetY = scrollService.maxScrollExtent;
        } else {
          currentOffsetY += onePageHeight;
        }
        final dy = scrollService.dy;
        expect(dy, currentOffsetY);
      }

      for (int i = 1; i <= 5; i++) {
        await editor.pressKey(
          key: LogicalKeyboardKey.pageDown,
        );
        final dy = scrollService.dy;
        expect(dy == scrollService.maxScrollExtent, true);
      }

      // Pressing the pageUp key continuously.
      for (int i = page; i >= 1; i--) {
        await editor.pressKey(
          key: LogicalKeyboardKey.pageUp,
        );
        if (i == 1) {
          currentOffsetY = scrollService.minScrollExtent;
        } else {
          currentOffsetY -= onePageHeight;
        }
        final dy = scrollService.dy;
        expect(dy, currentOffsetY);
      }

      for (int i = 1; i <= 5; i++) {
        await editor.pressKey(
          key: LogicalKeyboardKey.pageUp,
        );
        final dy = scrollService.dy;
        expect(dy == scrollService.minScrollExtent, true);
      }
    });
  });
}
