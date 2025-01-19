import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

final transitionMenuItem = SelectionMenuItem(
  getName: () => 'Transition',
  icon: (editorState, isSelected, style) => SelectionMenuIconWidget(
    icon: Symbols.compare_arrows_rounded,
    isSelected: isSelected,
    style: style,
  ),
  keywords: ['transition', 'change', 'scene'],
  handler: (editorState, _, __) {
    insertTransitionAfterSelection(editorState);
  },
);
