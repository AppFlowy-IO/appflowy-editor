import 'package:appflowy_editor/src/editor/editor_state.dart';
import 'package:flutter/material.dart';

/// Handler function for keyboard shortcut events.
///
/// Processes keyboard input and returns a [KeyEventResult] indicating
/// whether the event was handled.
///
/// Parameters:
/// - [editorState]: The current editor state
/// - [event]: The keyboard event that triggered this handler
///
/// Returns:
/// - [KeyEventResult.handled] if the shortcut was processed
/// - [KeyEventResult.ignored] if the shortcut was not handled
/// - [KeyEventResult.skipRemainingHandlers] to stop event propagation
///
/// Example:
/// ```dart
/// ShortcutEventHandler myHandler = (editorState, event) {
///   if (event?.logicalKey == LogicalKeyboardKey.keyB &&
///       event?.isMetaPressed == true) {
///     // Handle bold formatting
///     return KeyEventResult.handled;
///   }
///   return KeyEventResult.ignored;
/// };
/// ```
typedef ShortcutEventHandler = KeyEventResult Function(
    EditorState editorState, KeyEvent? event,);
