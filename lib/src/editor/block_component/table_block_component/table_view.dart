import 'package:flutter/material.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_node.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_add_button.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_col.dart';

class TableView extends StatefulWidget {
  const TableView({
    super.key,
    required this.editorState,
    required this.tableNode,
    required this.addIcon,
    required this.borderColor,
    required this.borderHoverColor,
    this.menuBuilder,
  });

  final EditorState editorState;
  final TableNode tableNode;

  final Widget addIcon;

  final TableBlockComponentMenuBuilder? menuBuilder;

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
                  padding: const EdgeInsets.only(left: 0),
                  icon: widget.addIcon,
                  width: 28,
                  height: widget.tableNode.colsHeight,
                  onPressed: () {
                    TableActions.add(
                      widget.tableNode.node,
                      widget.tableNode.colsLen,
                      widget.editorState,
                      TableDirection.col,
                    );
                  },
                ),
              ],
            ),
            TableActionButton(
              padding: const EdgeInsets.only(top: 1, right: 30),
              icon: widget.addIcon,
              height: 28,
              width: widget.tableNode.tableWidth,
              onPressed: () {
                TableActions.add(
                  widget.tableNode.node,
                  widget.tableNode.rowsLen,
                  widget.editorState,
                  TableDirection.row,
                );
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
        menuBuilder: widget.menuBuilder,
        borderColor: widget.borderColor,
        borderHoverColor: widget.borderHoverColor,
      ),
    );
  }
}
