import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/util/platform_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> onNonTextUpdate(
  TextEditingDeltaNonTextUpdate nonTextUpdate,
  EditorState editorState,
  List<CharacterShortcutEvent> characterShortcutEvents,
) async {
  AppFlowyEditorLog.input.debug('onNonTextUpdate: $nonTextUpdate');

  // update the selection on Windows
  //
  // when typing characters with CJK IME on Windows, a non-text update is sent
  // with the selection range.
  final selection = editorState.selection;

  if (await _checkIfBacktickPressed(editorState, nonTextUpdate)) {
    return;
  }

  if (PlatformExtension.isWindows) {
    if (selection != null &&
        nonTextUpdate.composing == TextRange.empty &&
        nonTextUpdate.selection.isCollapsed) {
      editorState.selection = Selection.collapsed(
        Position(
          path: selection.start.path,
          offset: nonTextUpdate.selection.start,
        ),
      );
    }
  } else if (PlatformExtension.isLinux) {
    if (selection != null) {
      editorState.updateSelectionWithReason(
        Selection.collapsed(
          Position(
            path: selection.start.path,
            offset: nonTextUpdate.selection.start,
          ),
        ),
      );
    }
  } else if (PlatformExtension.isMacOS) {
    if (selection != null) {
      editorState.updateSelectionWithReason(
        Selection.collapsed(
          Position(
            path: selection.start.path,
            offset: nonTextUpdate.selection.start,
          ),
        ),
      );
    }
  } else if (PlatformExtension.isAndroid) {
    // on some Android keyboards (e.g. Gboard), they use non-text update to update the selection when moving cursor
    // by space bar.
    // for the another keyboards (e.g. system keyboard), they will trigger the
    // `onFloatingCursor` event instead.
    AppFlowyEditorLog.input.debug('[Android] onNonTextUpdate: $nonTextUpdate');
    if (selection != null && selection != editorState.selection) {
      editorState.updateSelectionWithReason(
        Selection.collapsed(
          Position(
            path: selection.start.path,
            offset: nonTextUpdate.selection.start,
          ),
        ),
        reason: SelectionUpdateReason.uiEvent,
      );
    }
  } else if (PlatformExtension.isIOS) {
    // on iOS, the cursor movement will trigger the `onFloatingCursor` event.
    // so we don't need to handle the non-text update here.
    AppFlowyEditorLog.input.debug('[iOS] onNonTextUpdate: $nonTextUpdate');
  }
}

Future<bool> _checkIfBacktickPressed(
  EditorState editorState,
  TextEditingDeltaNonTextUpdate nonTextUpdate,
) async {
  // if the composing range is not empty, it means the user is typing a text,
  // so we don't need to handle the backtick pressed event
  if (!nonTextUpdate.composing.isCollapsed) {
    return false;
  }

  // if the selection is not collapsed, it means the user is not typing a text,
  // so we need to handle the backtick pressed event
  if (!nonTextUpdate.selection.isCollapsed) {
    return false;
  }

  final selection = editorState.selection;
  if (selection == null || !selection.isCollapsed) {
    AppFlowyEditorLog.input.debug('selection is null or not collapsed');
    return false;
  }

  final node = editorState.getNodesInSelection(selection).firstOrNull;
  if (node == null) {
    AppFlowyEditorLog.input.debug('node is null');
    return false;
  }

  // get last character of the node
  final lastCharacter = node.delta?.toPlainText().characters.lastOrNull;
  if (lastCharacter != '`') {
    AppFlowyEditorLog.input.debug('last character is not backtick');
    return false;
  }

  // check if the text should be formatted
  final (shouldApplyFormat, _) = checkSingleCharacterFormatShouldBeApplied(
    editorState: editorState,
    // check before the last character
    selection: selection.shift(-1),
    character: '`',
    formatStyle: FormatStyleByWrappingWithSingleChar.code,
  );

  if (!shouldApplyFormat) {
    AppFlowyEditorLog.input.debug('should not apply format');
    return false;
  }

  final transaction = editorState.transaction;
  transaction.deleteText(node, node.delta!.toPlainText().length - 1, 1);
  await editorState.apply(transaction);

  // remove the last backtick, and try to format the text to code block
  final isFormatted = handleFormatByWrappingWithSingleCharacter(
    editorState: editorState,
    character: '`',
    formatStyle: FormatStyleByWrappingWithSingleChar.code,
  );

  if (!isFormatted) {
    AppFlowyEditorLog.input.debug('format failed');
    // revert the transaction
    editorState.undoManager.undo();
  } else {
    editorState.sliceUpcomingAttributes = false;
  }

  return true;
}
