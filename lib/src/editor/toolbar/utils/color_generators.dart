import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// Default text color options when no option is provided
/// - support
///   - desktop
///   - web
///   - mobile
///
List<ColorOption> generateTextColorOptions() {
  return [
    ColorOption(
      colorHex: Colors.grey.toHex(),
      name: AppFlowyEditorL10n.current.fontColorGray,
    ),
    ColorOption(
      colorHex: Colors.brown.toHex(),
      name: AppFlowyEditorL10n.current.fontColorBrown,
    ),
    ColorOption(
      colorHex: Colors.yellow.toHex(),
      name: AppFlowyEditorL10n.current.fontColorYellow,
    ),
    ColorOption(
      colorHex: Colors.green.toHex(),
      name: AppFlowyEditorL10n.current.fontColorGreen,
    ),
    ColorOption(
      colorHex: Colors.blue.toHex(),
      name: AppFlowyEditorL10n.current.fontColorBlue,
    ),
    ColorOption(
      colorHex: Colors.purple.toHex(),
      name: AppFlowyEditorL10n.current.fontColorPurple,
    ),
    ColorOption(
      colorHex: Colors.pink.toHex(),
      name: AppFlowyEditorL10n.current.fontColorPink,
    ),
    ColorOption(
      colorHex: Colors.red.toHex(),
      name: AppFlowyEditorL10n.current.fontColorRed,
    ),
  ];
}

/// Default background color options when no option is provided
/// - support
///   - desktop
///   - web
///   - mobile
///
List<ColorOption> generateHighlightColorOptions() {
  return [
    ColorOption(
      colorHex: Colors.grey.withValues(alpha: 0.3).toHex(),
      name: AppFlowyEditorL10n.current.backgroundColorGray,
    ),
    ColorOption(
      colorHex: Colors.brown.withValues(alpha: 0.3).toHex(),
      name: AppFlowyEditorL10n.current.backgroundColorBrown,
    ),
    ColorOption(
      colorHex: Colors.yellow.withValues(alpha: 0.3).toHex(),
      name: AppFlowyEditorL10n.current.backgroundColorYellow,
    ),
    ColorOption(
      colorHex: Colors.green.withValues(alpha: 0.3).toHex(),
      name: AppFlowyEditorL10n.current.backgroundColorGreen,
    ),
    ColorOption(
      colorHex: Colors.blue.withValues(alpha: 0.3).toHex(),
      name: AppFlowyEditorL10n.current.backgroundColorBlue,
    ),
    ColorOption(
      colorHex: Colors.purple.withValues(alpha: 0.3).toHex(),
      name: AppFlowyEditorL10n.current.backgroundColorPurple,
    ),
    ColorOption(
      colorHex: Colors.pink.withValues(alpha: 0.3).toHex(),
      name: AppFlowyEditorL10n.current.backgroundColorPink,
    ),
    ColorOption(
      colorHex: Colors.red.withValues(alpha: 0.3).toHex(),
      name: AppFlowyEditorL10n.current.backgroundColorRed,
    ),
  ];
}
