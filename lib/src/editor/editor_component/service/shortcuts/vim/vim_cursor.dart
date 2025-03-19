import 'dart:async';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/command/selection_commands.dart';
import 'package:appflowy_editor/src/extensions/vim_shortcut_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:appflowy_editor/src/editor_state.dart';

const baseKeys = ['h', 'j', 'k', 'l', 'i', 'a', 'o'];
// String buffer = '';

class VimCursor {
  static Position? processMotionKeys(
      String key, EditorState editorState, Selection selection, int count) {
    switch (key) {
      case 'j':
        {
          int tmpPos = count + selection.end.path.first;
          if (tmpPos < editorState.document.root.children.length) {
            //BUG: This causes editor to say null value on places where offset is empty
            // Position(path: [tmpPos], offset: selection.end.offset ?? 0);
            return Position(path: [tmpPos], offset: 0);
          }
          //newPosition = Position(path: [count+selection.end.path.first]);
        }

      case 'k':
        {
          int tmpPos = selection.end.path.first - count;
          if (tmpPos < editorState.document.root.children.length) {
            //BUG: This causes editor to say null value on places where offset is empty
            // Position(path: [tmpPos], offset: selection.end.offset ?? 0);
            return Position(path: [tmpPos], offset: 0);
          }
        }
      case 'h':
        return moveHorizontalMultiple(
          editorState,
          selection.end,
          forward: true,
          count: count,
        );

      case 'l':
        return moveHorizontalMultiple(
          editorState,
          selection.end,
          forward: false,
          count: count,
        );
      case 'i':
        {
          editorState.editable = true;
          editorState.mode = VimModes.insertMode;
          editorState.selection = editorState.selection;
          editorState.selectionService.updateSelection(editorState.selection);
          editorState.prevSelection = null;
          return Position(
            path: editorState.selection!.end.path,
            offset: editorState.selection!.end.offset,
          );
        }
      default:
        return null;
    }
    return null;
  }
}
