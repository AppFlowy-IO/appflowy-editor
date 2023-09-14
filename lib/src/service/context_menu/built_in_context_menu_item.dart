import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/service/context_menu/context_menu.dart';

import '../internal_key_event_handlers/copy_paste_handler.dart';

final standardContextMenuItems = [
  [
    // cut
    ContextMenuItem(
      name: AppFlowyEditorLocalizations.current.cut,
      onPressed: (editorState) {
        handleCut(editorState);
      },
    ),
    // copy
    ContextMenuItem(
      name: AppFlowyEditorLocalizations.current.copy,
      onPressed: (editorState) {
        handleCopy(editorState);
      },
    ),
    // Paste
    ContextMenuItem(
      name: AppFlowyEditorLocalizations.current.paste,
      onPressed: (editorState) {
        handlePaste(editorState);
      },
    ),
  ],
];
