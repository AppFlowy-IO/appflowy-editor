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

  // should abstract this logic to a method
  // ----
  final left = rect.left + 10;
  double? top;
  double? bottom;
  final offset = rect.center;
  final editorOffset = editorState.renderBox!.localToGlobal(Offset.zero);
  final editorHeight = editorState.renderBox!.size.height;
  final threshold = editorOffset.dy + editorHeight - 200;
  if (offset.dy > threshold) {
    bottom = editorOffset.dy + editorHeight - rect.top - 5;
  } else {
    top = rect.bottom + 5;
  }
  // ----

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
  // if the color is empty, remove the highlight color format
  editorState.formatDelta(
    editorState.selection,
    {
      FlowyRichTextKeys.highlightColor: color.isEmpty ? null : color,
    },
  );
}

void _formatFontColor(EditorState editorState, String color) {
  // if the color is empty, remove the color format
  editorState.formatDelta(
    editorState.selection,
    {
      FlowyRichTextKeys.textColor: color.isEmpty ? null : color,
    },
  );
}

List<ColorOption> _generateTextColorOptions(EditorState editorState) {
  return [
    ColorOption(
      colorHex: '',
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
  return [
    ColorOption(
      colorHex: '',
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
