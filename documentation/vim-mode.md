# Vim Mode

Vim mode is not meant to emulate all the vim functionality but instead provide partial emulation.
The editor was not built to have vim mode from the beginning. However this mode allows some functionality to be used.

## Why not leverage on the existing shortcuts system?

Leveraging on the shortcuts system was the inital solution however that showed its limitations.
In some cases if the vim shortcut did not recognize the key input as a vim command, it will treat it as regular input this would result in printing letters onto the editor.
Which is not meant to be the case with Vim. 'Normal Mode' does not allow any text input besides the known shortcuts/commands.
The proposed idea was to instead capture keyboard events directly without modifying the core editor itself.


### So how does it work?

Inside the `keyboard_service_widget.dart` is where the keyboard capture is happening. Below is the snippet that is used specifically for vim mode.

```dart
    if (editorState.vimMode) {
      if (editorState.mode == VimModes.normalMode) {
        final VimCommandShortcutEvent vimCommandShortcutEvent =
            VimCommandShortcutEvent();
        final vimResult = vimCommandShortcutEvent.handleKey(event, editorState);
        if (vimResult == KeyEventResult.handled) {
          return KeyEventResult.handled;
        }
      }
    }
```

We only execute the block inside the if statement if the Vim Mode was enabled from the beginning. Vim Mode can be activated from the main AppFlowy constructor.

```dart
AppFlowyEditor(
          vimMode: true,
          editorState: editorState,
          // Other AppFlowy Commands
          ...
        )
```

## Technical Details

The `VimCommandShortcutEvent` value being used in `keyboard_service_widget.dart` does extend the CommandShortcut class but its not entirely used.
Instead its more of a wrapper for the actual vim handler. This was done so the vim keys can be registered in AppFlowy and not break anything else in the process.


```dart
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
```

### Vim Shortcuts handling

There are known keys for Vim to at least get around the document, such as `[h, j, k, l]` any other keys would be either extensions of the mentioned keys or new ones entirely.
Currently there are hard-coded keys which the Vim keyboard handler will check with for every key press. If the pressed keys are within the list of known keys they will trigger an action.
Any other key that is not known will just be ignored.


In Vim there is the concept of doing key combinations or awaiting key presses. For example `4j` means jump 4 lines down from the current position.
Normally `4` and `j` are registered as separate keys, however with VimMode we hold the keys in a buffer before we release them.
So if `4j` matches then an action is triggered however if we try `10m` that will not trigger anything because `m` is not a known key, so the buffer will be cleared.
