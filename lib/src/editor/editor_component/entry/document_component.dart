import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DocumentBlockKeys {
  const DocumentBlockKeys._();

  static const String type = 'document';
}

Node documentNode({
  required Iterable<Node> children,
}) {
  return Node(
    type: DocumentBlockKeys.type,
    children: children,
  );
}

class DocumentComponentBuilder extends BlockComponentBuilder {
  @override
  Widget build(BlockComponentContext blockComponentContext) {
    return DocumentComponent(
      key: blockComponentContext.node.key,
      node: blockComponentContext.node,
    );
  }
}

class DocumentComponent extends StatelessWidget {
  const DocumentComponent({
    super.key,
    required this.node,
  });

  final Node node;

  @override
  Widget build(BuildContext context) {
    final editorState = Provider.of<EditorState>(context, listen: false);
    final children = editorState.renderer.buildList(context, node.children);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}
