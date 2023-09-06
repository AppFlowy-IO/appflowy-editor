import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_action_handler.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_col_border.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_node.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TableCol extends StatefulWidget {
  const TableCol({
    Key? key,
    required this.tableNode,
    required this.editorState,
    required this.colIdx,
    required this.borderColor,
    required this.borderHoverColor,
    this.menuBuilder,
  }) : super(key: key);

  final int colIdx;
  final EditorState editorState;
  final TableNode tableNode;

  final TableBlockComponentMenuBuilder? menuBuilder;

  final Color borderColor;
  final Color borderHoverColor;

  @override
  State<TableCol> createState() => _TableColState();
}

class _TableColState extends State<TableCol> {
  bool _colActionVisiblity = false;

  Map<String, void Function()> listeners = {};

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    if (widget.colIdx == 0) {
      children.add(
        TableColBorder(
          resizable: false,
          tableNode: widget.tableNode,
          editorState: widget.editorState,
          colIdx: widget.colIdx,
          borderColor: widget.borderColor,
          borderHoverColor: widget.borderHoverColor,
        ),
      );
    }

    children.addAll([
      SizedBox(
        width: context.select(
          (Node n) => getCellNode(n, widget.colIdx, 0)
              ?.attributes[TableCellBlockKeys.width],
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
              transform: Matrix4.translationValues(0.0, -12, 0.0),
              alignment: Alignment.topCenter,
              menuBuilder: widget.menuBuilder,
              dir: TableDirection.col,
            ),
          ],
        ),
      ),
      TableColBorder(
        resizable: true,
        tableNode: widget.tableNode,
        editorState: widget.editorState,
        colIdx: widget.colIdx,
        borderColor: widget.borderColor,
        borderHoverColor: widget.borderHoverColor,
      ),
    ]);

    return Row(children: children);
  }

  List<Widget> _buildCells(BuildContext context) {
    final rowsLen = widget.tableNode.rowsLen;
    final List<Widget> cells = [];
    final Widget cellBorder = Container(
      height: widget.tableNode.config.borderWidth,
      color: widget.borderColor,
    );

    for (var i = 0; i < rowsLen; i++) {
      final node = widget.tableNode.getCell(widget.colIdx, i);
      updateRowHeightCallback(i);
      addListener(node, i);
      addListener(node.children.first, i);

      cells.addAll([
        widget.editorState.renderer.build(
          context,
          node,
        ),
        cellBorder,
      ]);
    }

    return [
      cellBorder,
      ...cells,
    ];
  }

  void addListener(Node node, int row) {
    if (listeners.containsKey(node.id)) {
      return;
    }

    listeners[node.id] = () => updateRowHeightCallback(row);
    node.addListener(listeners[node.id]!);
  }

  void updateRowHeightCallback(int row) =>
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (row >= widget.tableNode.rowsLen) {
          return;
        }

        final transaction = widget.editorState.transaction;
        widget.tableNode.updateRowHeight(row, transaction: transaction);
        if (transaction.operations.isNotEmpty) {
          transaction.afterSelection = transaction.beforeSelection;
          widget.editorState.apply(transaction);
        }
      });
}
