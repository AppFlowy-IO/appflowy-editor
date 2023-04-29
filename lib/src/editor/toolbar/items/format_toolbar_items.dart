import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/toolbar/items/icon_item_widget.dart';
import 'package:flutter/foundation.dart';

List<ToolbarItem> formatItems = _formatItems
    .map(
      (e) => ToolbarItem(
        id: 'editor.${e.name}',
        isActive: (editorState) => editorState.selection?.isSingle ?? false,
        builder: (context, editorState) {
          final selection = editorState.selection!;
          final nodes = editorState.getNodesInSelection(selection);
          final isHighlight = nodes.allSatisfyInSelection(selection, (delta) {
            return delta.everyAttributes(
              (attributes) => attributes[e.name] == true,
            );
          });
          return IconItemWidget(
            iconName: 'toolbar/${e.name}',
            isHighlight: isHighlight,
            tooltip: e.tooltip,
            onPressed: () {},
          );
        },
      ),
    )
    .toList();

class _FormatItem {
  const _FormatItem({
    required this.name,
    required this.tooltip,
  });

  final String name;
  final String tooltip;
}

List<_FormatItem> _formatItems = [
  _FormatItem(
    name: 'underline',
    tooltip:
        '${AppFlowyEditorLocalizations.current.underline}${_shortcutTooltips('⌘ + U', 'CTRL + U', 'CTRL + U')}',
  ),
  _FormatItem(
    name: 'bold',
    tooltip:
        '${AppFlowyEditorLocalizations.current.bold}${_shortcutTooltips('⌘ + B', 'CTRL + B', 'CTRL + B')}',
  ),
  _FormatItem(
    name: 'italic',
    tooltip:
        '${AppFlowyEditorLocalizations.current.bold}${_shortcutTooltips('⌘ + I', 'CTRL + I', 'CTRL + I')}',
  ),
  _FormatItem(
    name: 'strikethrough',
    tooltip:
        '${AppFlowyEditorLocalizations.current.strikethrough}${_shortcutTooltips('⌘ + SHIFT + S', 'CTRL + SHIFT + S', 'CTRL + SHIFT + S')}',
  ),
  _FormatItem(
    name: 'code',
    tooltip:
        '${AppFlowyEditorLocalizations.current.strikethrough}${_shortcutTooltips('⌘ + E', 'CTRL + E', 'CTRL + E')}',
  ),
];

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

extension on Delta {
  bool everyAttributes(bool Function(Attributes element) test) =>
      whereType<TextInsert>().every((element) {
        final attributes = element.attributes;
        return attributes != null && test(attributes);
      });
}
