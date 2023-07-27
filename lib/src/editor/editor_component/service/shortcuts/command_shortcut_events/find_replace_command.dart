import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/find_replace_menu/find_menu_service.dart';
import 'package:flutter/material.dart';

List<CommandShortcutEvent> findAndReplaceCommands({
  required FindReplaceLocalizations localizations,
  FindReplaceStyle? style,
}) =>
    [
      openFindDialog(
        localizations: localizations,
        style: style ?? FindReplaceStyle(),
      ),
      openReplaceDialog(
        localizations: localizations,
        style: style ?? FindReplaceStyle(),
      ),
    ];

class FindReplaceStyle {
  FindReplaceStyle({
    this.highlightColor = const Color(0x6000BCF0),
  });

  final Color highlightColor;
}

class FindReplaceLocalizations {
  FindReplaceLocalizations({
    required this.find,
    required this.previousMatch,
    required this.nextMatch,
    required this.close,
    required this.replace,
    required this.replaceAll,
  });

  final String find;
  final String previousMatch;
  final String nextMatch;
  final String close;
  final String replace;
  final String replaceAll;
}

/// Show the slash menu
///
/// - support
///   - desktop
///   - web
///
CommandShortcutEvent openFindDialog({
  required FindReplaceLocalizations localizations,
  required FindReplaceStyle style,
}) =>
    CommandShortcutEvent(
      key: 'show the find dialog',
      command: 'ctrl+f',
      macOSCommand: 'cmd+f',
      handler: (editorState) => _showFindAndReplaceDialog(
        editorState,
        localizations: localizations,
        style: style,
      ),
    );

CommandShortcutEvent openReplaceDialog({
  required FindReplaceLocalizations localizations,
  required FindReplaceStyle style,
}) =>
    CommandShortcutEvent(
      key: 'show the find and replace dialog',
      command: 'ctrl+h',
      macOSCommand: 'cmd+h',
      handler: (editorState) => _showFindAndReplaceDialog(
        editorState,
        localizations: localizations,
        style: style,
        openReplace: true,
      ),
    );

FindReplaceService? _findReplaceService;
KeyEventResult _showFindAndReplaceDialog(
  EditorState editorState, {
  required FindReplaceLocalizations localizations,
  required FindReplaceStyle style,
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
        localizations: localizations,
        style: style,
      );

      _findReplaceService?.show();
    }
  }();

  return KeyEventResult.handled;
}
