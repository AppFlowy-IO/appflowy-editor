import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/find_replace_menu/find_menu_service.dart';
import 'package:flutter/material.dart';

List<CommandShortcutEvent> findAndReplaceCommands({
  FindReplaceLocalizations? localizations,
  required BuildContext context,
  FindReplaceStyle? style,
}) =>
    [
      openFindDialog(
        localizations: localizations,
        context: context,
        style: style ?? FindReplaceStyle(),
      ),
      openReplaceDialog(
        localizations: localizations,
        context: context,
        style: style ?? FindReplaceStyle(),
      ),
    ];

class FindReplaceStyle {
  FindReplaceStyle({
    this.selectedHighlightColor = const Color(0xFFFFB931),
    this.unselectedHighlightColor = const Color(0x60ECBC5F),
  });

  //selected highlight color is used as background color on the selected found pattern.
  final Color selectedHighlightColor;
  //unselected highlight color is used on every other found pattern which can be selected.
  final Color unselectedHighlightColor;
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
  FindReplaceLocalizations? localizations,
  required BuildContext context,
  required FindReplaceStyle style,
}) =>
    CommandShortcutEvent(
      key: 'show the find dialog',
      command: 'ctrl+f',
      macOSCommand: 'cmd+f',
      handler: (editorState) => _showFindAndReplaceDialog(
        context,
        editorState,
        localizations: localizations,
        style: style,
      ),
    );

CommandShortcutEvent openReplaceDialog({
  FindReplaceLocalizations? localizations,
  required BuildContext context,
  required FindReplaceStyle style,
}) =>
    CommandShortcutEvent(
      key: 'show the find and replace dialog',
      command: 'ctrl+h',
      macOSCommand: 'cmd+h',
      handler: (editorState) => _showFindAndReplaceDialog(
        context,
        editorState,
        localizations: localizations,
        style: style,
        openReplace: true,
      ),
    );

FindReplaceService? _findReplaceService;
KeyEventResult _showFindAndReplaceDialog(
  BuildContext context,
  EditorState editorState, {
  FindReplaceLocalizations? localizations,
  required FindReplaceStyle style,
  bool openReplace = false,
}) {
  if (PlatformExtension.isMobile) {
    return KeyEventResult.ignored;
  }

  _findReplaceService = FindReplaceMenu(
    context: context,
    editorState: editorState,
    replaceFlag: openReplace,
    localizations: localizations,
    style: style,
  );

  _findReplaceService?.show();

  return KeyEventResult.handled;
}
