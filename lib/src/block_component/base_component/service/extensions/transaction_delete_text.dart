import 'package:appflowy_editor/appflowy_editor.dart';

extension Extension on Transaction {
  void deleteText2(
    Node node,
    int index,
    int length,
  ) {
    final delta = node.delta;
    if (delta == null) {
      return;
    }

    final now = delta.compose(
      Delta()
        ..retain(index)
        ..delete(length),
    );

    updateNode(node, {
      'delta': now.toJson(),
    });

    afterSelection = Selection.collapsed(
      Position(path: node.path, offset: index),
    );
  }
}
