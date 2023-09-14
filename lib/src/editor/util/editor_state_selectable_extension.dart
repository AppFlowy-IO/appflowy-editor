import 'package:appflowy_editor/appflowy_editor.dart';

extension EditorStateSelectable on EditorState {
  (Node, BlockComponentSelectable)? getFirstSelectable() {
    final nodes = document.root.children;
    for (var i = 0; i < nodes.length; i++) {
      final selectable = renderer.blockComponentSelectable(nodes[i].type);
      if (selectable != null) {
        return (nodes[i], selectable);
      }
    }
    return null;
  }

  (Node, BlockComponentSelectable)? getLastSelectable() {
    final node = document.root.lastChildWhere(
      (node) => renderer.blockComponentSelectable(node.type) != null,
    );
    if (node != null) {
      return (node, renderer.blockComponentSelectable(node.type)!);
    }
    return null;
  }
}
