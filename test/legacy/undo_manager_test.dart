import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/history/undo_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  test('HistoryItem #1', () {
    final editorState = EditorState.blank();

    final historyItem = HistoryItem();
    historyItem.add(DeleteOperation([0], [paragraphNode(text: '0')]));
    historyItem.add(DeleteOperation([0], [paragraphNode(text: '1')]));
    historyItem.add(DeleteOperation([0], [paragraphNode(text: '2')]));

    final transaction = historyItem.toTransaction(editorState);
    assert(isInsertAndPathEqual(transaction.operations[0], [0], '2'));
    assert(isInsertAndPathEqual(transaction.operations[1], [0], '1'));
    assert(isInsertAndPathEqual(transaction.operations[2], [0], '0'));
  });

  test('HistoryItem #2', () {
    final editorState = EditorState.blank();

    final historyItem = HistoryItem();
    historyItem.add(DeleteOperation([0], [paragraphNode(text: '0')]));
    historyItem.add(
      const UpdateOperation([0], {'subType': 'number'}, {'subType': null}),
    );
    historyItem.add(DeleteOperation([0], [paragraphNode(), paragraphNode()]));
    historyItem.add(DeleteOperation([0], [paragraphNode()]));

    final transaction = historyItem.toTransaction(editorState);
    assert(isInsertAndPathEqual(transaction.operations[0], [0]));
    assert(isInsertAndPathEqual(transaction.operations[1], [0]));
    assert(transaction.operations[2] is UpdateOperation);
    assert(isInsertAndPathEqual(transaction.operations[3], [0], '0'));
  });

  test('HistoryItem sealed', () {
    final historyItem = HistoryItem();
    historyItem.add(DeleteOperation([0], [paragraphNode(text: '0')]));
    historyItem.seal();
    expect(historyItem.sealed, true);
  });
}

bool isInsertAndPathEqual(Operation operation, Path path, [String? content]) {
  if (operation is! InsertOperation) {
    return false;
  }

  if (!operation.path.equals(path)) {
    return false;
  }

  final delta = operation.nodes.first.delta;
  if (delta == null) {
    return false;
  }

  if (content == null) {
    return true;
  }

  return delta.toPlainText() == content;
}
