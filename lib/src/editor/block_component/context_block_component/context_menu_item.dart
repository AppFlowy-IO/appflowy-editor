import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

final contextMenuItem = SelectionMenuItem(
  getName: () => 'Context',
  icon: (editorState, isSelected, style) => SelectionMenuIconWidget(
    icon: Symbols.auto_stories_rounded,
    isSelected: isSelected,
    style: style,
  ),
  keywords: ['context', 'info', 'background'],
  handler: (editorState, _, __) {
    insertContextAfterSelection(editorState);
  },
);
