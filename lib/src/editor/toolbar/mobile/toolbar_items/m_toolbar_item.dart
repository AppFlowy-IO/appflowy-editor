import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class MToolbarItem {
  Widget itemIcon;
  Widget Function(EditorState editorState, Selection selection)?
      itemMenuBuilder;

  void Function(EditorState editorState, Selection selection)? actionHandler;

  /// Tool bar item that implements attribute directly(without opening menu)
  MToolbarItem.action({
    required this.itemIcon,
    required this.actionHandler,
  });

  /// Tool bar item that opens a menu to show options
  MToolbarItem.withMenu({
    required this.itemIcon,
    required this.itemMenuBuilder,
  });

  bool get hasMenu => itemMenuBuilder != null;
}
