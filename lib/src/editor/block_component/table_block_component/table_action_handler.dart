import 'package:flutter/material.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_action_menu.dart';

class TableActionHandler extends StatefulWidget {
  const TableActionHandler({
    Key? key,
    this.visible = false,
    this.height,
    required this.node,
    required this.editorState,
    required this.position,
    required this.iconBuilder,
    required this.alignment,
    required this.transform,
    required this.dir,
  }) : super(key: key);

  final bool visible;
  final Node node;
  final EditorState editorState;
  final int position;
  final Widget Function({double? size, Color? color}) iconBuilder;
  final Alignment alignment;
  final Matrix4 transform;
  final double? height;
  final TableDirection dir;

  @override
  State<TableActionHandler> createState() => _TableActionHandlerState();
}

class _TableActionHandlerState extends State<TableActionHandler> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: widget.alignment,
      transform: widget.transform,
      height: widget.height,
      child: Visibility(
        visible: widget.visible || _visible,
        child: MouseRegion(
          onEnter: (_) => setState(() => _visible = true),
          onExit: (_) => setState(() => _visible = false),
          child: ActionMenuWidget(
            items: [
              ActionMenuItem(
                iconBuilder: widget.iconBuilder,
                onPressed: () => showActionMenu(
                  context,
                  widget.node,
                  widget.editorState,
                  widget.position,
                  widget.dir,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
