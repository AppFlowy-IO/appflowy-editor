import 'package:appflowy_editor/appflowy_editor.dart';
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

  @override
  void initState() {
    super.initState();

    editorState = Provider.of<EditorState>(context, listen: false);
    editorState.selectionNotifier.addListener(_onSelectionChanged);

    interceptor = SelectionGestureInterceptor(
      key: 'keyboard',
      canTap: (details) {
        focusNode.requestFocus();
        return true;
      },
    );
    editorState.service.selectionService
        .registerGestureInterceptor(interceptor);

    textInputService = DeltaTextInputService(
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

  @override
  KeyEventResult onKey(RawKeyEvent event) => throw UnimplementedError();

  @override
  List<ShortcutEvent> get shortcutEvents => throw UnimplementedError();

  @override
  Widget build(BuildContext context) {
    if (widget.commandShortcutEvents.isNotEmpty) {
      // the Focus widget is used to handle hardware keyboard.
      return Focus(
        focusNode: focusNode,
        onKey: _onKey,
        child: widget.child,
      );
    }
    // if there is no command shortcut event, we don't need to handle hardware keyboard.
    // like in read-only mode.
    return widget.child;
  }

  /// handle hardware keyboard
  KeyEventResult _onKey(FocusNode node, RawKeyEvent event) {
    if (event is! RawKeyDownEvent) {
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
    // attach the delta text input service if needed
    final selection = editorState.selection;
    if (selection == null) {
      textInputService.close();
    } else {
      // debounce the attachTextInputService function to avoid
      // the text input service being attached too frequently.
      Debounce.debounce(
        'attachTextInputService',
        const Duration(milliseconds: 200),
        () => _attachTextInputService(selection),
      );

      if (editorState.selectionUpdateReason == SelectionUpdateReason.uiEvent) {
        focusNode.requestFocus();
        Log.editor.debug('keyboard service - request focus');
      }
    }
  }

  void _attachTextInputService(Selection selection) {
    final textEditingValue = _getCurrentTextEditingValue(selection);
    if (textEditingValue != null) {
      textInputService.attach(textEditingValue);
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
    final composingTextRange = textInputService.composingTextRange;
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
          baseOffset: selection.start.offset,
          extentOffset: selection.end.offset,
        ),
        composing:
            composingTextRange ?? TextRange.collapsed(selection.start.offset),
      );
    }
    return null;
  }

  void _onFocusChanged() {
    Log.editor.debug(
      'keyboard service - focus changed: ${focusNode.hasFocus}}',
    );
  }
}
