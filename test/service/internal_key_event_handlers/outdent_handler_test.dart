import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../infra/test_editor.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('outdent_handler.dart', () {
    testWidgets("press shift tab in plain text", (tester) async {
      const text = 'Welcome to Appflowy 😁';
      final editor = tester.editor
        ..insertTextNode(text)
        ..insertTextNode(text)
        ..insertTextNode(text);

      await editor.startTesting();

      final snapshotDocument = editor.document;

      await editor.updateSelection(Selection.single(path: [0], startOffset: 0));

      await editor.pressLogicKey(
        key: LogicalKeyboardKey.tab,
        isShiftPressed: true,
      );

      // nothing happens
      expect(
        editor.documentSelection,
        Selection.single(path: [0], startOffset: 0),
      );
      expect(editor.document.toJson(), snapshotDocument.toJson());
    });

    testWidgets("press shift tab where previous element is not list element",
        (tester) async {
      const text = 'Welcome to Appflowy 😁';
      final editor = tester.editor
        ..insertTextNode(text)
        ..insertTextNode(
          text,
          attributes: {
            BuiltInAttributeKey.subtype: BuiltInAttributeKey.bulletedList
          },
        )
        ..insertTextNode(
          text,
          attributes: {
            BuiltInAttributeKey.subtype: BuiltInAttributeKey.bulletedList
          },
        );

      await editor.startTesting();

      final snapshotDocument = editor.document;

      var selection = Selection.single(path: [1], startOffset: 0);
      await editor.updateSelection(selection);

      await editor.pressLogicKey(
        key: LogicalKeyboardKey.tab,
        isShiftPressed: true,
      );

      // nothing happens
      expect(
        editor.documentSelection,
        Selection.single(path: [1], startOffset: 0),
      );
      expect(editor.document.toJson(), snapshotDocument.toJson());
    });

    testWidgets(
      "press shift tab in indented list with multiple nodes in same sub-level",
      (tester) async {
        const text = 'Welcome to Appflowy 😁';
        final editor = tester.editor
          ..insertTextNode(
            text,
            attributes: {
              BuiltInAttributeKey.subtype: BuiltInAttributeKey.checkbox,
              BuiltInAttributeKey.checkbox: false,
            },
          )
          ..insertTextNode(
            text,
            attributes: {
              BuiltInAttributeKey.subtype: BuiltInAttributeKey.checkbox,
              BuiltInAttributeKey.checkbox: false,
            },
          )
          ..insertTextNode(
            text,
            attributes: {
              BuiltInAttributeKey.subtype: BuiltInAttributeKey.checkbox,
              BuiltInAttributeKey.checkbox: false,
            },
          );
        await editor.startTesting();

        final selection = Selection.single(path: [1], startOffset: 0);
        await editor.updateSelection(selection);

        await editor.pressLogicKey(key: LogicalKeyboardKey.tab);

        await editor.updateSelection(selection);

        await editor.pressLogicKey(key: LogicalKeyboardKey.tab);

        // Before
        // [] Welcome to Appflowy 😁
        // [] Welcome to Appflowy 😁
        // [] Welcome to Appflowy 😁
        // After
        // [] Welcome to Appflowy 😁
        //  [] Welcome to Appflowy 😁
        //  [] Welcome to Appflowy 😁

        expect(
          editor.documentSelection,
          Selection.single(path: [0, 1], startOffset: 0),
        );
        expect(
          editor.nodeAtPath([0])!.subtype,
          BuiltInAttributeKey.checkbox,
        );
        expect(editor.nodeAtPath([1]), null);
        expect(editor.nodeAtPath([2]), null);
        expect(
          editor.nodeAtPath([0, 0])!.subtype,
          BuiltInAttributeKey.checkbox,
        );
        expect(
          editor.nodeAtPath([0, 1])!.subtype,
          BuiltInAttributeKey.checkbox,
        );

        await editor
            .updateSelection(Selection.single(path: [0, 1], startOffset: 0));

        await editor.pressLogicKey(
          key: LogicalKeyboardKey.tab,
          isShiftPressed: true,
        );

        // Before
        // * Welcome to Appflowy 😁
        //  * Welcome to Appflowy 😁
        //  * Welcome to Appflowy 😁
        // After
        // * Welcome to Appflowy 😁
        //  * Welcome to Appflowy 😁
        // * Welcome to Appflowy 😁

        expect(
          editor.nodeAtPath([1])!.subtype,
          BuiltInAttributeKey.checkbox,
        );
        expect(
          editor.nodeAtPath([0, 0])!.subtype,
          BuiltInAttributeKey.checkbox,
        );
        expect(editor.nodeAtPath([0, 1]), null);
      },
    );

    testWidgets(
      "press shift tab in indented list with only one node in same sub-level",
      (tester) async {
        const text = 'Welcome to Appflowy 😁';
        final editor = tester.editor
          ..insertTextNode(
            text,
            attributes: {
              BuiltInAttributeKey.subtype: BuiltInAttributeKey.bulletedList
            },
          )
          ..insertTextNode(
            text,
            attributes: {
              BuiltInAttributeKey.subtype: BuiltInAttributeKey.bulletedList
            },
          )
          ..insertTextNode(
            text,
            attributes: {
              BuiltInAttributeKey.subtype: BuiltInAttributeKey.bulletedList
            },
          );
        await editor.startTesting();

        var selection = Selection.single(path: [1], startOffset: 0);
        await editor.updateSelection(selection);

        await editor.pressLogicKey(key: LogicalKeyboardKey.tab);

        // Before
        // * Welcome to Appflowy 😁
        // * Welcome to Appflowy 😁
        // * Welcome to Appflowy 😁
        // After
        // * Welcome to Appflowy 😁
        //  * Welcome to Appflowy 😁
        // * Welcome to Appflowy 😁

        expect(
          editor.documentSelection,
          Selection.single(path: [0, 0], startOffset: 0),
        );
        expect(
            editor.nodeAtPath([0])!.subtype, BuiltInAttributeKey.bulletedList);
        expect(editor.nodeAtPath([0, 0])!.subtype,
            BuiltInAttributeKey.bulletedList);
        expect(
            editor.nodeAtPath([1])!.subtype, BuiltInAttributeKey.bulletedList);
        expect(editor.nodeAtPath([2]), null);

        await editor
            .updateSelection(Selection.single(path: [0, 0], startOffset: 0));

        await editor.pressLogicKey(
          key: LogicalKeyboardKey.tab,
          isShiftPressed: true,
        );

        // Before
        // * Welcome to Appflowy 😁
        // * Welcome to Appflowy 😁
        // * Welcome to Appflowy 😁
        // After
        // * Welcome to Appflowy 😁
        // * Welcome to Appflowy 😁
        // * Welcome to Appflowy 😁

        expect(
            editor.nodeAtPath([0])!.subtype, BuiltInAttributeKey.bulletedList);
        expect(
            editor.nodeAtPath([1])!.subtype, BuiltInAttributeKey.bulletedList);
        expect(
            editor.nodeAtPath([2])!.subtype, BuiltInAttributeKey.bulletedList);
        expect(editor.nodeAtPath([0, 0]), null);
      },
    );
  });
}
