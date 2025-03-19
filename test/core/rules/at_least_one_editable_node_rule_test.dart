import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('at least one editable node rule', () async {
    final rule = AtLeastOneEditableNodeRule();
    final node1 = paragraphNode(text: 'Hello World!');
    final node2 = paragraphNode(text: 'Hello World!');
    final node3 = paragraphNode(text: 'Hello World!');
    final document = Document(
      root: pageNode(
        children: [
          node1,
          node2,
          node3,
        ],
      ),
    );
    final editorState = EditorState(document: document)..documentRules = [rule];
    // delete all the nodes
    final transaction = editorState.transaction;
    transaction.deleteNodes([node1, node2, node3]);
    await editorState.apply(transaction);

    await Future.delayed(const Duration(milliseconds: 100));
    final node = editorState.document.root.children[0];
    expect(node.type, ParagraphBlockKeys.type);

    editorState.dispose();
  });
}
