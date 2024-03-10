import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
  bool shouldInsertSlash = true,
  SelectionMenuStyle style = SelectionMenuStyle.light,
}) {
  return CharacterShortcutEvent(
    key: 'show the slash menu',
    character: '/',
    handler: (editorState) => _showSlashMenu(
      editorState,
      items,
      shouldInsertSlash: shouldInsertSlash,
      style: style,
    ),
  );
}

final Set<String> supportSlashMenuNodeWhiteList = {
  ParagraphBlockKeys.type,
  HeadingBlockKeys.type,
  TodoListBlockKeys.type,
  BulletedListBlockKeys.type,
  NumberedListBlockKeys.type,
  QuoteBlockKeys.type,
};

SelectionMenuService? _selectionMenuService;
Future<bool> _showSlashMenu(
  EditorState editorState,
  List<SelectionMenuItem> items, {
  bool shouldInsertSlash = true,
  SelectionMenuStyle style = SelectionMenuStyle.light,
}) async {
  if (PlatformExtension.isMobile) {
    return false;
  }

  final selection = editorState.selection;
  if (selection == null) {
    return false;
  }

  // delete the selection
  if (!selection.isCollapsed) {
    await editorState.deleteSelection(selection);
  }

  final afterSelection = editorState.selection;
  if (afterSelection == null || !afterSelection.isCollapsed) {
    assert(false, 'the selection should be collapsed');
    return true;
  }

  final node = editorState.getNodeAtPath(selection.start.path);

  // only enable in white-list nodes
  if (node == null || !_isSupportSlashMenuNode(node)) {
    return false;
  }

  // insert the slash character
  if (shouldInsertSlash) {
    if (kIsWeb) {
      // Have no idea why the focus will lose after inserting on web.
      keepEditorFocusNotifier.increase();
      await editorState.insertTextAtPosition('/', position: selection.start);
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) => keepEditorFocusNotifier.decrease(),
      );
    } else {
      await editorState.insertTextAtPosition('/', position: selection.start);
    }
  }

  // show the slash menu
  () {
    // this code is copied from the the old editor.
    final context = editorState.getNodeAtPath(selection.start.path)?.context;
    if (context != null) {
      _selectionMenuService = SelectionMenu(
        context: context,
        editorState: editorState,
        selectionMenuItems: items,
        deleteSlashByDefault: shouldInsertSlash,
        style: style,
      );
      _selectionMenuService?.show();
    }
  }();

  return true;
}

bool _isSupportSlashMenuNode(Node node) {
  var result = supportSlashMenuNodeWhiteList.contains(node.type);
  if (node.level > 1 && node.parent != null) {
    return result && _isSupportSlashMenuNode(node.parent!);
  }
  return result;
}
