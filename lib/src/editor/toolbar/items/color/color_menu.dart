import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

void showColorMenu(
  BuildContext context,
  EditorState editorState,
  Selection selection, {
  String? currentColorHex,
  required bool isTextColor,
}) {
  // Since link format is only available for single line selection,
  // the first rect(also the only rect) is used as the starting reference point for the [overlay] position
  final rect = editorState.selectionRects().first;
  OverlayEntry? overlay;

  void dismissOverlay() {
    overlay?.remove();
    overlay = null;
  }

  overlay = FullScreenOverlayEntry(
    top: rect.bottom + 5,
    left: rect.left,
    builder: (context) {
      return ColorPicker(
        isTextColor: isTextColor,
        editorState: editorState,
        selectedColorHex: currentColorHex,
        colorOptions: isTextColor
            ? _generateTextColorOptions(editorState)
            : _generateHighlightColorOptions(editorState),
        onSubmittedColorHex: (color) {
          isTextColor
              ? _formatFontColor(
                  editorState,
                  color,
                )
              : _formatHighlightColor(
                  editorState,
                  color,
                );
          dismissOverlay();
        },
        onDismiss: dismissOverlay,
      );
    },
  ).build();
  Overlay.of(context).insert(overlay!);
}

void _formatHighlightColor(EditorState editorState, String color) {
  editorState.formatDelta(
    editorState.selection,
    {FlowyRichTextKeys.highlightColor: color},
  );
}

void _formatFontColor(EditorState editorState, String color) {
  editorState.formatDelta(
    editorState.selection,
    {FlowyRichTextKeys.textColor: color},
  );
}

List<ColorOption> _generateTextColorOptions(EditorState editorState) {
  return [
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

List<ColorOption> _generateHighlightColorOptions(EditorState editorState) {
  return [
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
