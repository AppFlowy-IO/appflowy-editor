import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_action_handler.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_action_menu.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_config.dart';
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
  });

  @override
  final BlockComponentConfiguration configuration;

  @override
  BlockComponentWidget build(BlockComponentContext blockComponentContext) {
    final node = blockComponentContext.node;
    return TableCelBlockWidget(
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

class TableCelBlockWidget extends BlockComponentStatefulWidget {
  const TableCelBlockWidget({
    super.key,
    required super.node,
    super.showActions,
    super.actionBuilder,
    super.configuration = const BlockComponentConfiguration(),
  });

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
              minHeight: context.select((Node n) => n.attributes['height']),
            ),
            color: context.select((Node n) {
              return (n.attributes['backgroundColor'] as String?)?.toColor();
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
          ),
        ),
        TableActionHandler(
          visible: _rowActionVisibility,
          node: widget.node.parent!,
          editorState: editorState,
          position: widget.node.attributes['rowPosition'],
          transform: context.select((Node n) {
            final int col = n.attributes['colPosition'];
            double left = -15.0;
            for (var i = 0; i < col; i++) {
              left -=
                  getCellNode(n.parent!, i, 0)?.attributes['width'] as double;
              left -= n.parent!.attributes['tableBorderWidth'] ??
                  defaultBorderWidth;
            }

            return Matrix4.translationValues(left, 0.0, 0.0);
          }),
          alignment: Alignment.centerLeft,
          height: context.select((Node n) => n.attributes['height']),
          icon: const Icon(Icons.drag_indicator),
          dir: TableDirection.row,
        ),
      ],
    );
  }
}
