import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../new/infra/testable_editor.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  // input `Hello` World
  // only the `Hello` has the code style
  testWidgets('skip attributes if pressing space', (tester) async {
    final editor = tester.editor..addEmptyParagraph();
    await editor.startTesting();
    await tester.pumpAndSettle();

    final selection = Selection.collapsed(Position(path: [0]));
    await editor.updateSelection(selection);
    const text = '`Hello` World';
    for (var i = 0; i < text.length; i++) {
      await editor.ime.typeText(text[i]);
    }

    final node = editor.editorState.getNodeAtPath([0]);
    final delta = node?.delta;
    expect(delta?.toPlainText(), 'Hello World');
    expect(delta?.toJson(), [
      {
        'insert': 'Hello',
        'attributes': {'code': true},
      },
      {'insert': ' World'},
    ]);
  });

  testWidgets('don\'t keep attributes if pressing backspace', (tester) async {
    final editor = tester.editor..addEmptyParagraph();
    await editor.startTesting();
    await tester.pumpAndSettle();

    final selection = Selection.collapsed(Position(path: [0]));
    await editor.updateSelection(selection);
    const text1 = '`Hello` ';
    for (var i = 0; i < text1.length; i++) {
      await editor.ime.typeText(text1[i]);
    }

    await tester.editor.pressKey(key: LogicalKeyboardKey.backspace);

    const text2 = 'World';
    for (var i = 0; i < text2.length; i++) {
      await editor.ime.typeText(text2[i]);
    }

    final node = editor.editorState.getNodeAtPath([0]);
    final delta = node?.delta;
    expect(delta?.toJson(), [
      {
        'insert': 'Hello',
        'attributes': {'code': true},
      },
      {'insert': 'World'},
    ]);
  });

  testWidgets('slice attributes from next position if index is 0',
      (tester) async {
    final editor = tester.editor..addEmptyParagraph();
    await editor.startTesting();
    await tester.pumpAndSettle();

    final selection = Selection.collapsed(Position(path: [0]));
    await editor.updateSelection(selection);
    const text1 = '**World**';
    for (var i = 0; i < text1.length; i++) {
      await editor.ime.typeText(text1[i]);
    }

    // move the cursor to the beginning of the text
    await editor.updateSelection(Selection.collapsed(Position(path: [0])));
    await editor.ime.typeText('Hello');

    final node = editor.editorState.getNodeAtPath([0]);
    final delta = node?.delta;
    expect(delta?.toJson(), [
      {
        'insert': 'HelloWorld',
        'attributes': {'bold': true},
      },
    ]);
  });

  testWidgets('don\'t slice attributes from next position if index is not 0',
      (tester) async {
    final editor = tester.editor..addEmptyParagraph();
    await editor.startTesting();
    await tester.pumpAndSettle();

    final selection = Selection.collapsed(Position(path: [0]));
    await editor.updateSelection(selection);
    const text1 = 'Hello **World**';
    for (var i = 0; i < text1.length; i++) {
      await editor.ime.typeText(text1[i]);
    }

    // move the cursor after Hello: `Hello |`
    await editor.updateSelection(
      Selection.collapsed(Position(path: [0], offset: 6)),
    );
    await editor.ime.typeText('Hello');

    final node = editor.editorState.getNodeAtPath([0]);
    final delta = node?.delta;
    expect(delta?.toJson(), [
      {
        'insert': 'Hello Hello',
      },
      {
        'insert': 'World',
        'attributes': {'bold': true},
      },
    ]);
  });
}
