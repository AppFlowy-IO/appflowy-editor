import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_config.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/util.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_action_menu.dart';

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
  State<TableCelBlockWidget> createState() => _TableCeBlockeWidgetState();
}

class _TableCeBlockeWidgetState extends State<TableCelBlockWidget> {
  late final editorState = Provider.of<EditorState>(context, listen: false);
  bool _rowActionVisiblity = false, _visible = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _rowActionVisiblity = true),
          onExit: (_) => setState(() => _rowActionVisiblity = false),
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
        Container(
          alignment: Alignment.centerLeft,
          height: context.select((Node n) => n.attributes['height']),
          transform: context.select((Node n) {
            final int col = n.attributes['colPosition'];
            double left = 20.0 + n.attributes['width'] / 2;
            for (var i = 0; i <= col; i++) {
              left -=
                  getCellNode(n.parent!, i, 0)?.attributes['width'] as double;
              left -= n.parent!.attributes['tableBorderWidth'] ??
                  defaultBorderWidth;
            }

            return Matrix4.translationValues(left, 0.0, 0.0);
          }),
          child: Visibility(
            visible: _rowActionVisiblity || _visible,
            child: MouseRegion(
              onEnter: (_) => setState(() => _visible = true),
              onExit: (_) => setState(() => _visible = false),
              child: ActionMenuWidget(
                items: [
                  ActionMenuItem(
                    iconBuilder: ({size, color}) {
                      return const Icon(
                        Icons.drag_indicator,
                      );
                    },
                    onPressed: () => showRowActionMenu(
                      context,
                      widget.node.parent!,
                      editorState,
                      widget.node.attributes['rowPosition'],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
