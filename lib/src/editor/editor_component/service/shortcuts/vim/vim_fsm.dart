import 'dart:async';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/extensions/vim_shortcut_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:appflowy_editor/src/editor/command/selection_commands.dart';
import './vim_cursor.dart';

const baseKeys = ['h', 'j', 'k', 'l', 'i', 'a', 'o', 'w'];

void vimMoveCursorToStartHandler(EditorState editorState) {
  if (!editorState.vimMode) {}
  if (editorState.mode == VimModes.normalMode) {
    final selection = editorState.selection;
    if (selection == null) {}
    if (isRTL(editorState)) {
      editorState.moveCursorBackward(SelectionMoveRange.line);
    } else {
      editorState.moveCursorForward(SelectionMoveRange.line);
    }
  }
}

void vimMoveCursorToEndHandler(EditorState editorState) {
  if (!editorState.vimMode) {}
  if (editorState.mode == VimModes.normalMode) {
    final selection = editorState.selection;
    if (selection == null) {}
    if (isRTL(editorState)) {
      editorState.moveCursorForward(SelectionMoveRange.line);
    } else {
      editorState.moveCursorBackward(SelectionMoveRange.line);
    }
  }
}

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
      transaction.deleteNodesAtPath(editorState.selection!.start.path);

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

class VimState {
  String commandBuffer = '';
  String deleteBuffer = '';
  Timer? resetTimer;
  void reset() {
    commandBuffer = '';
    deleteBuffer = '';
    resetTimer?.cancel();
  }

  void scheduleReset() {
    resetTimer?.cancel();
    resetTimer = Timer(const Duration(milliseconds: 500), reset);
  }
}

class VimFSM {
  static final VimFSM _instance = VimFSM._internal();
  factory VimFSM() => _instance;
  VimFSM._internal();
  final _state = VimState();

  KeyEventResult processKey(KeyEvent event, EditorState editorState) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    _state.scheduleReset();

    final key = event.logicalKey.keyLabel.toLowerCase();
    if (baseKeys.contains(key)) {
      final count = _parseCount(_state.commandBuffer);
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
    }
    String keySequence = _buildKeySequence(event);
    _state.commandBuffer += keySequence;
    if (_handleSpecialCommands(editorState)) {
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  int _parseCount(String buffer) {
    final match = RegExp(r'^(\d+)').firstMatch(buffer);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '') ?? 1;
    }
    return 1;
  }

  String _buildKeySequence(KeyEvent event) {
    final key = event.logicalKey.keyLabel.toLowerCase();
    if (key.startsWith('shift')) {
      return key;
    }
    return key;
  }

//TODO: Handle other keys from vim.dart
  bool _handleSpecialCommands(EditorState editorState) {
    final buffer = _state.commandBuffer;
    if (buffer == 'shift left4' || buffer == 'shift right4') {
      vimMoveCursorToEndHandler(editorState);
      _state.reset();
      return true;
    }

    if (buffer == '0') {
      vimMoveCursorToStartHandler(editorState);
      _state.reset();
      return true;
    }
    if (buffer.endsWith('dd')) {
      final count = _parseCount(buffer.substring(0, buffer.length - 2));
      final position = deleteCurrentLine(editorState, count);
      editorState.selection = Selection(start: position, end: position);
      _state.reset();
      return true;
    }
    return false;
  }
}
