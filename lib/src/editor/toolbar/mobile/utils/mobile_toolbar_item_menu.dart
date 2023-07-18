import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class MobileToolbarItemMenu extends StatefulWidget {
  const MobileToolbarItemMenu({
    super.key,
    required this.editorState,
    required this.itemMenuBuilder,
  });

  final EditorState editorState;
  final Widget Function() itemMenuBuilder;

  @override
  State<MobileToolbarItemMenu> createState() => _MobileToolbarItemMenuState();
}

class _MobileToolbarItemMenuState extends State<MobileToolbarItemMenu> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final style = MobileToolbarStyle.of(context);

    return Container(
      width: size.width,
      color: style.backgroundColor,
      padding: const EdgeInsets.all(8),
      child: widget.itemMenuBuilder(),
    );
  }
}
