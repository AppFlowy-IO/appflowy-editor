import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class MobileToolbarItem {
  /// Tool bar item that implements attribute directly(without opening menu)
  const MobileToolbarItem.action({
    required this.itemIcon,
    required this.actionHandler,
  })  : hasMenu = false,
        itemMenuBuilder = null;

  /// Tool bar item that opens a menu to show options
  const MobileToolbarItem.withMenu({
    required this.itemIcon,
    required this.itemMenuBuilder,
  })  : hasMenu = true,
        actionHandler = null;
  final Widget itemIcon;
  final Widget Function(EditorState editorState, Selection selection)?
      itemMenuBuilder;
  final void Function(EditorState editorState, Selection selection)?
      actionHandler;
  final bool hasMenu;
}
