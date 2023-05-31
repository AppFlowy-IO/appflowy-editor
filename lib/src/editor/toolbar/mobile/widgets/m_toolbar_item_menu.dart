import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class MToolbarItemMenu extends StatelessWidget {
  const MToolbarItemMenu({
    super.key,
    required this.editorState,
    required this.itemMenu,
  });

  final EditorState editorState;
  final Widget itemMenu;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      color: MColors.toolbarBgColor,
      padding: const EdgeInsets.all(8),
      child: itemMenu,
    );
  }
}
