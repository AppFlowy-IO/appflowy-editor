import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

abstract class MobileToolbarItemMenuService {
  void closeItemMenu();
}

class MobileToolbarItemMenu extends StatefulWidget {
  const MobileToolbarItemMenu({
    super.key,
    required this.editorState,
    required this.itemMenuBuilder,
  });

  final EditorState editorState;
  final Widget Function(MobileToolbarItemMenuState state) itemMenuBuilder;

  @override
  State<MobileToolbarItemMenu> createState() => MobileToolbarItemMenuState();
}

class MobileToolbarItemMenuState extends State<MobileToolbarItemMenu>
    implements MobileToolbarItemMenuService {
  bool _showMenu = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final style = MobileToolbarStyle.of(context);
    return _showMenu
        ? Container(
            width: size.width,
            color: style.backgroundColor,
            padding: const EdgeInsets.all(8),
            child: widget.itemMenuBuilder(this),
          )
        : const SizedBox.shrink();
  }

  @override
  void closeItemMenu() {
    setState(() {
      _showMenu = false;
    });
  }
}
