import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/find_replace_menu/find_menu_service.dart';
import 'package:flutter/material.dart';

final List<CommandShortcutEvent> findAndReplaceCommands = [
  openFindDialog,
  openReplaceDialog,
];

/// Show the slash menu
///
/// - support
///   - desktop
///   - web
///
final CommandShortcutEvent openFindDialog = CommandShortcutEvent(
  key: 'show the find dialog',
  command: 'ctrl+f',
  macOSCommand: 'cmd+f',
  handler: (editorState) => _showFindAndReplaceDialog(
    editorState,
  ),
);

final CommandShortcutEvent openReplaceDialog = CommandShortcutEvent(
  key: 'show the find and replace dialog',
  command: 'ctrl+h',
  macOSCommand: 'cmd+h',
  handler: (editorState) => _showFindAndReplaceDialog(
    editorState,
    openReplace: true,
  ),
);

FindReplaceService? _findReplaceService;
KeyEventResult _showFindAndReplaceDialog(
  EditorState editorState, {
  bool openReplace = false,
}) {
  if (PlatformExtension.isMobile) {
    return KeyEventResult.ignored;
  }

  final selection = editorState.selection;
  if (selection == null) {
    return KeyEventResult.ignored;
  }

  // // delete the selection
  // if (!selection.isCollapsed) {
  //   await editorState.deleteSelection(selection);
  // }

  final afterSelection = editorState.selection;
  if (afterSelection == null || !afterSelection.isCollapsed) {
    assert(false, 'the selection should be collapsed');
    return KeyEventResult.handled;
  }

  // show the slash menu
  () {
    // this code is copied from the the old editor.
    // TODO: refactor this code
    final context = editorState.getNodeAtPath(selection.start.path)?.context;
    if (context != null) {
      _findReplaceService = FindReplaceMenu(
        context: context,
        editorState: editorState,
        replaceFlag: openReplace,
      );
      _findReplaceService?.show();
    }
  }();

  return KeyEventResult.handled;
}
