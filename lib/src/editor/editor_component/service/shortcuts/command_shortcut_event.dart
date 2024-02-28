import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

typedef CommandShortcutEventHandler = KeyEventResult Function(
  EditorState editorState,
);

/// Defines the implementation of shortcut event based on command.
class CommandShortcutEvent {
  CommandShortcutEvent({
    required this.key,
    required this.command,
    required this.handler,
    required String Function()? getDescription,
    String? windowsCommand,
    String? macOSCommand,
    String? linuxCommand,
  }) : _getDescription = getDescription {
    updateCommand(
      command: command,
      windowsCommand: windowsCommand,
      macOSCommand: macOSCommand,
      linuxCommand: linuxCommand,
    );
  }

  /// The unique key.
  ///
  /// Usually, uses the description as the key.
  final String key;

  /// The string representation for the keyboard keys.
  ///
  /// The following is the mapping relationship of modify key.
  ///   ctrl: Ctrl
  ///   meta: Command in macOS or Control in Windows.
  ///   alt: Alt
  ///   shift: Shift
  ///   cmd: meta
  ///   win: meta
  ///
  /// Refer to [keyMapping] for other keys.
  ///
  /// Uses ',' to split different keyboard key combinations.
  ///
  /// Like, 'ctrl+c,cmd+c'
  ///
  String command;

  /// Callback to return the localized description of the command.
  final String Function()? _getDescription;

  final CommandShortcutEventHandler handler;

  List<Keybinding> get keybindings => _keybindings;
  List<Keybinding> _keybindings = [];

  String? get description =>
      _getDescription != null ? _getDescription!() : null;

  void updateCommand({
    String? command,
    String? windowsCommand,
    String? macOSCommand,
    String? linuxCommand,
  }) {
    if (command == null &&
        windowsCommand == null &&
        macOSCommand == null &&
        linuxCommand == null) {
      return;
    }
    var matched = false;
    if ((PlatformExtension.isWindows || PlatformExtension.isWebOnWindows) &&
        windowsCommand != null &&
        windowsCommand.isNotEmpty) {
      this.command = windowsCommand;
      matched = true;
    } else if ((PlatformExtension.isMacOS || PlatformExtension.isWebOnMacOS) &&
        macOSCommand != null &&
        macOSCommand.isNotEmpty) {
      this.command = macOSCommand;
      matched = true;
    } else if ((PlatformExtension.isLinux || PlatformExtension.isWebOnLinux) &&
        linuxCommand != null &&
        linuxCommand.isNotEmpty) {
      this.command = linuxCommand;
      matched = true;
    } else if (command != null && command.isNotEmpty) {
      this.command = command;
      matched = true;
    }

    if (matched) {
      _keybindings = this
          .command
          .split(',')
          .map((e) => Keybinding.parse(e))
          .toList(growable: false);
    }
  }

  bool canRespondToRawKeyEvent(KeyEvent event) {
    return keybindings.containsKeyEvent(event);
  }

  KeyEventResult execute(EditorState editorState) {
    return handler(editorState);
  }

  CommandShortcutEvent copyWith({
    String? key,
    String Function()? getDescription,
    String? command,
    CommandShortcutEventHandler? handler,
  }) {
    return CommandShortcutEvent(
      key: key ?? this.key,
      getDescription: getDescription ?? _getDescription,
      command: command ?? this.command,
      handler: handler ?? this.handler,
    );
  }

  @override
  String toString() =>
      'CommandShortcutEvent(key: $key, command: $command, handler: $handler)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CommandShortcutEvent &&
        other.key == key &&
        other.command == command &&
        other.handler == handler;
  }

  @override
  int get hashCode => key.hashCode ^ command.hashCode ^ handler.hashCode;
}
