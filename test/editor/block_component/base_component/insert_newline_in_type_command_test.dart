import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InsertNewlineInTypeCommand tests', () {
    test('bulleted list', () async {
      final bulletedNode = bulletedListNode(
        text: 'bulleted list 1',
        children: [
          bulletedListNode(text: '1'),
          bulletedListNode(text: ''),
        ],
      );
      final document = Document.blank()..insert([0], [bulletedNode]);

      final editorState = EditorState(document: document);

      editorState.selection = Selection.collapsed(Position(path: [0, 1]));

      insertNewLineAfterBulletedList.execute(editorState);
      Node? node1 = editorState.getNodeAtPath([1]);
      expect(node1?.type, BulletedListBlockKeys.type);

      insertNewLineAfterBulletedList.execute(editorState);
      Node? node2 = editorState.getNodeAtPath([1]);

      expect(node2?.type, ParagraphBlockKeys.type);
    });

    test('todo list', () async {
      final todoListNodes = todoListNode(
        checked: false,
        children: [
          todoListNode(checked: false),
          todoListNode(checked: false),
        ],
      );
      final document = Document.blank()..insert([0], [todoListNodes]);

      final editorState = EditorState(document: document);

      editorState.selection = Selection.collapsed(Position(path: [0, 1]));

      insertNewLineAfterTodoList.execute(editorState);
      Node? node1 = editorState.getNodeAtPath([1]);
      expect(node1?.type, TodoListBlockKeys.type);

      insertNewLineAfterTodoList.execute(editorState);
      Node? node2 = editorState.getNodeAtPath([1]);

      expect(node2?.type, ParagraphBlockKeys.type);
    });

    test('numbered list', () async {
      final numberedListNodes = numberedListNode(
        children: [
          numberedListNode(),
          numberedListNode(),
        ],
      );
      final document = Document.blank()..insert([0], [numberedListNodes]);

      final editorState = EditorState(document: document);

      editorState.selection = Selection.collapsed(Position(path: [0, 1]));

      insertNewLineAfterNumberedList.execute(editorState);
      Node? node1 = editorState.getNodeAtPath([1]);
      expect(node1?.type, NumberedListBlockKeys.type);

      insertNewLineAfterNumberedList.execute(editorState);
      Node? node2 = editorState.getNodeAtPath([1]);

      expect(node2?.type, ParagraphBlockKeys.type);
    });
  });
}
