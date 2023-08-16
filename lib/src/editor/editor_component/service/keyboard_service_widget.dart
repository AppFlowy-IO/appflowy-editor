import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'ime/delta_input_impl.dart';

// handle software keyboard and hardware keyboard
class KeyboardServiceWidget extends StatefulWidget {
  const KeyboardServiceWidget({
    super.key,
    this.commandShortcutEvents = const [],
    this.characterShortcutEvents = const [],
    this.focusNode,
    required this.child,
  });

  final FocusNode? focusNode;
  final List<CommandShortcutEvent> commandShortcutEvents;
  final List<CharacterShortcutEvent> characterShortcutEvents;
  final Widget child;

  @override
  State<KeyboardServiceWidget> createState() => KeyboardServiceWidgetState();
}

@visibleForTesting
class KeyboardServiceWidgetState extends State<KeyboardServiceWidget>
    implements AppFlowyKeyboardService {
  late final SelectionGestureInterceptor interceptor;
  late final EditorState editorState;
  late final TextInputService textInputService;
  late final FocusNode focusNode;

  // use for IME only
  bool enableShortcuts = true;

  @override
  void initState() {
    super.initState();

    editorState = Provider.of<EditorState>(context, listen: false);
    editorState.selectionNotifier.addListener(_onSelectionChanged);

    interceptor = SelectionGestureInterceptor(
      key: 'keyboard',
      canTap: (details) {
        enableShortcuts = true;
        focusNode.requestFocus();
        textInputService.close();
        return true;
      },
    );
    editorState.service.selectionService
        .registerGestureInterceptor(interceptor);

    textInputService = NonDeltaTextInputService(
      onInsert: (insertion) async => await onInsert(
        insertion,
        editorState,
        widget.characterShortcutEvents,
      ),
      onDelete: (deletion) async => await onDelete(
        deletion,
        editorState,
      ),
      onReplace: (replacement) async => await onReplace(
        replacement,
        editorState,
        widget.characterShortcutEvents,
      ),
      onNonTextUpdate: onNonTextUpdate,
      onPerformAction: (action) async => await onPerformAction(
        action,
        editorState,
      ),
    );

    focusNode = widget.focusNode ?? FocusNode(debugLabel: 'keyboard service');
    focusNode.addListener(_onFocusChanged);

    keepEditorFocusNotifier.addListener(_onKeepEditorFocusChanged);
  }

  @override
  void dispose() {
    editorState.selectionNotifier.removeListener(_onSelectionChanged);
    editorState.service.selectionService.unregisterGestureInterceptor(
      'keyboard',
    );
    focusNode.removeListener(_onFocusChanged);
    if (widget.focusNode == null) {
      focusNode.dispose();
    }
    keepEditorFocusNotifier.removeListener(_onKeepEditorFocusChanged);
    super.dispose();
  }

  @override
  void disable({
    bool showCursor = false,
    UnfocusDisposition disposition = UnfocusDisposition.previouslyFocusedChild,
  }) =>
      focusNode.unfocus(disposition: disposition);

  @override
  void enable() => focusNode.requestFocus();

  // Used in mobile only
  @override
  void closeKeyboard() {
    textInputService.close();
  }

  // Used in mobile only
  @override
  void enableKeyBoard(Selection selection) {
    _attachTextInputService(selection);
  }

  @override
  KeyEventResult onKey(RawKeyEvent event) => throw UnimplementedError();

  @override
  Widget build(BuildContext context) {
    Widget child = widget.child;
    // if there is no command shortcut event, we don't need to handle hardware keyboard.
    // like in read-only mode.
    if (widget.commandShortcutEvents.isNotEmpty) {
      // the Focus widget is used to handle hardware keyboard.
      child = Focus(
        focusNode: focusNode,
        onKey: _onKey,
        child: child,
      );
    }

    // ignore the default behavior of the space key on web
    if (kIsWeb) {
      child = Shortcuts(
        shortcuts: {
          LogicalKeySet(LogicalKeyboardKey.space):
              const DoNothingAndStopPropagationIntent(),
        },
        child: child,
      );
    }

    return child;
  }

  /// handle hardware keyboard
  KeyEventResult _onKey(FocusNode node, RawKeyEvent event) {
    if (event is! RawKeyDownEvent || !enableShortcuts) {
      return KeyEventResult.ignored;
    }

    for (final shortcutEvent in widget.commandShortcutEvents) {
      // check if the shortcut event can respond to the raw key event
      if (shortcutEvent.canRespondToRawKeyEvent(event)) {
        final result = shortcutEvent.handler(editorState);
        if (result == KeyEventResult.handled) {
          Log.keyboard.debug(
            'keyboard service - handled by command shortcut event: $shortcutEvent',
          );
          return KeyEventResult.handled;
        } else if (result == KeyEventResult.skipRemainingHandlers) {
          Log.keyboard.debug(
            'keyboard service - skip by command shortcut event: $shortcutEvent',
          );
          return KeyEventResult.skipRemainingHandlers;
        }
        continue;
      }
    }

    return KeyEventResult.ignored;
  }

  void _onSelectionChanged() {
    enableShortcuts = true;
    // attach the delta text input service if needed
    final selection = editorState.selection;
    if (selection == null) {
      textInputService.close();
    } else {
      // For the deletion, we should attach the text input service immediately.
      _attachTextInputService(selection);
      _updateCaretPosition(selection);

      // debounce the attachTextInputService function to avoid
      // the text input service being attached too frequently.
      // Debounce.debounce(
      //   'attachTextInputService',
      //   const Duration(milliseconds: 200),
      //   () => _attachTextInputService(selection),
      // );

      if (editorState.selectionUpdateReason == SelectionUpdateReason.uiEvent) {
        focusNode.requestFocus();
        Log.editor.debug('keyboard service - request focus');
      }
    }
  }

  void _attachTextInputService(Selection selection) {
    final textEditingValue = _getCurrentTextEditingValue(selection);
    if (textEditingValue != null) {
      textInputService.attach(
        textEditingValue,
        TextInputConfiguration(
          enableDeltaModel: false,
          inputType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          inputAction: TextInputAction.newline,
          keyboardAppearance: Theme.of(context).brightness,
        ),
      );
      // disable shortcuts when the IME active
      enableShortcuts = textEditingValue.composing == TextRange.empty;
    } else {
      enableShortcuts = true;
    }
  }

  // This function is used to get the current text editing value of the editor
  // based on the given selection.
  TextEditingValue? _getCurrentTextEditingValue(Selection selection) {
    // Get all the editable nodes in the selection.
    final editableNodes = editorState
        .getNodesInSelection(selection)
        .where((element) => element.delta != null);

    // Get the composing text range.
    final composingTextRange =
        textInputService.composingTextRange ?? TextRange.empty;
    if (editableNodes.isNotEmpty) {
      // Get the text by concatenating all the editable nodes in the selection.
      var text = editableNodes.fold<String>(
        '',
        (sum, editableNode) => '$sum${editableNode.delta!.toPlainText()}\n',
      );

      // Remove the last '\n'.
      text = text.substring(0, text.length - 1);

      return TextEditingValue(
        text: text,
        selection: TextSelection(
          baseOffset: selection.startIndex,
          extentOffset: selection.endIndex,
        ),
        composing: composingTextRange,
      );
    }
    return null;
  }

  void _onFocusChanged() {
    Log.editor.debug(
      'keyboard service - focus changed: ${focusNode.hasFocus}}',
    );

    // clear the selection when the focus is lost.
    if (!focusNode.hasFocus) {
      if (PlatformExtension.isDesktopOrWeb) {
        if (keepEditorFocusNotifier.value > 0) {
          return;
        }
      }
      final children =
          WidgetsBinding.instance.focusManager.primaryFocus?.children;
      if (children != null && !children.contains(focusNode)) {
        editorState.selection = null;
      }
      textInputService.close();
    }
  }

  void _onKeepEditorFocusChanged() {
    Log.editor.debug(
      'keyboard service - on keep editor focus changed: ${keepEditorFocusNotifier.value}}',
    );

    if (keepEditorFocusNotifier.value == 0) {
      focusNode.requestFocus();
    }
  }

  // only verify on macOS.
  void _updateCaretPosition(Selection? selection) {
    if (selection == null || !selection.isCollapsed) {
      return;
    }
    final node = editorState.getNodeAtPath(selection.start.path);
    if (node == null) {
      return;
    }
    final renderBox = node.renderBox;
    final selectable = node.selectable;
    if (renderBox != null && selectable != null) {
      final size = renderBox.size;
      final transform = renderBox.getTransformTo(null);
      final rect = selectable.getCursorRectInPosition(selection.end);
      if (rect != null) {
        textInputService.updateCaretPosition(size, transform, rect);
      }
    }
  }
}
