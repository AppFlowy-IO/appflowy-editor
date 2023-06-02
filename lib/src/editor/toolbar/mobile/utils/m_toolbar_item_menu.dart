import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

GlobalKey<MToolbarItemMenuState> mToolbarItemMenuStateKey = GlobalKey();

class MToolbarItemMenu extends StatefulWidget {
  const MToolbarItemMenu({
    super.key,
    required this.editorState,
    required this.itemMenu,
  });

  final EditorState editorState;
  final Widget itemMenu;

  @override
  State<MToolbarItemMenu> createState() => MToolbarItemMenuState();
}

class MToolbarItemMenuState extends State<MToolbarItemMenu> {
  late bool _showMenu;

  @override
  void initState() {
    super.initState();
    _showMenu = true;
  }

  void closeItemMenu() {
    setState(() {
      _showMenu = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return _showMenu
        ? Container(
            width: size.width,
            color: MColors.toolbarBgColor,
            padding: const EdgeInsets.all(8),
            child: widget.itemMenu,
          )
        : const SizedBox.shrink();
  }
}
