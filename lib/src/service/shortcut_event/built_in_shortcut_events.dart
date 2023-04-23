import 'package:appflowy_editor/src/service/internal_key_event_handlers/arrow_keys_handler.dart';
import 'package:appflowy_editor/src/service/internal_key_event_handlers/backspace_handler.dart';
import 'package:appflowy_editor/src/service/internal_key_event_handlers/copy_paste_handler.dart';
import 'package:appflowy_editor/src/service/internal_key_event_handlers/enter_without_shift_in_text_node_handler.dart';
import 'package:appflowy_editor/src/service/internal_key_event_handlers/exit_editing_mode_handler.dart';
import 'package:appflowy_editor/src/service/internal_key_event_handlers/markdown_syntax_to_styled_text.dart';
import 'package:appflowy_editor/src/service/internal_key_event_handlers/page_up_down_handler.dart';
import 'package:appflowy_editor/src/service/internal_key_event_handlers/redo_undo_handler.dart';
import 'package:appflowy_editor/src/service/internal_key_event_handlers/select_all_handler.dart';
import 'package:appflowy_editor/src/service/internal_key_event_handlers/slash_handler.dart';
import 'package:appflowy_editor/src/service/internal_key_event_handlers/format_style_handler.dart';
import 'package:appflowy_editor/src/service/internal_key_event_handlers/space_on_web_handler.dart';
import 'package:appflowy_editor/src/service/internal_key_event_handlers/tab_handler.dart';
import 'package:appflowy_editor/src/service/internal_key_event_handlers/whitespace_handler.dart';
import 'package:appflowy_editor/src/service/internal_key_event_handlers/checkbox_event_handler.dart';
import 'package:appflowy_editor/src/service/shortcut_event/shortcut_event.dart';
import 'package:flutter/foundation.dart';

