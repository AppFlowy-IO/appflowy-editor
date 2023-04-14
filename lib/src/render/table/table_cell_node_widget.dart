import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TableCellNodeWidgetBuilder extends NodeWidgetBuilder<Node> {
  @override
  Widget build(NodeWidgetContext<Node> context) {
    return TableCellNodeWidget(
      key: context.node.key,
      node: context.node,
      editorState: context.editorState,
    );
  }

  @override
  NodeValidator<Node> get nodeValidator => (node) =>
      node.attributes.isNotEmpty &&
      node.attributes.containsKey('rowPosition') &&
      node.attributes.containsKey('colPosition');
}

class TableCellNodeWidget extends StatefulWidget {
  const TableCellNodeWidget({
    Key? key,
    required this.node,
    required this.editorState,
  }) : super(key: key);

  final Node node;
  final EditorState editorState;

  @override
  State<TableCellNodeWidget> createState() => _TableCellNodeWidgetState();
}

class _TableCellNodeWidgetState extends State<TableCellNodeWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: context.select((Node n) => n.attributes['height']),
      ),
      color: context.select((Node n) {
        if (n.attributes['backgroundColor'] == null) {
          return null;
        }
        final colorInt = int.tryParse(n.attributes['backgroundColor']);
        return colorInt != null ? Color(colorInt) : null;
      }),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: widget.editorState.service.renderPluginService
                .buildPluginWidget(
              widget.node.children.first is TextNode
                  ? NodeWidgetContext<TextNode>(
                      context: context,
                      node: widget.node.children.first as TextNode,
                      editorState: widget.editorState,
                    )
                  : NodeWidgetContext<Node>(
                      context: context,
                      node: widget.node.children.first,
                      editorState: widget.editorState,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
