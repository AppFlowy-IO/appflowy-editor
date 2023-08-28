import 'package:appflowy_editor/src/service/context_menu/context_menu.dart';

import '../internal_key_event_handlers/copy_paste_handler.dart';

final standardContextMenuItems = [
  [
    // cut
    ContextMenuItem(
      name: 'Cut',
      onPressed: (editorState) {
        handleCut(editorState);
      },
    ),
    // copy
    ContextMenuItem(
      name: 'Copy',
      onPressed: (editorState) {
        handleCopy(editorState);
      },
    ),
    // Paste
    ContextMenuItem(
      name: 'Paste',
      onPressed: (editorState) {
        handlePaste(editorState);
      },
    ),
  ],
];
