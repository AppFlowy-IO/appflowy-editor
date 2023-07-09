import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/toolbar/desktop/items/utils/overlay_util.dart';
import 'package:flutter/material.dart';

void showColorMenu(
  BuildContext context,
  EditorState editorState,
  Selection selection, {
  String? currentColorHex,
  List<ColorOption>? textColorOptions,
  List<ColorOption>? highlightColorOptions,
  required bool isTextColor,
}) {
  // Since link format is only available for single line selection,
  // the first rect(also the only rect) is used as the starting reference point for the [overlay] position
  final rect = editorState.selectionRects().first;
  OverlayEntry? overlay;

  final (top, bottom, left) = positionFromRect(rect, editorState);

  void dismissOverlay() {
    overlay?.remove();
    overlay = null;
  }

  overlay = FullScreenOverlayEntry(
    top: top,
    bottom: bottom,
    left: left,
    builder: (context) {
      return ColorPicker(
        title: isTextColor
            ? AppFlowyEditorLocalizations.current.textColor
            : AppFlowyEditorLocalizations.current.highlightColor,
        selectedColorHex: currentColorHex,
        colorOptions: isTextColor
            ? textColorOptions ?? generateTextColorOptions()
            : highlightColorOptions ?? generateHighlightColorOptions(),
        onSubmittedColorHex: (color) {
          isTextColor
              ? formatFontColor(
                  editorState,
                  color,
                )
              : formatHighlightColor(
                  editorState,
                  color,
                );
          dismissOverlay();
        },
        resetText: isTextColor
            ? AppFlowyEditorLocalizations.current.resetToDefaultColor
            : AppFlowyEditorLocalizations.current.clearHighlightColor,
        resetIconName:
            isTextColor ? 'reset_text_color' : 'clear_highlight_color',
      );
    },
  ).build();
  Overlay.of(context).insert(overlay!);
}
