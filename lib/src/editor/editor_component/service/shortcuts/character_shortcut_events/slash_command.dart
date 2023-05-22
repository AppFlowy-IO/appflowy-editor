import 'package:appflowy_editor/appflowy_editor.dart';

/// Show the slash menu
///
/// - support
///   - desktop
///   - web
///
final CharacterShortcutEvent slashCommand = CharacterShortcutEvent(
  key: 'show the slash menu',
  character: '/',
  handler: (editorState) async => await _showSlashMenu(
    editorState,
    standardSelectionMenuItems,
  ),
);

CharacterShortcutEvent customSlashCommand(
  List<SelectionMenuItem> items, {
  shouldInsertSlash = true,
}) {
  return CharacterShortcutEvent(
    key: 'show the slash menu',
    character: '/',
    handler: (editorState) => _showSlashMenu(
      editorState,
      [
        ...standardSelectionMenuItems,
        ...items,
      ],
      shouldInsertSlash: shouldInsertSlash,
    ),
  );
}

SelectionMenuService? _selectionMenuService;
Future<bool> _showSlashMenu(
  EditorState editorState,
  List<SelectionMenuItem> items, {
  shouldInsertSlash = true,
}) async {
  if (PlatformExtension.isMobile) {
    return false;
  }

  final selection = editorState.selection;
  if (selection == null) {
    return false;
  }

  // delete the selection
  await editorState.deleteSelection(editorState.selection!);

  final afterSelection = editorState.selection;
  if (afterSelection == null || !afterSelection.isCollapsed) {
    assert(false, 'the selection should be collapsed');
    return true;
  }

  // insert the slash character
  if (shouldInsertSlash) {
    await editorState.insertTextAtPosition('/', position: selection.start);
  }

  // show the slash menu
  () {
    // this code is copied from the the old editor.
    // TODO: refactor this code
    final context = editorState.getNodeAtPath(selection.start.path)?.context;
    if (context != null) {
      _selectionMenuService = SelectionMenu(
        context: context,
        editorState: editorState,
        selectionMenuItems: items,
        deleteSlashByDefault: shouldInsertSlash,
      );
      _selectionMenuService?.show();
    }
  }();

  return true;
}
