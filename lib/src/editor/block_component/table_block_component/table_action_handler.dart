import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_action_menu.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_node.dart';

class TableActionHandler extends StatefulWidget {
  const TableActionHandler({
    Key? key,
    this.visible = false,
    required this.tableNode,
    required this.editorState,
    required this.colIdx,
  }) : super(key: key);

  final bool visible;
  final TableNode tableNode;
  final EditorState editorState;
  final int colIdx;

  @override
  State<TableActionHandler> createState() => _TableActionHandlerState();
}

class _TableActionHandlerState extends State<TableActionHandler> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      transform: Matrix4.translationValues(0.0, -20.0, 0.0),
      child: Visibility(
        visible: widget.visible || _visible,
        child: MouseRegion(
          onEnter: (_) => setState(() => _visible = true),
          onExit: (_) => setState(() => _visible = false),
          child: ActionMenuWidget(
            items: [
              ActionMenuItem(
                iconBuilder: ({size, color}) {
                  return Transform.rotate(
                    angle: math.pi / 2,
                    child: const Icon(
                      Icons.drag_indicator,
                    ),
                  );
                },
                onPressed: () => showColActionMenu(
                  context,
                  widget.tableNode.node,
                  widget.editorState,
                  widget.colIdx,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
