import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

GlobalKey<MobileToolbarItemMenuState> mobileToolbarItemMenuStateKey =
    GlobalKey();

class MobileToolbarItemMenu extends StatefulWidget {
  const MobileToolbarItemMenu({
    super.key,
    required this.editorState,
    required this.itemMenu,
  });

  final EditorState editorState;
  final Widget itemMenu;

  @override
  State<MobileToolbarItemMenu> createState() => MobileToolbarItemMenuState();
}

class MobileToolbarItemMenuState extends State<MobileToolbarItemMenu> {
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
