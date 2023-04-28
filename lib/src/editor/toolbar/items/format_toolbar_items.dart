import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/toolbar/items/icon_item_widget.dart';
import 'package:flutter/foundation.dart';

ToolbarItem underlineItem = ToolbarItem(
  id: 'editor.paragraph',
  isActive: (editorState) => editorState.selection?.isSingle ?? false,
  builder: (context, editorState) {
    final selection = editorState.selection!;
    final node = editorState.getNodeAtPath(selection.start.path)!;
    final isHighlight = node.type == 'quote';
    return IconItemWidget(
      iconName: 'toolbar/bold',
      isHighlight: isHighlight,
      tooltip:
          '${AppFlowyEditorLocalizations.current.bold}${_shortcutTooltips('⌘ + B', 'CTRL + B', 'CTRL + B')}',
      onPressed: () {},
    );
  },
);

String _shortcutTooltips(
  String? macOSString,
  String? windowsString,
  String? linuxString,
) {
  if (kIsWeb) return '';
  if (Platform.isMacOS && macOSString != null) {
    return '\n$macOSString';
  } else if (Platform.isWindows && windowsString != null) {
    return '\n$windowsString';
  } else if (Platform.isLinux && linuxString != null) {
    return '\n$linuxString';
  }
  return '';
}
