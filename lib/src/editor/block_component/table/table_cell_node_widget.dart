import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TableCellBlockComponentBuilder extends BlockComponentBuilder {
  TableCellBlockComponentBuilder({
    this.configuration = const BlockComponentConfiguration(),
  });

  @override
  final BlockComponentConfiguration configuration;

  @override
  BlockComponentWidget build(BlockComponentContext blockComponentContext) {
    final node = blockComponentContext.node;
    return TableCellNodeWidget(
      key: node.key,
      node: node,
      configuration: configuration,
      showActions: showActions(node),
      actionBuilder: (context, state) => actionBuilder(
        blockComponentContext,
        state,
      ),
    );
  }

  @override
  bool validate(Node node) =>
      node.attributes.isNotEmpty &&
      node.attributes.containsKey('rowPosition') &&
      node.attributes.containsKey('colPosition');
}

class TableCellNodeWidget extends BlockComponentStatefulWidget {
  const TableCellNodeWidget({
    super.key,
    required super.node,
    super.showActions,
    super.actionBuilder,
    super.configuration = const BlockComponentConfiguration(),
  });

  @override
  State<TableCellNodeWidget> createState() => _TableCellNodeWidgetState();
}

class _TableCellNodeWidgetState extends State<TableCellNodeWidget> {
  late final editorState = Provider.of<EditorState>(context, listen: false);

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
            child: editorState.renderer.build(
              context,
              widget.node.children.first,
            ),
          ),
        ],
      ),
    );
  }
}
