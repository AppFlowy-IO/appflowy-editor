import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/shortcuts/command_shortcut_event.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/shortcuts/vim/vim_fsm.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class VimCommandShortcutEvent extends CommandShortcutEvent {
  final VimFSM vimFSM = VimFSM();
  VimCommandShortcutEvent()
      : super(
          key: 'Vim FSM Handler',
          command: '',
          handler: _dummyHandler,
          getDescription: () => 'Handles multi-key vim commands using an FSM',
        );
  KeyEventResult handleKey(KeyEvent event, EditorState editorState) {
    return vimFSM.processKey(event, editorState);
  }

  static KeyEventResult _dummyHandler(EditorState editorState) {
    return KeyEventResult.ignored;
  }
}

