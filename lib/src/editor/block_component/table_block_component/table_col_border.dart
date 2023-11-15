import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_node.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TableColBorder extends StatefulWidget {
  const TableColBorder({
    super.key,
    required this.tableNode,
    required this.editorState,
    required this.colIdx,
    required this.resizable,
    required this.borderColor,
    required this.borderHoverColor,
  });

  final bool resizable;
  final int colIdx;
  final TableNode tableNode;
  final EditorState editorState;

  final Color borderColor;
  final Color borderHoverColor;

  @override
  State<TableColBorder> createState() => _TableColBorderState();
}

class _TableColBorderState extends State<TableColBorder> {
  final GlobalKey _borderKey = GlobalKey();
  bool _borderHovering = false;
  bool _borderDragging = false;

  Offset initialOffset = const Offset(0, 0);

  @override
  Widget build(BuildContext context) {
    return widget.resizable
        ? buildResizableBorder(context)
        : buildFixedBorder(context);
  }

  MouseRegion buildResizableBorder(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight,
      onEnter: (_) => setState(() => _borderHovering = true),
      onExit: (_) => setState(() => _borderHovering = false),
      child: GestureDetector(
        onHorizontalDragStart: (DragStartDetails details) {
          setState(() => _borderDragging = true);
          initialOffset = details.globalPosition;
        },
        onHorizontalDragEnd: (_) {
          final transaction = widget.editorState.transaction;
          widget.tableNode.setColWidth(
            widget.colIdx,
            widget.tableNode.getColWidth(widget.colIdx),
            transaction: transaction,
            force: true,
          );
          transaction.afterSelection = transaction.beforeSelection;
          widget.editorState.apply(transaction);
          setState(() => _borderDragging = false);
        },
        onHorizontalDragUpdate: (DragUpdateDetails details) {
          final colWidth = widget.tableNode.getColWidth(widget.colIdx);
          widget.tableNode
              .setColWidth(widget.colIdx, colWidth + details.delta.dx);
        },
        child: Container(
          key: _borderKey,
          width: widget.tableNode.config.borderWidth,
          height: context
              .select((Node n) => n.attributes[TableBlockKeys.colsHeight]),
          color: _borderHovering || _borderDragging
              ? widget.borderHoverColor
              : widget.borderColor,
        ),
      ),
    );
  }

  Container buildFixedBorder(BuildContext context) {
    return Container(
      width: widget.tableNode.config.borderWidth,
      height:
          context.select((Node n) => n.attributes[TableBlockKeys.colsHeight]),
      color: Colors.grey,
    );
  }
}
