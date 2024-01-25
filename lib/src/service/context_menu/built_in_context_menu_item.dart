import 'package:appflowy_editor/src/editor/l10n/appflowy_editor_l10n.dart';

import '../internal_key_event_handlers/copy_paste_handler.dart';
import 'context_menu.dart';

final standardContextMenuItems = [
  [
    // cut
    ContextMenuItem(
      getName: () => AppFlowyEditorL10n.current.cut,
      onPressed: (editorState) {
        handleCut(editorState);
      },
    ),
    // copy
    ContextMenuItem(
      getName: () => AppFlowyEditorL10n.current.copy,
      onPressed: (editorState) {
        handleCopy(editorState);
      },
    ),
    // Paste
    ContextMenuItem(
      getName: () => AppFlowyEditorL10n.current.paste,
      onPressed: (editorState) {
        handlePaste(editorState);
      },
    ),
  ],
];
