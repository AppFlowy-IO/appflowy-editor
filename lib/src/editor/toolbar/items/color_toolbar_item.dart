import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/toolbar/items/delta_util.dart';
import 'package:appflowy_editor/src/editor/toolbar/items/tooltip_util.dart';
import 'package:appflowy_editor/src/editor/toolbar/items/icon_item_widget.dart';
import 'package:appflowy_editor/src/render/color_menu/color_picker.dart';
import 'package:flutter/material.dart';

final colorItem = ToolbarItem(
  id: 'editor.color',
  isActive: (editorState) => editorState.selection?.isSingle ?? false,
  builder: (context, editorState) {
    final selection = editorState.selection!;
    final nodes = editorState.getNodesInSelection(selection);
    final isHighlight = nodes.allSatisfyInSelection(selection, (delta) {
      return delta.everyAttributes(
        (attributes) {
          // TODO: refactor this part.
          //  just copy from the origin code.
          final color = attributes['color'];
          final backgroundColor = attributes['backgroundColor'];
          final defaultColor = _generateFontColorOptions(
            editorState,
          ).first.colorHex;
          final defaultBackgroundColor = _generateBackgroundColorOptions(
            editorState,
          ).first.colorHex;
          return (color != null && color != defaultColor) ||
              (backgroundColor != null &&
                  backgroundColor != defaultBackgroundColor);
        },
      );
    });
    return IconItemWidget(
      iconName: 'toolbar/highlight',
      isHighlight: isHighlight,
      tooltip:
          '${AppFlowyEditorLocalizations.current.link}${shortcutTooltips("⌘ + K", "CTRL + K", "CTRL + K")}',
      onPressed: () {},
    );
  },
);

List<ColorOption> _generateFontColorOptions(EditorState editorState) {
  final defaultColor =
      editorState.editorStyle.textStyle?.color ?? Colors.black; // black
  return [
    ColorOption(
      colorHex: defaultColor.toHex(),
      name: AppFlowyEditorLocalizations.current.fontColorDefault,
    ),
    ColorOption(
      colorHex: Colors.grey.toHex(),
      name: AppFlowyEditorLocalizations.current.fontColorGray,
    ),
    ColorOption(
      colorHex: Colors.brown.toHex(),
      name: AppFlowyEditorLocalizations.current.fontColorBrown,
    ),
    ColorOption(
      colorHex: Colors.yellow.toHex(),
      name: AppFlowyEditorLocalizations.current.fontColorYellow,
    ),
    ColorOption(
      colorHex: Colors.green.toHex(),
      name: AppFlowyEditorLocalizations.current.fontColorGreen,
    ),
    ColorOption(
      colorHex: Colors.blue.toHex(),
      name: AppFlowyEditorLocalizations.current.fontColorBlue,
    ),
    ColorOption(
      colorHex: Colors.purple.toHex(),
      name: AppFlowyEditorLocalizations.current.fontColorPurple,
    ),
    ColorOption(
      colorHex: Colors.pink.toHex(),
      name: AppFlowyEditorLocalizations.current.fontColorPink,
    ),
    ColorOption(
      colorHex: Colors.red.toHex(),
      name: AppFlowyEditorLocalizations.current.fontColorRed,
    ),
  ];
}

List<ColorOption> _generateBackgroundColorOptions(EditorState editorState) {
  final defaultBackgroundColorHex =
      editorState.editorStyle.highlightColorHex ?? '0x6000BCF0';
  return [
    ColorOption(
      colorHex: defaultBackgroundColorHex,
      name: AppFlowyEditorLocalizations.current.backgroundColorDefault,
    ),
    ColorOption(
      colorHex: Colors.grey.withOpacity(0.3).toHex(),
      name: AppFlowyEditorLocalizations.current.backgroundColorGray,
    ),
    ColorOption(
      colorHex: Colors.brown.withOpacity(0.3).toHex(),
      name: AppFlowyEditorLocalizations.current.backgroundColorBrown,
    ),
    ColorOption(
      colorHex: Colors.yellow.withOpacity(0.3).toHex(),
      name: AppFlowyEditorLocalizations.current.backgroundColorYellow,
    ),
    ColorOption(
      colorHex: Colors.green.withOpacity(0.3).toHex(),
      name: AppFlowyEditorLocalizations.current.backgroundColorGreen,
    ),
    ColorOption(
      colorHex: Colors.blue.withOpacity(0.3).toHex(),
      name: AppFlowyEditorLocalizations.current.backgroundColorBlue,
    ),
    ColorOption(
      colorHex: Colors.purple.withOpacity(0.3).toHex(),
      name: AppFlowyEditorLocalizations.current.backgroundColorPurple,
    ),
    ColorOption(
      colorHex: Colors.pink.withOpacity(0.3).toHex(),
      name: AppFlowyEditorLocalizations.current.backgroundColorPink,
    ),
    ColorOption(
      colorHex: Colors.red.withOpacity(0.3).toHex(),
      name: AppFlowyEditorLocalizations.current.backgroundColorRed,
    ),
  ];
}

extension on Color {
  String toHex() {
    return '0x${value.toRadixString(16)}';
  }
}
