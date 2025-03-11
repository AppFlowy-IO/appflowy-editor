import 'package:appflowy_editor/src/extensions/vim_shortcut_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:appflowy_editor/appflowy_editor.dart';

const baseKeys = ['h', 'j', 'k', 'l'];

class VimFSM {
  String _buffer = '';

  KeyEventResult processKey(KeyEvent event, EditorState editorState) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey.keyLabel.toLowerCase();

    if (RegExp(r'^\d$').hasMatch(key)) {
      _buffer += key;
      return KeyEventResult.handled;
    }

    Position? newPosition;
    if (baseKeys.contains(key)) {
      final count = _buffer.isNotEmpty ? int.parse(_buffer) : 1;
      _buffer = '';
      final selection = editorState.selection;
      if (selection == null) return KeyEventResult.ignored;

      switch (key) {
        case 'j':
          newPosition = moveVerticalMultiple(
            editorState,
            selection.end,
            upwards: false,
            count: count,
          );
          break;

        case 'k':
          newPosition = moveVerticalMultiple(
            editorState,
            selection.end,
            upwards: true,
            count: count,
          );
          break;
        case 'h':
          newPosition = moveHorizontalMultiple(
            editorState,
            selection.end,
            forward: false,
            count: count,
          );
          break;
        case 'l':
          newPosition = moveHorizontalMultiple(
            editorState,
            selection.end,
            forward: true,
            count: count,
          );
          break;
      }
      if (newPosition != null) {
        editorState.updateSelectionWithReason(
          Selection.collapsed(newPosition),
          reason: SelectionUpdateReason.uiEvent,
        );
        return KeyEventResult.handled;
      }
    }
    _buffer = '';
    return KeyEventResult.ignored;
  }

  void reset() {
    _buffer = '';
  }
}
