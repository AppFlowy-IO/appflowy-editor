import 'package:appflowy_editor/appflowy_editor.dart';

/// This rule ensures that there is at least one editable node in the document.
///
/// If the document is empty, it will create a new paragraph node.
class AtLeastOneEditableNodeRule extends DocumentRule {
  const AtLeastOneEditableNodeRule();
  @override
  bool shouldApply({
    required EditorState editorState,
    required EditorTransactionValue value,
  }) {
    final time = value.$1;
    if (time != TransactionTime.after) {
      return false;
    }
    final document = editorState.document;
    return document.root.children.isEmpty;
  }

  @override
  Future<void> apply({
    required EditorState editorState,
    required EditorTransactionValue value,
  }) async {
    final transaction = editorState.transaction;
    transaction
      ..insertNode([0], paragraphNode())
      ..afterSelection = Selection.collapsed(
        Position(path: [0]),
      );
    editorState.apply(transaction);
  }
}
