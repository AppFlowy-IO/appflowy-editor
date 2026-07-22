import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Regression: copy→paste of a checklist must preserve the todo_list block
  // type AND the checked state. The encoder emits
  // <div><input type="checkbox" [checked]/>text</div>; the decoder must rebuild
  // a todo_list node (previously <div> fell through to a plain paragraph and the
  // <input> was ignored, so checkboxes pasted as plain text).
  test('todo_list survives html encode -> decode with checked state', () {
    final doc = Document.blank(withInitialText: false)
      ..insert([0], [
        todoListNode(checked: false, text: 'check box 1'),
        todoListNode(checked: true, text: 'check box 2'),
        todoListNode(checked: false, text: 'check box 3'),
      ]);

    final decoded = htmlToDocument(documentToHTML(doc));
    final children = decoded.root.children.toList();

    expect(children.length, 3);
    expect(
      children.every((n) => n.type == TodoListBlockKeys.type),
      isTrue,
      reason: 'all three should decode as todo_list, not paragraph',
    );
    expect(children[0].attributes[TodoListBlockKeys.checked], false);
    expect(children[1].attributes[TodoListBlockKeys.checked], true);
    expect(children[2].attributes[TodoListBlockKeys.checked], false);
    expect(children[1].delta?.toPlainText(), 'check box 2');
  });
}