List<ShortcutEvent> builtInShortcutEvents = [
  ShortcutEvent.fromCommand(
    key: 'Move cursor up',
    command: 'arrow up',
    handler: cursorUp,
  ),
  ShortcutEvent.fromCommand(
    key: 'Move cursor down',
    command: 'arrow down',
    handler: cursorDown,
  ),
  ShortcutEvent.fromCommand(
    key: 'Move cursor left',
    command: 'arrow left',
    handler: cursorLeft,
  ),
  ShortcutEvent.fromCommand(
    key: 'Move cursor right',
    command: 'arrow right',
    handler: cursorRight,
  ),
  ShortcutEvent.fromCommand(
    key: 'Cursor up select',
    command: 'shift+arrow up',
    handler: cursorUpSelect,
  ),
  ShortcutEvent.fromCommand(
    key: 'Cursor down select',
    command: 'shift+arrow down',
    handler: cursorDownSelect,
  ),
  ShortcutEvent.fromCommand(
    key: 'Cursor left word select',
    command: 'shift+alt+arrow left',
    windowsCommand: 'shift+alt+arrow left',
    linuxCommand: 'shift+alt+arrow left',
    handler: cursorLeftWordSelect,
  ),
  ShortcutEvent.fromCommand(
    key: 'Cursor right word select',
    command: 'shift+alt+arrow right',
    windowsCommand: 'shift+alt+arrow right',
    linuxCommand: 'shift+alt+arrow right',
    handler: cursorRightWordSelect,
  ),
  ShortcutEvent.fromCommand(
    key: 'Cursor word delete',
    command: 'alt+backspace',
    windowsCommand: 'ctrl+backspace',
    linuxCommand: 'ctrl+backspace',
    handler: cursorLeftWordDelete,
  ),
  ShortcutEvent.fromCommand(
    key: 'Cursor sentence delete',
    command: 'meta+backspace',
    windowsCommand: 'ctrl+alt+backspace',
    linuxCommand: 'ctrl+alt+backspace',
    handler: cursorLeftSentenceDelete,
  ),
  ShortcutEvent.fromCommand(
    key: 'Cursor left select',
    command: 'shift+arrow left',
    handler: cursorLeftSelect,
  ),
  ShortcutEvent.fromCommand(
    key: 'Cursor right select',
    command: 'shift+arrow right',
    handler: cursorRightSelect,
  ),
  ShortcutEvent.fromCommand(
    key: 'Move cursor top',
    command: 'meta+arrow up',
    windowsCommand: 'ctrl+arrow up',
    linuxCommand: 'ctrl+arrow up',
    handler: cursorTop,
  ),
  ShortcutEvent.fromCommand(
    key: 'Move cursor bottom',
    command: 'meta+arrow down',
    windowsCommand: 'ctrl+arrow down',
    linuxCommand: 'ctrl+arrow down',
    handler: cursorBottom,
  ),
  ShortcutEvent.fromCommand(
    key: 'Move cursor begin',
    command: 'meta+arrow left',
    windowsCommand: 'ctrl+arrow left',
    linuxCommand: 'ctrl+arrow left',
    handler: cursorBegin,
  ),
  ShortcutEvent.fromCommand(
    key: 'Move cursor end',
    command: 'meta+arrow right',
    windowsCommand: 'ctrl+arrow right',
    linuxCommand: 'ctrl+arrow right',
    handler: cursorEnd,
  ),
  ShortcutEvent.fromCommand(
    key: 'Cursor top select',
    command: 'meta+shift+arrow up',
    windowsCommand: 'ctrl+shift+arrow up',
    linuxCommand: 'ctrl+shift+arrow up',
    handler: cursorTopSelect,
  ),
  ShortcutEvent.fromCommand(
    key: 'Cursor bottom select',
    command: 'meta+shift+arrow down',
    windowsCommand: 'ctrl+shift+arrow down',
    linuxCommand: 'ctrl+shift+arrow down',
    handler: cursorBottomSelect,
  ),
  ShortcutEvent.fromCommand(
    key: 'Cursor begin select',
    command: 'meta+shift+arrow left,shift+home',
    windowsCommand: 'ctrl+shift+arrow left,shift+home',
    linuxCommand: 'ctrl+shift+arrow left,shift+home',
    handler: cursorBeginSelect,
  ),
  ShortcutEvent.fromCommand(
    key: 'Cursor end select',
    command: 'meta+shift+arrow right,shift+end',
    windowsCommand: 'ctrl+shift+arrow right,shift+end',
    linuxCommand: 'ctrl+shift+arrow right,shift+end',
    handler: cursorEndSelect,
  ),
  ShortcutEvent.fromCommand(
    key: 'Redo',
    command: 'meta+shift+z,meta+y',
    windowsCommand: 'ctrl+shift+z,ctrl+y',
    linuxCommand: 'ctrl+shift+z,ctrl+y',
    handler: redoEventHandler,
  ),
  ShortcutEvent.fromCommand(
    key: 'Undo',
    command: 'meta+z',
    windowsCommand: 'ctrl+z',
    linuxCommand: 'ctrl+z',
    handler: undoEventHandler,
  ),
  ShortcutEvent.fromCommand(
    key: 'Format bold',
    command: 'meta+b',
    windowsCommand: 'ctrl+b',
    linuxCommand: 'ctrl+b',
    handler: formatBoldEventHandler,
  ),
  ShortcutEvent.fromCommand(
    key: 'Format italic',
    command: 'meta+i',
    windowsCommand: 'ctrl+i',
    linuxCommand: 'ctrl+i',
    handler: formatItalicEventHandler,
  ),
  ShortcutEvent.fromCommand(
    key: 'Format underline',
    command: 'meta+u',
    windowsCommand: 'ctrl+u',
    linuxCommand: 'ctrl+u',
    handler: formatUnderlineEventHandler,
  ),
  ShortcutEvent.fromCommand(
    key: 'Toggle Checkbox',
    command: 'meta+enter',
    windowsCommand: 'ctrl+enter',
    linuxCommand: 'ctrl+enter',
    handler: toggleCheckbox,
  ),
  ShortcutEvent.fromCommand(
    key: 'Format strikethrough',
    command: 'meta+shift+s',
    windowsCommand: 'ctrl+shift+s',
    linuxCommand: 'ctrl+shift+s',
    handler: formatStrikethroughEventHandler,
  ),
  ShortcutEvent.fromCommand(
    key: 'Format highlight',
    command: 'meta+shift+h',
    windowsCommand: 'ctrl+shift+h',
    linuxCommand: 'ctrl+shift+h',
    handler: formatHighlightEventHandler,
  ),
  ShortcutEvent.fromCommand(
    key: 'Format embed code',
    command: 'meta+e',
    windowsCommand: 'ctrl+e',
    linuxCommand: 'ctrl+e',
    handler: formatEmbedCodeEventHandler,
  ),
  ShortcutEvent.fromCommand(
    key: 'Format link',
    command: 'meta+k',
    windowsCommand: 'ctrl+k',
    linuxCommand: 'ctrl+k',
    handler: formatLinkEventHandler,
  ),
  ShortcutEvent.fromCommand(
    key: 'Copy',
    command: 'meta+c',
    windowsCommand: 'ctrl+c',
    linuxCommand: 'ctrl+c',
    handler: copyEventHandler,
  ),
  ShortcutEvent.fromCommand(
    key: 'Paste',
    command: 'meta+v',
    windowsCommand: 'ctrl+v',
    linuxCommand: 'ctrl+v',
    handler: pasteEventHandler,
  ),
  ShortcutEvent.fromCommand(
    key: 'Cut',
    command: 'meta+x',
    windowsCommand: 'ctrl+x',
    linuxCommand: 'ctrl+x',
    handler: cutEventHandler,
  ),
  ShortcutEvent.fromCommand(
    key: 'Home',
    command: 'home',
    handler: cursorBegin,
  ),
  ShortcutEvent.fromCommand(
    key: 'End',
    command: 'end',
    handler: cursorEnd,
  ),
  ShortcutEvent.fromCommand(
    key: 'Delete Text by backspace',
    command: 'backspace',
    handler: backspaceEventHandler,
  ),
  ShortcutEvent.fromCommand(
    key: 'Delete Text',
    command: 'delete',
    handler: deleteEventHandler,
  ),
  ShortcutEvent.fromCharacter(
    key: 'selection menu',
    character: '/',
    handler: slashShortcutHandler,
  ),
  ShortcutEvent.fromCommand(
    key: 'enter',
    command: 'enter',
    handler: enterWithoutShiftInTextNodesHandler,
  ),
  ShortcutEvent.fromCommand(
    key: 'markdown',
    command: 'space',
    handler: whiteSpaceHandler,
  ),
  ShortcutEvent.fromCommand(
    key: 'select all',
    command: 'meta+a',
    windowsCommand: 'ctrl+a',
    linuxCommand: 'ctrl+a',
    handler: selectAllHandler,
  ),
  ShortcutEvent.fromCommand(
    key: 'Page up',
    command: 'page up',
    handler: pageUpHandler,
  ),
  ShortcutEvent.fromCommand(
    key: 'Page down',
    command: 'page down',
    handler: pageDownHandler,
  ),
  ShortcutEvent.fromCommand(
    key: 'Tab',
    command: 'tab',
    handler: tabHandler,
  ),
  ShortcutEvent.fromCommand(
    key: 'Backquote to code',
    command: 'backquote',
    handler: backquoteToCodeHandler,
  ),
  ShortcutEvent.fromCharacter(
    key: 'Double tilde to strikethrough',
    character: '~',
    handler: doubleTildeToStrikethrough,
  ),
  ShortcutEvent.fromCommand(
    key: 'Markdown link or image',
    command: 'shift+parenthesis right',
    handler: markdownLinkOrImageHandler,
  ),
  ShortcutEvent.fromCommand(
    key: 'Exit editing mode',
    command: 'escape',
    handler: exitEditingModeEventHandler,
  ),
  ShortcutEvent.fromCharacter(
    key: 'Underscore to italic',
    character: '_',
    handler: underscoreToItalicHandler,
  ),
  ShortcutEvent.fromCharacter(
    key: 'Double asterisk to bold',
    character: '*',
    handler: doubleAsteriskToBoldHandler,
  ),
  ShortcutEvent.fromCharacter(
    key: 'Double underscore to bold',
    character: '_',
    handler: doubleUnderscoreToBoldHandler,
  ),
  ShortcutEvent.fromCommand(
    key: 'Move cursor left one word',
    command: 'alt+arrow left',
    windowsCommand: 'alt+arrow left',
    linuxCommand: 'alt+arrow left',
    handler: cursorLeftWordMove,
  ),
  ShortcutEvent.fromCommand(
    key: 'Move cursor right one word',
    command: 'alt+arrow right',
    windowsCommand: 'alt+arrow right',
    linuxCommand: 'alt+arrow right',
    handler: cursorRightWordMove,
  ),

  // https://github.com/flutter/flutter/issues/104944
  // Workaround: Using space editing on the web platform often results in errors,
  //  so adding a shortcut event to handle the space input instead of using the
  //  `input_service`.
  if (kIsWeb)
    ShortcutEvent.fromCommand(
      key: 'Space on the Web',
      command: 'space',
      handler: spaceOnWebHandler,
    ),
];
