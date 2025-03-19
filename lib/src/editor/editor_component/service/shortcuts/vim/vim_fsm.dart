import 'dart:async';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/extensions/vim_shortcut_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:appflowy_editor/src/editor/command/selection_commands.dart';
import './vim_cursor.dart';

const baseKeys = ['h', 'j', 'k', 'l', 'i', 'a', 'o'];

String _buffer = '';
String _deleteBuffer = '';

CommandShortcutEventHandler vimMoveCursorToStartHandler = (editorState) {
  if (!editorState.vimMode) {
    return KeyEventResult.ignored;
  }
  if (editorState.mode == VimModes.normalMode) {
    final selection = editorState.selection;
    if (selection == null) {
      return KeyEventResult.ignored;
    }
    if (isRTL(editorState)) {
      editorState.moveCursorBackward(SelectionMoveRange.line);
    } else {
      editorState.moveCursorForward(SelectionMoveRange.line);
    }
    return KeyEventResult.handled;
  }
  return KeyEventResult.ignored;
};

CommandShortcutEventHandler vimMoveCursorToEndHandler = (editorState) {
  if (!editorState.vimMode) {
    return KeyEventResult.ignored;
  }
  if (editorState.mode == VimModes.normalMode) {
    final selection = editorState.selection;
    if (selection == null) {
      return KeyEventResult.ignored;
    }
    if (isRTL(editorState)) {
      editorState.moveCursorForward(SelectionMoveRange.line);
    } else {
      editorState.moveCursorBackward(SelectionMoveRange.line);
    }

    return KeyEventResult.handled;
  }
  return KeyEventResult.ignored;
};

Position deleteCurrentLine(EditorState editorState, int count) {
  final selection = editorState.selection;
  if (selection == null) return Position(path: [0], offset: 0);
  final node = editorState.getNodeAtPath(selection.start.path);
  if (node == null || node.delta == null) return Position(path: [0], offset: 0);
  final startPath = selection.start.path.first;
  final endPath = startPath + count - 1;
  final tmpPosition = Position(path: [startPath], offset: 0);
  final delta = node.delta;
  for (int i = startPath; i <= endPath; i++) {
    if (delta != null) {
      final deletionSelection = Selection(
          start: Position(path: selection.start.path, offset: 0),
          end: Position(path: selection.end.path, offset: delta.length));
      editorState.selection = deletionSelection;
      final transaction = editorState.transaction;
      //transaction.deleteText(node, 0, node.delta!.length);
      transaction.deleteNodesAtPath(editorState.selection!.start.path);
      // transaction.deleteNode(node);

      editorState
          .apply(transaction)
          .then((value) => {editorState.selectionType = null});
      editorState.updateSelectionWithReason(
        Selection(start: tmpPosition, end: tmpPosition),
        reason: SelectionUpdateReason.uiEvent,
      );
    }
  }
  return tmpPosition;
}

String keyBuffer = '';
Timer? resetTimer;

class VimFSM {
  KeyEventResult processKey(KeyEvent event, EditorState editorState) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    resetTimer?.cancel();
    resetTimer = Timer(Duration(milliseconds: 500), () {
      keyBuffer = "";
    });

    final key = event.logicalKey.keyLabel.toLowerCase();
    if (baseKeys.contains(key)) {
      final count = _buffer.isNotEmpty ? int.parse(_buffer) : 1;
      resetBuffer();
      final selection = editorState.selection;
      if (selection == null) return KeyEventResult.ignored;

      Position? newPosition =
          VimCursor.processMotionKeys(key, editorState, selection, count);

      if (newPosition != null) {
        editorState.updateSelectionWithReason(
          Selection.collapsed(newPosition),
          reason: SelectionUpdateReason.uiEvent,
        );
        return KeyEventResult.handled;
      }
    } else {
      resetBuffer();

      keyBuffer += key;
      if (RegExp(r'^\d$').hasMatch(key)) {
        if (keyBuffer == 'shift left4' ||
            keyBuffer == 'shift right4' ||
            event.character == '\$') {
          vimMoveCursorToEndHandler(editorState);
          resetSequenceBuffer();
        }
        if (_buffer.isEmpty && key == '0') {
          vimMoveCursorToStartHandler(editorState);
          resetBuffer();
        } else {
          _buffer += key;
          keyBuffer += key;
        }
        return KeyEventResult.handled;
      }

      if (keyBuffer.endsWith('dd')) {
        final RegExp ddRegExp = RegExp(r'^(\d+)?dd$');
        final match = ddRegExp.firstMatch(keyBuffer);
        if (match != null) {
          final String? countStr = match.group(1);
          final int count = (countStr != null && countStr.isNotEmpty)
              ? int.parse(countStr)
              : 1;
          final tmpPosition = deleteCurrentLine(editorState, count);
          editorState.selection = Selection(
            end: tmpPosition,
            start: tmpPosition,
          );
          resetSequenceBuffer();
          return KeyEventResult.handled;
        }
      }

      return KeyEventResult.handled;
    }

    resetBuffer();

    return KeyEventResult.ignored;
  }

  void resetBuffer() {
    _buffer = '';
  }

  void resetSequenceBuffer() {
    keyBuffer = "";
    resetTimer?.cancel();
  }
}
