import 'dart:async';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/extensions/vim_shortcut_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:appflowy_editor/src/editor/command/selection_commands.dart';

const baseKeys = ['h', 'j', 'k', 'l'];

String _buffer = '';
String _deleteBuffer = '';

// void moveCursorHorizontal(
//     EditorState editorState, SelectionMoveDirection direction,
//     [SelectionMoveRange range = SelectionMoveRange.character]) {
//   final selection = editorState.selection?.normalized;
//   if (selection == null) {
//     return;
//   }
//   if (!selection.isCollapsed && range != SelectionMoveRange.line) {
//     editorState.selection = selection.collapse(
//         atStart: direction == SelectionMoveDirection.forward);
//     return;
//   }

//   final node = getNodeAtPath(selection.start.path);
//   if (node == null) {
//     return;
//   }

//   final start = node.selectable?.start();
//   final end = node.selectable?.end();
//   final offset = direction == SelectionMoveDirection.forward
//       ? selection.startIndex
//       : selection.endIndex;

//   {
//     // the cursor is at the start of the node
//     // move the cursor to the end of the previous node
//     if (direction == SelectionMoveDirection.forward &&
//         start != null &&
//         start.offset >= offset) {
//       final previousEnd = node
//           .previousNodeWhere((element) => element.selectable != null)
//           ?.selectable
//           ?.end();
//       if (previousEnd != null) {
//         updateSelectionWithReason(
//           Selection.collapsed(previousEnd),
//           reason: SelectionUpdateReason.uiEvent,
//         );
//       }
//       return;
//     }
//     // the cursor is at the end of the node
//     // move the cursor to the start of the next node
//     else if (direction == SelectionMoveDirection.backward &&
//         end != null &&
//         end.offset <= offset) {
//       final nextStart = node.next?.selectable?.start();
//       if (nextStart != null) {
//         updateSelectionWithReason(
//           Selection.collapsed(nextStart),
//           reason: SelectionUpdateReason.uiEvent,
//         );
//       }
//       return;
//     }
//   }
//   final delta = node.delta;
//  switch(range){
//    case SelectionMoveRange.line:
//   if (delta != null){
//     updateSelectionWithReason(
//       Selection.collapsed(selection.start.copyWith(offset: direction == SelectionMoveDirection.forward ? 0 : delta.length))
//       reason: SelectionUpdateReason.uiEvent
//     )
//   }
//   else {
//     throw UnimplementedError();
//   }
//   break;
//   default:
//   throw UnimplementedError();
//  }
// }

/*
BUG: State gets sticky when at the end of the line & yet
and want to move to the start
Will have to build a custom one from moveCursorBackward
BUG: After selecting end then moving to start it freezes
then jumps backward a few characters after pressing another key
NOTE: Refer to the 'selection_commands.dart'
*/
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
    if (isRTL(editorState)) {
      editorState.moveCursorBackward(SelectionMoveRange.line);
    } else {
      editorState.moveCursorForward(SelectionMoveRange.line);
    }
    return KeyEventResult.handled;
  }
  return KeyEventResult.ignored;
};

/*
BUG: Has buggy behavior after selecting it
*/
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

  final tmpPosition = Position(path: selection.start.path, offset: 0);
  final delta = node.delta;
  if (delta != null) {
    final deletionSelection = Selection(
        start: Position(path: selection.start.path, offset: 0),
        end: Position(path: selection.end.path, offset: delta.length));
    print('after modifying selection');
    print(deletionSelection);
    editorState.selection = deletionSelection;
    final transaction = editorState.transaction;
    //transaction.deleteText(node, 0, node.delta!.length);
    print('new editorSTate selection');
    print(editorState.selection);
    transaction.deleteNodesAtPath(editorState.selection!.start.path);
    // transaction.deleteNode(node);

    editorState
        .apply(transaction)
        .then((value) => {editorState.selectionType = null});
    editorState.updateSelectionWithReason(
        Selection(start: tmpPosition, end: tmpPosition),
        reason: SelectionUpdateReason.uiEvent);
    print('editor transactions!');
    print(transaction.operations);
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

    if (event.character == '\$') {
      vimMoveCursorToEndHandler(editorState);
    }

    final key = event.logicalKey.keyLabel.toLowerCase();

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
    } else {
      _buffer = '';

      keyBuffer += key;
      if (RegExp(r'^\d$').hasMatch(key)) {
        if (_buffer.isEmpty && key == '0') {
          vimMoveCursorToStartHandler(editorState);
        } else {
          _buffer += key;
        }
        return KeyEventResult.handled;
      }
      print('key buffer: $keyBuffer');

      if (keyBuffer == 'dd') {
        // _deleteBuffer += key;
        final RegExp ddRegExp = RegExp(r'^(\d*)dd$');
        final match = ddRegExp.firstMatch(_deleteBuffer);
        // if (match != null) {
        //   final String? countStr = match.group(1);
        // final int count =
        //     (countStr != null && countStr.isNotEmpty) ? int.parse(countStr) : 1;
        final tmpPosition = deleteCurrentLine(editorState, 1);
        _deleteBuffer = '';
        editorState.selection = Selection(
          end: tmpPosition,
          start: tmpPosition,
        );
        resetKeyBuffer();
        return KeyEventResult.handled;
        // }
      }
      return KeyEventResult.handled;
    }

    if (keyBuffer != 'dd') {
      resetKeyBuffer();
      return KeyEventResult.ignored;
    }

    _buffer = '';

    return KeyEventResult.ignored;
  }

  void reset() {
    _buffer = '';
  }

  void resetKeyBuffer() {
    keyBuffer = "";
    resetTimer?.cancel();
  }
}
