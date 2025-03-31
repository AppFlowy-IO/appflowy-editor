import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/extensions/vim_shortcut_extensions.dart';
// import 'package:appflowy_editor/src/editor_state.dart';

void moveCursor(
  EditorState editorState,
  SelectionMoveDirection direction, [
  SelectionMoveRange range = SelectionMoveRange.character,
]) {
  final selection = editorState.selection?.normalized;
  if (selection == null) {
    return;
  }

  // If the selection is not collapsed, then we want to collapse the selection
  if (!selection.isCollapsed && range != SelectionMoveRange.line) {
    // move the cursor to the start or end of the selection
    editorState.selection = selection.collapse(
      atStart: direction == SelectionMoveDirection.forward,
    );
    return;
  }

  final node = editorState.getNodeAtPath(selection.start.path);
  if (node == null) {
    return;
  }

  // Originally, I want to make this function as pure as possible,
  //  but I have to import the selectable here to compute the selection.
  final start = node.selectable?.start();
  final end = node.selectable?.end();
  final offset = direction == SelectionMoveDirection.forward
      ? selection.startIndex
      : selection.endIndex;
  {
    // the cursor is at the start of the node
    // move the cursor to the end of the previous node
    if (direction == SelectionMoveDirection.forward &&
        start != null &&
        start.offset >= offset) {
      final previousEnd = node
          .previousNodeWhere((element) => element.selectable != null)
          ?.selectable
          ?.end();
      if (previousEnd != null) {
        editorState.updateSelectionWithReason(
          Selection.collapsed(previousEnd),
          reason: SelectionUpdateReason.uiEvent,
        );
      }
      return;
    }
    // the cursor is at the end of the node
    // move the cursor to the start of the next node
    else if (direction == SelectionMoveDirection.backward &&
        end != null &&
        end.offset <= offset) {
      //Would have to handle if text has reached document end
      if (end.offset == offset) {
        editorState.insertText(end.offset, ' ', node: node);
        final pos = Position(path: node.path, offset: end.offset + 1);
        if (node.selectable?.end() != null) {
          editorState.updateSelectionWithReason(
            Selection.collapsed(pos),
            reason: SelectionUpdateReason.uiEvent,
          );
        }
      }

      return;
    }
  }

  final delta = node.delta;
  switch (range) {
    case SelectionMoveRange.character:
      if (delta != null) {
        // move the cursor to the left or right by one character
        editorState.updateSelectionWithReason(
          Selection.collapsed(
            selection.start.copyWith(
              offset: direction == SelectionMoveDirection.forward
                  ? delta.prevRunePosition(offset)
                  : delta.nextRunePosition(offset),
            ),
          ),
          reason: SelectionUpdateReason.uiEvent,
        );
      } else {
        throw UnimplementedError();
      }
      break;
    default:
      throw UnimplementedError();
  }
}

const baseKeys = ['h', 'j', 'k', 'l', 'i', 'a', 'o', 'w'];
// String buffer = '';

class VimCursor {
  static Position? processMotionKeys(
      String key, EditorState editorState, Selection selection, int count) {
    //final int docLength = editorState.document.root.children.length;
    switch (key) {
      case 'j':
        {
          //print('Here is the doc length!, $docLength');
          int tmpPos = count + selection.end.path.first;
          //print('counter: $count');

          Selection bottomLevel = Selection(
            start: Position(
              path: editorState.document.root.children.last.path,
              offset: 0,
            ),
            end: Position(
              path: editorState.document.root.children.last.path,
              offset: 0,
            ),
          );

          if (editorState.selection == bottomLevel) {
            return Position(
              path: editorState.document.root.children.last.path,
              offset: 0,
            );
          }
          if (count > editorState.document.root.children.length) {
            //print('Found a value out of range!, $count');
            /*print(
                'Here is the doc length!, ${editorState.document.root.children.length}');
                */
            return Position(
              path: editorState.document.root.children.last.path,
              offset: 0,
            );
          }
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
          Selection topLevel = Selection(
            start: Position(path: [0], offset: 0),
            end: Position(
              path: [0],
              offset: 0,
            ),
          );

          if (editorState.selection == topLevel) {
            return Position(path: [0], offset: 0);
          }

          if (count > editorState.document.root.children.length) {
            return Position(path: [0], offset: 0);
          }
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

      case 'a':
        {
          editorState.editable = true;
          editorState.mode = VimModes.insertMode;
          editorState.selection = editorState.selection;

          moveCursor(editorState, SelectionMoveDirection.backward);

          editorState.selectionService.updateSelection(editorState.selection);
          editorState.prevSelection = null;
          return Position(
            path: editorState.selection!.end.path,
            offset: editorState.selection!.end.offset,
          );
        }

      case 'o':
        {
          editorState.editable = true;
          editorState.mode = VimModes.insertMode;
          editorState.selection = editorState.selection;

//insertNewLine selects the old text and carries it over to the new line?
//NOTE: Manually build node and perform transaction
          final transaction = editorState.transaction;
          final nextPosition = Position(
            path: [editorState.selection!.end.path.first + 1],
            offset: 0,
          );
          final Node blankLine = paragraphNode(text: '');
          transaction.insertNode(nextPosition.path, blankLine);
          transaction.afterSelection = Selection.collapsed(nextPosition);
          transaction.customSelectionType = SelectionType.inline;
          editorState.apply(transaction).then((value) => {});

          editorState.selection = editorState.selection;
          editorState.selectionService.updateSelection(editorState.selection);
          editorState.prevSelection = null;
          //manually insert whitespace if next node is not present?

          return Position(
            path: editorState.selection!.end.path,
            offset: editorState.selection!.end.offset,
          );
        }
      case 'w':
        {
          editorState.selection = editorState.selection;

          editorState.moveCursor(
              SelectionMoveDirection.backward, SelectionMoveRange.word);

          editorState.selection = editorState.selection;
          editorState.selectionService.updateSelection(editorState.selection);
          //manually insert whitespace if next node is not present?

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
