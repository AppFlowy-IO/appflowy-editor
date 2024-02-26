import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util/util.dart';

Future<void> testFormatCharacterShortcut(
  CharacterShortcutEvent event,
  String prefix,
  int index,
  void Function(bool result, Node before, Node after, EditorState editorState)
      test, {
  String text = 'Welcome to AppFlowy Editor 🔥!',
  Node? node,
}) async {
  final document = Document.blank();
  if (node != null) {
    document.insert([0], [node]);
  } else {
    document.addParagraph(
      builder: (index) => Delta()..insert('$prefix$text'),
    );
  }
  final editorState = EditorState(document: document);

  final selection = Selection.collapsed(
    Position(path: [0], offset: index),
  );
  editorState.selection = selection;
  final before = editorState.getNodesInSelection(selection).first;
  final result = await event.execute(editorState);
  final after = editorState.getNodesInSelection(selection).first;

  test(result, before, after, editorState);
}
