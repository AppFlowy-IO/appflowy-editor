import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

// if the result is null, the item will be hidden
typedef MobileToolbarItemIconBuilder = Widget? Function(
  BuildContext context,
  EditorState editorState,
  // To access to the state of MobileToolbarWidget
  MobileToolbarWidgetService service,
);

typedef MobileToolbarItemActionHandler = void Function(
  BuildContext context,
  EditorState editorState,
);

class MobileToolbarItem {
  /// Tool bar item that implements attribute directly(without opening menu)
  const MobileToolbarItem.action({
    required this.itemIconBuilder,
    required this.actionHandler,
  })  : hasMenu = false,
        itemMenuBuilder = null,
        assert(itemIconBuilder != null && actionHandler != null);

  /// Tool bar item that opens a menu to show options
  const MobileToolbarItem.withMenu({
    required this.itemIconBuilder,
    required this.itemMenuBuilder,
  })  : hasMenu = true,
        actionHandler = null,
        assert(itemMenuBuilder != null && itemIconBuilder != null);

  // if the result is null, the item will be hidden
  final MobileToolbarItemIconBuilder? itemIconBuilder;
  final MobileToolbarItemActionHandler? actionHandler;

  final bool hasMenu;
  final MobileToolbarItemIconBuilder? itemMenuBuilder;
}
