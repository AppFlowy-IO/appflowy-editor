import 'package:flutter/material.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_action.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_node.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_add_button.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_col.dart';

class TableView extends StatefulWidget {
  const TableView({
    Key? key,
    required this.editorState,
    required this.tableNode,
    required this.addIcon,
    required this.handlerIcon,
    required this.borderColor,
    required this.borderHoverColor,
  }) : super(key: key);

  final EditorState editorState;
  final TableNode tableNode;

  final Widget addIcon;
  final Widget handlerIcon;

  final Color borderColor;
  final Color borderHoverColor;

  @override
  State<TableView> createState() => _TableViewState();
}

class _TableViewState extends State<TableView> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          children: [
            Row(
              children: [
                ..._buildColumns(context),
                TableActionButton(
                  padding: const EdgeInsets.only(left: 1),
                  icon: widget.addIcon,
                  width: 35,
                  height: widget.tableNode.colsHeight,
                  onPressed: () {
                    final transaction = widget.editorState.transaction;
                    addCol(
                      widget.tableNode.node,
                      widget.tableNode.colsLen,
                      transaction,
                    );
                    widget.editorState.apply(transaction);
                  },
                ),
              ],
            ),
            TableActionButton(
              padding: const EdgeInsets.only(top: 1, right: 32),
              icon: widget.addIcon,
              height: 35,
              width: widget.tableNode.tableWidth,
              onPressed: () {
                final transaction = widget.editorState.transaction;
                addRow(
                  widget.tableNode.node,
                  widget.tableNode.rowsLen,
                  transaction,
                );
                widget.editorState.apply(transaction);
              },
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildColumns(BuildContext context) {
    return List.generate(
      widget.tableNode.colsLen,
      (i) => TableCol(
        colIdx: i,
        editorState: widget.editorState,
        tableNode: widget.tableNode,
        handlerIcon: widget.handlerIcon,
        borderColor: widget.borderColor,
        borderHoverColor: widget.borderHoverColor,
      ),
    );
  }
}
