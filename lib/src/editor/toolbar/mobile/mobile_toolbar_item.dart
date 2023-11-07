import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

typedef MobileToolbarItemMenuBuilder = Widget Function(
  EditorState editorState,
  Selection selection,
  // To access to the state of MobileToolbarWidget
  MobileToolbarWidgetService service,
);

typedef MobileToolbarItemActionHandler = void Function(
  EditorState editorState,
  Selection selection,
);

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

  final bool hasMenu;
  final Widget itemIcon;
  final MobileToolbarItemMenuBuilder? itemMenuBuilder;
  final MobileToolbarItemActionHandler? actionHandler;
}
