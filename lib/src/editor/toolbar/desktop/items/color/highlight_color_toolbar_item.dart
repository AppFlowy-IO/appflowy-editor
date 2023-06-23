import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

final highlightColorItem = ToolbarItem(
  id: 'editor.highlightColor',
  group: 4,
  isActive: onlyShowInTextType,
  builder: (context, editorState) {
    String? highlightColorHex;

    final selection = editorState.selection!;
    final nodes = editorState.getNodesInSelection(selection);
    final isHighlight = nodes.allSatisfyInSelection(selection, (delta) {
      return delta.everyAttributes(
        (attributes) => attributes[FlowyRichTextKeys.highlightColor] != null,
      );
    });
    return SVGIconItemWidget(
      iconName: 'toolbar/highlight_color',
      iconSize: const Size.square(14),
      isHighlight: isHighlight,
      tooltip: AppFlowyEditorLocalizations.current.highlightColor,
      onPressed: () {
        showColorMenu(
          context,
          editorState,
          selection,
          currentColorHex: highlightColorHex,
          isTextColor: false,
        );
      },
    );
  },
);
