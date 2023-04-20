import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/util/debounce.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ime/delta_input_impl.dart';

// handle software keyboard and hardware keyboard
class KeyboardServiceWidget extends StatefulWidget {
  const KeyboardServiceWidget({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<KeyboardServiceWidget> createState() => _KeyboardServiceWidgetState();
}

class _KeyboardServiceWidgetState extends State<KeyboardServiceWidget> {
  bool isAttached = false;

  late final TextInputService textInputService;
  late EditorState editorState;

  @override
  void initState() {
    super.initState();

    editorState = Provider.of<EditorState>(context, listen: false);

    textInputService = DeltaTextInputService(
      onInsert: (insertion) => onInsert(insertion, editorState),
      onDelete: (deletion) => onDelete(deletion, editorState),
      onReplace: onReplace,
      onNonTextUpdate: onNonTextUpdate,
      onPerformAction: (action) => onPerformAction(action, editorState),
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      editorState.selection.currentSelection.addListener(_onSelectionChanged);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    editorState = Provider.of<EditorState>(context, listen: false);
  }

  @override
  void dispose() {
    editorState.selection.currentSelection.removeListener(_onSelectionChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void _onSelectionChanged() {
    // attach the delta text input service if needed
    final selection = editorState.selection.currentSelection.value;
    if (selection == null) {
      if (textInputService.attached && isAttached) {
        textInputService.close();
        isAttached = false;
      }
    } else {
      Debounce.debounce(
        'attachTextInputService',
        const Duration(milliseconds: 200),
        () => _attachTextInputService(selection),
      );
    }
  }

  void _attachTextInputService(Selection selection) {
    if (textInputService.attached && isAttached) {
      return;
    }
    final textEditingValue = _getCurrentTextEditingValue(selection);
    if (textEditingValue != null) {
      Log.input.debug(
        'attach text editing value: $textEditingValue',
      );
      textInputService.attach(textEditingValue);
      isAttached = true;
    }
  }

  TextEditingValue? _getCurrentTextEditingValue(Selection selection) {
    final editableNodes = editorState.selection.currentSelectedNodes.where(
      (element) => element.delta != null,
    );
    final selection = editorState.selection.currentSelection.value;
    final composingTextRange = textInputService.composingTextRange;
    if (editableNodes.isNotEmpty && selection != null) {
      final text = editableNodes.fold<String>(
        '',
        (sum, editableNode) => '$sum${editableNode.delta!.toPlainText()}\n',
      );
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
}
