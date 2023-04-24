import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../infra/test_editor.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('link_open_handler.dart', () {
    testWidgets("press option + enter in plain text", (tester) async {
      //pressing option/alt + enter in plain text which is not a link,
      //should call the link open handler and since the textNode is not
      //a link, the handler should return KeyEventResultHandled.
      //
      //To verify this, we can expect that the document has no change,
      //since if the handler was not called then the functionality of enter will
      //execute and change the number of nodes in the document.
      const text = 'Welcome to Appflowy 😁';
      final editor = tester.editor
        ..insertTextNode(text)
        ..insertTextNode(text)
        ..insertTextNode(text);

      await editor.startTesting();

      await editor.updateSelection(Selection.single(path: [1], startOffset: 5));

      await editor.pressLogicKey(
        key: LogicalKeyboardKey.enter,
        isAltPressed: true,
      );

      //no new node is inserted because of enter being pressed
      expect(editor.documentLength, 3);
    });

    testWidgets("press option + enter in link", (tester) async {
      //pressing option/alt + enter in link should call the link open handler
      //and since the textNode is a link, the handler must execute.
      //
      //To verify this, we can expect that the document has no change,
      //since if the handler was not called then the functionality of enter will
      //execute and change the number of nodes in the document.
      const text = 'Welcome to Appflowy 😁';
      const link = 'appflowy.io';

      final editor = tester.editor
        ..insertTextNode(text)
        ..insertTextNode(
          text,
          delta: Delta()
            ..insert(
              link,
              attributes: {
                BuiltInAttributeKey.href: link,
              },
            ),
        )
        ..insertTextNode(text);

      await editor.startTesting();

      await editor.updateSelection(Selection.single(path: [1], startOffset: 5));

      await editor.pressLogicKey(
        key: LogicalKeyboardKey.enter,
        isAltPressed: true,
      );

      //no new node is inserted because of enter being pressed
      expect(editor.documentLength, 3);
    });
  });
}
