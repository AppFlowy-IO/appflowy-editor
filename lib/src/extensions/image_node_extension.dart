import 'package:appflowy_editor/appflowy_editor.dart';

extension InsertImage on EditorState {
  void insertImageNode(String src) {
    final selection = service.selectionService.currentSelection.value;
    if (selection == null) {
      return;
    }
    final imageNode = Node(
      type: 'image',
      attributes: {
        'image_src': src,
        'align': 'center',
      },
    );
    final transaction = this.transaction;
    transaction.insertNode(
      selection.start.path,
      imageNode,
    );
    apply(transaction);
  }
}
