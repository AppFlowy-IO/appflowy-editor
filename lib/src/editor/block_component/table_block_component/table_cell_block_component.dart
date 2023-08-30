import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_action_handler.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TableCellBlockKeys {
  const TableCellBlockKeys._();

  static const String type = 'table/cell';
}

class TableCellBlockComponentBuilder extends BlockComponentBuilder {
  TableCellBlockComponentBuilder({
    this.configuration = const BlockComponentConfiguration(),
    this.menuBuilder,
  });

  @override
  final BlockComponentConfiguration configuration;

  final TableBlockComponentMenuBuilder? menuBuilder;

  @override
  BlockComponentWidget build(BlockComponentContext blockComponentContext) {
    final node = blockComponentContext.node;
    return TableCelBlockWidget(
      key: node.key,
      node: node,
      configuration: configuration,
      menuBuilder: menuBuilder,
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
      node.attributes.containsKey(TableBlockKeys.rowPosition) &&
      node.attributes.containsKey(TableBlockKeys.colPosition);
}

class TableCelBlockWidget extends BlockComponentStatefulWidget {
  const TableCelBlockWidget({
    super.key,
    required super.node,
    this.menuBuilder,
    super.showActions,
    super.actionBuilder,
    super.configuration = const BlockComponentConfiguration(),
  });

  final TableBlockComponentMenuBuilder? menuBuilder;

  @override
  State<TableCelBlockWidget> createState() => _TableCeBlockWidgetState();
}

class _TableCeBlockWidgetState extends State<TableCelBlockWidget> {
  late final editorState = Provider.of<EditorState>(context, listen: false);
  bool _rowActionVisibility = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _rowActionVisibility = true),
          onExit: (_) => setState(() => _rowActionVisibility = false),
          child: Container(
            constraints: BoxConstraints(
              minHeight: context
                  .select((Node n) => n.attributes[TableBlockKeys.height]),
            ),
            color: context.select(
              (Node n) =>
                  (n.attributes[TableBlockKeys.colBackgroundColor] as String?)
                      ?.toColor() ??
                  (n.attributes[TableBlockKeys.rowBackgroundColor] as String?)
                      ?.toColor(),
            ),
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
          ),
        ),
        TableActionHandler(
          visible: _rowActionVisibility,
          node: widget.node.parent!,
          editorState: editorState,
          position: widget.node.attributes[TableBlockKeys.rowPosition],
          transform: context.select((Node n) {
            final int col = n.attributes[TableBlockKeys.colPosition];
            double left = -15.0;
            for (var i = 0; i < col; i++) {
              left -= getCellNode(n.parent!, i, 0)
                  ?.attributes[TableBlockKeys.width] as double;
              left -= n.parent!.attributes['borderWidth'] ??
                  TableDefaults.borderWidth;
            }

            return Matrix4.translationValues(left, 0.0, 0.0);
          }),
          alignment: Alignment.centerLeft,
          height:
              context.select((Node n) => n.attributes[TableBlockKeys.height]),
          menuBuilder: widget.menuBuilder,
          dir: TableDirection.row,
        ),
      ],
    );
  }
}
