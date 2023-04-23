import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/util/util.dart';

/// Show the slash menu
///
/// - support
///   - desktop
///   - web
///
CharacterShortcutEvent slashCommand = CharacterShortcutEvent(
  key: 'show the slash menu',
  character: '/',
  handler: _showSlashMenu,
);

SelectionMenuService? _selectionMenuService;
CharacterShortcutEventHandler _showSlashMenu = (editorState) async {
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
  await editorState.insertTextAtPosition('/', position: selection.start);

  // show the slash menu
  {
    // this code is copied from the the old editor.
    // TODO: refactor this code
    final context = editorState.getNodeAtPath(selection.start.path)?.context;
    if (context != null) {
      _selectionMenuService = SelectionMenu(
        context: context,
        editorState: editorState,
      );
      _selectionMenuService?.show();
    }
  }

  return true;
};
