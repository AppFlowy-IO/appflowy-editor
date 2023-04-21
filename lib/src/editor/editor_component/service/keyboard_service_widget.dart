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
  late final TextInputService textInputService;
  late final EditorState editorState;

  @override
  void initState() {
    super.initState();

    editorState = Provider.of<EditorState>(context, listen: false);
    editorState.selectionNotifier.addListener(_onSelectionChanged);

    textInputService = DeltaTextInputService(
      onInsert: (insertion) => onInsert(insertion, editorState),
      onDelete: (deletion) => onDelete(deletion, editorState),
      onReplace: onReplace,
      onNonTextUpdate: onNonTextUpdate,
      onPerformAction: (action) => onPerformAction(action, editorState),
    );
  }

  @override
  void dispose() {
    editorState.selectionNotifier.removeListener(_onSelectionChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void _onSelectionChanged() {
    // attach the delta text input service if needed
    final selection = editorState.selection;
    if (selection == null) {
      textInputService.close();
    } else {
      Debounce.debounce(
        'attachTextInputService',
        const Duration(milliseconds: 200),
        () => _attachTextInputService(selection),
      );
    }
  }

  void _attachTextInputService(Selection selection) {
    final textEditingValue = _getCurrentTextEditingValue(selection);
    if (textEditingValue != null) {
      textInputService.attach(textEditingValue);
    }
  }

  TextEditingValue? _getCurrentTextEditingValue(Selection selection) {
    final editableNodes =
        editorState.selectionService.currentSelectedNodes.where(
      (element) => element.delta != null,
    );
    final selection = editorState.selection;
    final composingTextRange = textInputService.composingTextRange;
    if (editableNodes.isNotEmpty && selection != null) {
      var text = editableNodes.fold<String>(
        '',
        (sum, editableNode) => '$sum${editableNode.delta!.toPlainText()}\n',
      );
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
}
