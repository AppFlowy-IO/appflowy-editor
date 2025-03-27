import 'dart:async';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/extensions/vim_shortcut_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:appflowy_editor/src/editor/command/selection_commands.dart';
import './vim_cursor.dart';

const baseKeys = ['h', 'j', 'k', 'l', 'i'];

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
  //print('start delete point: $startPath');
  final endPath = startPath + count - 1;
  //print('final end point: $endPath');
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

String deleteBuffer = '';

class VimFSM {
  KeyEventResult processKey(KeyEvent event, EditorState editorState) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    resetTimer?.cancel();
    resetTimer = Timer(Duration(milliseconds: 500), () {
      keyBuffer = "";
      _buffer = "";
    });
    final key = event.logicalKey.keyLabel.toLowerCase();
    if (baseKeys.contains(key)) {
      //print('buffer key readout: $_buffer');
      final count = _buffer.isNotEmpty ? int.parse(_buffer) : 1;
      //print('counter for debugger: $count');
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
        resetBuffer();
        return KeyEventResult.handled;
      }
    } else {
      //BUG: _buffer is causing double keys like 440 instead of 40
      _buffer += key;
      deleteBuffer += key;
      //NOTE: Resetting the _buffer here will break line jumping
      // resetBuffer();
      resetSequenceBuffer();

      keyBuffer += key;
      /*print(
          'After appending, keyBuffer="$keyBuffer", _buffer="$_buffer", deleteBuffer="$deleteBuffer"');
          */
      if (RegExp(r'^\d$').hasMatch(key)) {
        if (_buffer == 'shift left4' ||
            _buffer == 'shift right4' ||
            event.character == '\$') {
          vimMoveCursorToEndHandler(editorState);
          resetSequenceBuffer();
          resetBuffer();
        }

        if (keyBuffer == '0' && _buffer == '0') {
          vimMoveCursorToStartHandler(editorState);
          resetBuffer();
          resetSequenceBuffer();
        }
        return KeyEventResult.handled;
      }

      if (deleteBuffer.endsWith('dd')) {
        // final tmpString = deleteBuffer + keyBuffer;
        final RegExp ddRegExp = RegExp(r'^(\d+)?dd$');
        final match = ddRegExp.firstMatch(deleteBuffer);
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
          deleteBuffer = '';
          keyBuffer = '';
          // _buffer = '';
          return KeyEventResult.handled;
        }
      }

      deleteBuffer = '';
      resetBuffer();

      return KeyEventResult.handled;
    }

    resetSequenceBuffer();
    resetBuffer();
    deleteBuffer = '';
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
