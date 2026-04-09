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

  test('Multi-step redo preserves redo stack', () {
    final editorState = EditorState(
      document: Document(
        root: pageNode(
          children: [
            paragraphNode(text: ''),
          ],
        ),
      ),
    );
    editorState.disableSealTimer = true;

    // Apply 3 separate transactions, sealing each one
    for (var i = 0; i < 3; i++) {
      final transaction = editorState.transaction;
      transaction.insertText(
        editorState.document.nodeAtPath([0])!,
        i, // offset
        String.fromCharCode(65 + i), // 'A', 'B', 'C'
      );
      editorState.apply(transaction);
      editorState.undoManager.undoStack.last.seal();
    }

    // Document should be "ABC"
    expect(
      editorState.document.nodeAtPath([0])!.delta!.toPlainText(),
      'ABC',
    );
    expect(editorState.undoManager.undoStack.length, 3);
    expect(editorState.undoManager.redoStack.length, 0);

    // Undo 3 times → back to empty
    editorState.undoManager.undo();
    expect(
      editorState.document.nodeAtPath([0])!.delta!.toPlainText(),
      'AB',
    );
    expect(editorState.undoManager.undoStack.length, 2);
    expect(editorState.undoManager.redoStack.length, 1);

    editorState.undoManager.undo();
    expect(
      editorState.document.nodeAtPath([0])!.delta!.toPlainText(),
      'A',
    );
    expect(editorState.undoManager.undoStack.length, 1);
    expect(editorState.undoManager.redoStack.length, 2);

    editorState.undoManager.undo();
    expect(
      editorState.document.nodeAtPath([0])!.delta!.toPlainText(),
      '',
    );
    expect(editorState.undoManager.undoStack.length, 0);
    expect(editorState.undoManager.redoStack.length, 3);

    // Redo 3 times → should restore each step
    editorState.undoManager.redo();
    expect(
      editorState.document.nodeAtPath([0])!.delta!.toPlainText(),
      'A',
    );
    expect(editorState.undoManager.undoStack.length, 1);
    expect(editorState.undoManager.redoStack.length, 2);

    // Manually seal to simulate the 50ms debounce timer
    editorState.undoManager.undoStack.last.seal();

    editorState.undoManager.redo();
    expect(
      editorState.document.nodeAtPath([0])!.delta!.toPlainText(),
      'AB',
    );
    expect(editorState.undoManager.undoStack.length, 2);
    expect(editorState.undoManager.redoStack.length, 1);

    editorState.undoManager.undoStack.last.seal();

    editorState.undoManager.redo();
    expect(
      editorState.document.nodeAtPath([0])!.delta!.toPlainText(),
      'ABC',
    );
    expect(editorState.undoManager.undoStack.length, 3);
    expect(editorState.undoManager.redoStack.length, 0);
  });

  test('New edit after undo still clears redo stack', () {
    final editorState = EditorState(
      document: Document(
        root: pageNode(
          children: [
            paragraphNode(text: ''),
          ],
        ),
      ),
    );
    editorState.disableSealTimer = true;

    // Insert "A"
    final t1 = editorState.transaction;
    t1.insertText(editorState.document.nodeAtPath([0])!, 0, 'A');
    editorState.apply(t1);
    editorState.undoManager.undoStack.last.seal();

    // Insert "B"
    final t2 = editorState.transaction;
    t2.insertText(editorState.document.nodeAtPath([0])!, 1, 'B');
    editorState.apply(t2);
    editorState.undoManager.undoStack.last.seal();

    // Undo once → "A", redo stack should have 1 item
    editorState.undoManager.undo();
    expect(
      editorState.document.nodeAtPath([0])!.delta!.toPlainText(),
      'A',
    );
    expect(editorState.undoManager.redoStack.isNonEmpty, true);

    // Make a NEW edit (not redo) → redo stack should be cleared
    final t3 = editorState.transaction;
    t3.insertText(editorState.document.nodeAtPath([0])!, 1, 'X');
    editorState.apply(t3);

    expect(editorState.undoManager.redoStack.isEmpty, true);
  });

  test('Undo after redo restores previous state', () {
    final editorState = EditorState(
      document: Document(
        root: pageNode(
          children: [
            paragraphNode(text: ''),
          ],
        ),
      ),
    );
    editorState.disableSealTimer = true;

    // Insert A, B, C
    for (var i = 0; i < 3; i++) {
      final transaction = editorState.transaction;
      transaction.insertText(
        editorState.document.nodeAtPath([0])!,
        i,
        String.fromCharCode(65 + i),
      );
      editorState.apply(transaction);
      editorState.undoManager.undoStack.last.seal();
    }
    expect(editorState.getNodeAtPath([0])!.delta!.toPlainText(), 'ABC');

    // Undo all
    editorState.undoManager.undo();
    editorState.undoManager.undo();
    editorState.undoManager.undo();
    expect(editorState.getNodeAtPath([0])!.delta!.toPlainText(), '');

    // Redo 2
    editorState.undoManager.redo();
    editorState.undoManager.redo();
    expect(editorState.getNodeAtPath([0])!.delta!.toPlainText(), 'AB');
    expect(editorState.undoManager.undoStack.length, 2);
    expect(editorState.undoManager.redoStack.length, 1);

    // Undo 1 — should undo the last redo
    editorState.undoManager.undo();
    expect(editorState.getNodeAtPath([0])!.delta!.toPlainText(), 'A');
    expect(editorState.undoManager.undoStack.length, 1);
    expect(editorState.undoManager.redoStack.length, 2);

    // Redo all remaining
    editorState.undoManager.redo();
    editorState.undoManager.redo();
    expect(editorState.getNodeAtPath([0])!.delta!.toPlainText(), 'ABC');
  });

  test('Partial undo then redo', () {
    final editorState = EditorState(
      document: Document(
        root: pageNode(
          children: [
            paragraphNode(text: ''),
          ],
        ),
      ),
    );
    editorState.disableSealTimer = true;

    // Insert A, B, C, D
    for (var i = 0; i < 4; i++) {
      final transaction = editorState.transaction;
      transaction.insertText(
        editorState.document.nodeAtPath([0])!,
        i,
        String.fromCharCode(65 + i),
      );
      editorState.apply(transaction);
      editorState.undoManager.undoStack.last.seal();
    }
    expect(editorState.getNodeAtPath([0])!.delta!.toPlainText(), 'ABCD');

    // Undo 2 of 4
    editorState.undoManager.undo();
    editorState.undoManager.undo();
    expect(editorState.getNodeAtPath([0])!.delta!.toPlainText(), 'AB');
    expect(editorState.undoManager.undoStack.length, 2);
    expect(editorState.undoManager.redoStack.length, 2);

    // Redo 2
    editorState.undoManager.redo();
    expect(editorState.getNodeAtPath([0])!.delta!.toPlainText(), 'ABC');
    editorState.undoManager.redo();
    expect(editorState.getNodeAtPath([0])!.delta!.toPlainText(), 'ABCD');
    expect(editorState.undoManager.undoStack.length, 4);
    expect(editorState.undoManager.redoStack.length, 0);
  });

  test('Interleaved undo and redo', () {
    final editorState = EditorState(
      document: Document(
        root: pageNode(
          children: [
            paragraphNode(text: ''),
          ],
        ),
      ),
    );
    editorState.disableSealTimer = true;

    // Insert A, B, C
    for (var i = 0; i < 3; i++) {
      final transaction = editorState.transaction;
      transaction.insertText(
        editorState.document.nodeAtPath([0])!,
        i,
        String.fromCharCode(65 + i),
      );
      editorState.apply(transaction);
      editorState.undoManager.undoStack.last.seal();
    }

    // undo → redo → undo → redo cycle
    editorState.undoManager.undo(); // ABC → AB
    expect(editorState.getNodeAtPath([0])!.delta!.toPlainText(), 'AB');

    editorState.undoManager.redo(); // AB → ABC
    expect(editorState.getNodeAtPath([0])!.delta!.toPlainText(), 'ABC');

    editorState.undoManager.undo(); // ABC → AB
    expect(editorState.getNodeAtPath([0])!.delta!.toPlainText(), 'AB');

    editorState.undoManager.undo(); // AB → A
    expect(editorState.getNodeAtPath([0])!.delta!.toPlainText(), 'A');

    editorState.undoManager.redo(); // A → AB
    expect(editorState.getNodeAtPath([0])!.delta!.toPlainText(), 'AB');

    editorState.undoManager.redo(); // AB → ABC
    expect(editorState.getNodeAtPath([0])!.delta!.toPlainText(), 'ABC');
  });

  test('New edit mid-redo clears remaining redo stack', () {
    final editorState = EditorState(
      document: Document(
        root: pageNode(
          children: [
            paragraphNode(text: ''),
          ],
        ),
      ),
    );
    editorState.disableSealTimer = true;

    // Insert A, B, C
    for (var i = 0; i < 3; i++) {
      final transaction = editorState.transaction;
      transaction.insertText(
        editorState.document.nodeAtPath([0])!,
        i,
        String.fromCharCode(65 + i),
      );
      editorState.apply(transaction);
      editorState.undoManager.undoStack.last.seal();
    }

    // Undo all 3
    editorState.undoManager.undo();
    editorState.undoManager.undo();
    editorState.undoManager.undo();
    expect(editorState.getNodeAtPath([0])!.delta!.toPlainText(), '');
    expect(editorState.undoManager.redoStack.length, 3);

    // Redo 1
    editorState.undoManager.redo();
    expect(editorState.getNodeAtPath([0])!.delta!.toPlainText(), 'A');
    expect(editorState.undoManager.redoStack.length, 2);

    // Make a NEW edit → remaining redo should be cleared
    final t = editorState.transaction;
    t.insertText(editorState.document.nodeAtPath([0])!, 1, 'X');
    editorState.apply(t);

    expect(editorState.getNodeAtPath([0])!.delta!.toPlainText(), 'AX');
    expect(editorState.undoManager.redoStack.length, 0);

    // Redo should be no-op now
    editorState.undoManager.redo();
    expect(editorState.getNodeAtPath([0])!.delta!.toPlainText(), 'AX');
  });

  test('Selection is preserved during multi-step redo', () {
    final editorState = EditorState(
      document: Document(
        root: pageNode(
          children: [
            paragraphNode(text: ''),
          ],
        ),
      ),
    );
    editorState.disableSealTimer = true;

    // Insert A at offset 0 with selection
    final t1 = editorState.transaction;
    t1.insertText(editorState.document.nodeAtPath([0])!, 0, 'A');
    t1.afterSelection = Selection.collapsed(Position(path: [0], offset: 1));
    editorState.apply(t1);
    editorState.undoManager.undoStack.last.seal();

    // Insert B at offset 1 with selection
    final t2 = editorState.transaction;
    t2.insertText(editorState.document.nodeAtPath([0])!, 1, 'B');
    t2.afterSelection = Selection.collapsed(Position(path: [0], offset: 2));
    editorState.apply(t2);
    editorState.undoManager.undoStack.last.seal();

    // Undo both
    editorState.undoManager.undo();
    editorState.undoManager.undo();
    expect(editorState.getNodeAtPath([0])!.delta!.toPlainText(), '');

    // Redo first — selection should be at offset 1
    editorState.undoManager.redo();
    expect(
      editorState.selection,
      Selection.collapsed(Position(path: [0], offset: 1)),
    );

    // Redo second — selection should be at offset 2
    editorState.undoManager.redo();
    expect(
      editorState.selection,
      Selection.collapsed(Position(path: [0], offset: 2)),
    );
  });

  test('TransactionSource.none does not record to either stack', () {
    final editorState = EditorState(
      document: Document(
        root: pageNode(
          children: [
            paragraphNode(text: ''),
          ],
        ),
      ),
    );
    editorState.disableSealTimer = true;

    // Apply with source: none
    final transaction = editorState.transaction;
    transaction.insertText(
      editorState.document.nodeAtPath([0])!,
      0,
      'A',
    );
    editorState.apply(
      transaction,
      options: const ApplyOptions(
        recordUndo: false,
        source: TransactionSource.none,
      ),
    );

    // Document is modified but neither stack is affected
    expect(
      editorState.document.nodeAtPath([0])!.delta!.toPlainText(),
      'A',
    );
    expect(editorState.undoManager.undoStack.length, 0);
    expect(editorState.undoManager.redoStack.length, 0);
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
