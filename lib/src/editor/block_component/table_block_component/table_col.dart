import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_action_menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_col_border.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/util.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_node.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_action_handler.dart';
import 'dart:math' as math;

class TableCol extends StatefulWidget {
  const TableCol({
    Key? key,
    required this.tableNode,
    required this.editorState,
    required this.colIdx,
  }) : super(key: key);

  final int colIdx;
  final EditorState editorState;
  final TableNode tableNode;

  @override
  State<TableCol> createState() => _TableColState();
}

class _TableColState extends State<TableCol> {
  bool _colActionVisiblity = false;

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    if (widget.colIdx == 0) {
      children.add(
        TableColBorder(
          resizable: false,
          tableNode: widget.tableNode,
          colIdx: widget.colIdx,
        ),
      );
    }

    children.addAll([
      SizedBox(
        width: context.select(
          (Node n) => getCellNode(n, widget.colIdx, 0)?.attributes['width'],
        ),
        child: Stack(
          children: [
            MouseRegion(
              onEnter: (_) => setState(() => _colActionVisiblity = true),
              onExit: (_) => setState(() => _colActionVisiblity = false),
              child: Column(children: _buildCells(context)),
            ),
            TableActionHandler(
              visible: _colActionVisiblity,
              node: widget.tableNode.node,
              editorState: widget.editorState,
              position: widget.colIdx,
              transform: Matrix4.translationValues(0.0, -20.0, 0.0),
              alignment: Alignment.topCenter,
              iconBuilder: ({size, color}) {
                return Transform.rotate(
                  angle: math.pi / 2,
                  child: const Icon(
                    Icons.drag_indicator,
                  ),
                );
              },
              dir: TableDirection.col,
            )
          ],
        ),
      ),
      TableColBorder(
        resizable: true,
        tableNode: widget.tableNode,
        colIdx: widget.colIdx,
      )
    ]);

    return Row(children: children);
  }

  List<Widget> _buildCells(BuildContext context) {
    final rowsLen = widget.tableNode.rowsLen;
    final List<Widget> cells = [];
    final Widget cellBorder = Container(
      height: widget.tableNode.config.tableBorderWidth,
      color: Colors.grey,
    );

    for (var i = 0; i < rowsLen; i++) {
      final node = widget.tableNode.getCell(widget.colIdx, i);

      updateRowHeightCallback(i);
      node.addListener(() => updateRowHeightCallback(i));
      node.children.first.addListener(() => updateRowHeightCallback(i));

      cells.addAll([
        widget.editorState.renderer.build(
          context,
          node,
        ),
        cellBorder
      ]);
    }

    return [
      cellBorder,
      ...cells,
    ];
  }

  void updateRowHeightCallback(int row) =>
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => row < widget.tableNode.rowsLen
            ? widget.tableNode.updateRowHeight(row)
            : null,
      );
}
