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
  final rect = editorState.selectionRects.first;
  OverlayEntry? overlay;

  void dismissOverlay() {
    overlay?.remove();
    overlay = null;
  }

  overlay = FullScreenOverlayEntry(
    top: rect.bottom + 5,
    left: rect.left + 10,
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
  final selection = editorState.selection!;
  editorState.formatDelta(selection, {'highlightColor': color});
}

void _formatFontColor(EditorState editorState, String color) {
  final selection = editorState.selection!;
  //Since there is no additional color for the text, remove the 'textColor' attribute, so that the textColor item on the toolbar won't be highlighted
  //'0xff000000' is the deault color when developer doesn't set.
  if (color == editorState.editorStyle.textStyle?.color?.toHex() ||
      color == '0xff000000') {
    editorState.formatDelta(selection, {'textColor': null});
  } else {
    editorState.formatDelta(selection, {'textColor': color});
  }
}

List<ColorOption> _generateTextColorOptions(EditorState editorState) {
  final defaultColor = editorState.editorStyle.textStyle?.color ??
      Colors.black; // the deault text color when developer doesn't set
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

List<ColorOption> _generateHighlightColorOptions(EditorState editorState) {
  final defaultBackgroundColorHex = editorState.editorStyle.highlightColorHex ??
      '0x6000BCF0'; // the deault highlight color when developer doesn't set
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
