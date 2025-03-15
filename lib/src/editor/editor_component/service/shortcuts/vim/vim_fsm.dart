import 'package:appflowy_editor/src/extensions/vim_shortcut_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:appflowy_editor/appflowy_editor.dart';

const baseKeys = ['h', 'j', 'k', 'l'];

String _buffer = '';
String _deleteBuffer = '';

CommandShortcutEventHandler vimMoveCursorToStartHandler = (editorState) {
  if (!editorState.vimMode) {
    return KeyEventResult.ignored;
  }
  // final afKeyboard = editorState.service.keyboardServiceKey;
  if (editorState.mode == VimModes.normalMode) {
    final selection = editorState.selection;
    if (selection == null) {
      return KeyEventResult.ignored;
    }
    final nodes = editorState.getNodesInSelection(selection);
    if (nodes.isEmpty) {
      return KeyEventResult.ignored;
    }
    var end = selection.end;
    final position = isRTL(editorState)
        ? nodes.last.selectable?.end()
        : nodes.last.selectable?.start();
    if (position != null) {
      end = position;
    }

    editorState.selection =
        Selection.collapsed(Position(path: end.path, offset: 0));
    return KeyEventResult.handled;
  }
  return KeyEventResult.ignored;
};

Position deleteCurrentLine(EditorState editorState, int count) {
  final selection = editorState.selection;
  if (selection == null) return Position(path: [0], offset: 0);
  final node = editorState.getNodeAtPath(selection.end.path);
  if (node == null || node.delta == null) return Position(path: [0], offset: 0);
  final transaction = editorState.transaction;
  final tmpPosition = Position(path: selection.start.path, offset: 0);
  //transaction.deleteText(node, 0, node.delta!.length);
  transaction.deleteNodesAtPath(selection.start.path);
  editorState.apply(transaction).then(
        (value) => {editorState.selectionType = null},
      );
  return tmpPosition;
}

class VimFSM {
  KeyEventResult processKey(KeyEvent event, EditorState editorState) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey.keyLabel.toLowerCase();

    if (RegExp(r'^\d$').hasMatch(key)) {
      if (_buffer.isEmpty && key == '0') {
        vimMoveCursorToStartHandler(editorState);
      } else {
        _buffer += key;
      }
      return KeyEventResult.handled;
    }

    if (key == 'd') {
      _deleteBuffer += key;
      final RegExp ddRegExp = RegExp(r'^(\d*)dd$');
      final match = ddRegExp.firstMatch(_deleteBuffer);
      if (match != null) {
        final String? countStr = match.group(1);
        final int count =
            (countStr != null && countStr.isNotEmpty) ? int.parse(countStr) : 1;
        final tmpPosition = deleteCurrentLine(editorState, count);
        _deleteBuffer = '';
        editorState.selection = Selection(
          end: tmpPosition,
          start: tmpPosition,
        );
        return KeyEventResult.handled;
      }
    }

    Position? newPosition;
    if (baseKeys.contains(key)) {
      final count = _buffer.isNotEmpty ? int.parse(_buffer) : 1;
      _buffer = '';
      final selection = editorState.selection;
      if (selection == null) return KeyEventResult.ignored;
      //NOTE: Figure a way out to perform transactions
      //final transaction = editorState.transaction;

      /*
            transaction
                .deleteNodesAtPath(editorState.prevSelection!.start.path);
            editorState
                .apply(transaction)
                .then((value) => editorState.selectionType = null);
                */
      switch (key) {
        case 'j':
          {
            newPosition = moveVerticalMultiple(
              editorState,
              selection.end,
              upwards: false,
              count: count,
            );
            int tmpPos = count + selection.end.path.first;
            if (tmpPos < editorState.document.root.children.length) {
              newPosition =
                  //BUG: This causes editor to say null value on places where offset is empty
                  // Position(path: [tmpPos], offset: selection.end.offset ?? 0);
                  Position(path: [tmpPos], offset: 0);
            }
            //newPosition = Position(path: [count+selection.end.path.first]);
            break;
          }

        case 'k':
          {
            newPosition = moveVerticalMultiple(
              editorState,
              selection.end,
              upwards: true,
              count: count,
            );

            int tmpPos = selection.end.path.first - count;
            if (tmpPos < editorState.document.root.children.length) {
              newPosition =

                  //BUG: This causes editor to say null value on places where offset is empty
                  // Position(path: [tmpPos], offset: selection.end.offset ?? 0);
                  Position(path: [tmpPos], offset: 0);
            }
            break;
          }
        case 'h':
          {
            newPosition = moveHorizontalMultiple(
              editorState,
              selection.end,
              forward: true,
              count: count,
            );

            break;
          }
        case 'l':
          {
            newPosition = moveHorizontalMultiple(
              editorState,
              selection.end,
              forward: false,
              count: count,
            );
            break;
          }
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
