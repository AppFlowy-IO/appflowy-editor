import 'dart:math';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';

abstract class TextInputService {
  TextInputService({
    required this.onInsert,
    required this.onDelete,
    required this.onReplace,
    required this.onNonTextUpdate,
    required this.onPerformAction,
  });

  Future<void> Function(TextEditingDeltaInsertion insertion) onInsert;
  Future<void> Function(TextEditingDeltaDeletion deletion) onDelete;
  Future<void> Function(TextEditingDeltaReplacement replacement) onReplace;
  Future<void> Function(TextEditingDeltaNonTextUpdate nonTextUpdate)
      onNonTextUpdate;
  Future<void> Function(TextInputAction action) onPerformAction;

  TextRange? get composingTextRange;
  bool get attached;

  void updateCaretPosition(Size size, Matrix4 transform, Rect rect);

  /// Updates the [TextEditingValue] of the text currently being edited.
  ///
  /// Note that if there are IME-related requirements,
  ///   please config `composing` value within [TextEditingValue]
  void attach(TextEditingValue textEditingValue);

  /// Applies insertion, deletion and replacement
  ///   to the text currently being edited.
  ///
  /// For more information, please check [TextEditingDelta].
  Future<void> apply(List<TextEditingDelta> deltas);

  /// Closes the editing state of the text currently being edited.
  void close();
}

class DeltaTextInputService extends TextInputService with DeltaTextInputClient {
  DeltaTextInputService({
    required super.onInsert,
    required super.onDelete,
    required super.onReplace,
    required super.onNonTextUpdate,
    required super.onPerformAction,
  });

  @override
  TextRange? composingTextRange;

  @override
  bool get attached => _textInputConnection?.attached ?? false;

  @override
  AutofillScope? get currentAutofillScope => throw UnimplementedError();

  @override
  TextEditingValue? get currentTextEditingValue => throw UnimplementedError();

  TextInputConnection? _textInputConnection;

  @override
  Future<void> apply(List<TextEditingDelta> deltas) async {
    final formattedDeltas = deltas.map((e) => e.format()).toList();
    for (final delta in formattedDeltas) {
      _updateComposing(delta);

      if (delta is TextEditingDeltaInsertion) {
        await onInsert(delta);
      } else if (delta is TextEditingDeltaDeletion) {
        await onDelete(delta);
      } else if (delta is TextEditingDeltaReplacement) {
        await onReplace(delta);
      } else if (delta is TextEditingDeltaNonTextUpdate) {
        await onNonTextUpdate(delta);
      }
    }
  }

  @override
  void attach(TextEditingValue textEditingValue) {
    if (_textInputConnection == null ||
        _textInputConnection!.attached == false) {
      _textInputConnection = TextInput.attach(
        this,
        const TextInputConfiguration(
          enableDeltaModel: true,
          inputType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          inputAction: TextInputAction.newline,
        ),
      );
    }

    final formattedValue = textEditingValue.format();
    _textInputConnection!
      ..setEditingState(formattedValue)
      ..show();

    Log.input.debug(
      'attach text editing value: $textEditingValue',
    );
  }

  @override
  void close() {
    _textInputConnection?.close();
    _textInputConnection = null;
  }

  @override
  void updateEditingValueWithDeltas(List<TextEditingDelta> textEditingDeltas) {
    Log.input.debug(
      textEditingDeltas.map((delta) => delta.toString()).toString(),
    );
    apply(textEditingDeltas);
  }

  // TODO: support IME in linux / windows / ios / android
  // Only support macOS now.
  @override
  void updateCaretPosition(Size size, Matrix4 transform, Rect rect) {
    _textInputConnection
      ?..setEditableSizeAndTransform(size, transform)
      ..setCaretRect(rect);
  }

  @override
  void connectionClosed() {}

  @override
  void insertTextPlaceholder(Size size) {}

  @override
  Future<void> performAction(TextInputAction action) async {
    return onPerformAction(action);
  }

  @override
  void performPrivateCommand(String action, Map<String, dynamic> data) {}

  @override
  void removeTextPlaceholder() {}

  @override
  void showAutocorrectionPromptRect(int start, int end) {}

  @override
  void showToolbar() {}

  @override
  void updateEditingValue(TextEditingValue value) {}

  @override
  void updateFloatingCursor(RawFloatingCursorPoint point) {}

  @override
  void didChangeInputControl(
    TextInputControl? oldControl,
    TextInputControl? newControl,
  ) {}

  @override
  void performSelector(String selectorName) {}

  @override
  void insertContent(KeyboardInsertedContent content) {}

  void _updateComposing(TextEditingDelta delta) {
    if (delta is! TextEditingDeltaNonTextUpdate) {
      if (composingTextRange != null &&
          composingTextRange!.start != -1 &&
          delta.composing.end != -1) {
        composingTextRange = TextRange(
          start: composingTextRange!.start,
          end: delta.composing.end,
        );
      } else {
        composingTextRange = delta.composing;
      }
    }
  }
}

const String _whitespace = ' ';
const int _len = 1;

extension on TextEditingValue {
  // The IME will not report the backspace button if the cursor is at the beginning of the text.
  // Therefore, we need to add a transparent symbol at the start to ensure that we can capture the backspace event.
  TextEditingValue format() {
    final text = _whitespace + this.text;
    final selection = this.selection >> _len;
    final composing = this.composing >> _len;

    return TextEditingValue(
      text: text,
      selection: selection,
      composing: composing,
    );
  }
}

extension on TextEditingDelta {
  TextEditingDelta format() {
    if (this is TextEditingDeltaInsertion) {
      return (this as TextEditingDeltaInsertion).format();
    } else if (this is TextEditingDeltaDeletion) {
      return (this as TextEditingDeltaDeletion).format();
    } else if (this is TextEditingDeltaReplacement) {
      return (this as TextEditingDeltaReplacement).format();
    } else if (this is TextEditingDeltaNonTextUpdate) {
      return (this as TextEditingDeltaNonTextUpdate).format();
    }
    throw UnimplementedError();
  }
}

extension on TextEditingDeltaInsertion {
  TextEditingDeltaInsertion format() => TextEditingDeltaInsertion(
        oldText: oldText << _len,
        textInserted: textInserted,
        insertionOffset: insertionOffset - _len,
        selection: selection << _len,
        composing: composing << _len,
      );
}

extension on TextEditingDeltaDeletion {
  TextEditingDeltaDeletion format() => TextEditingDeltaDeletion(
        oldText: oldText << _len,
        deletedRange: deletedRange << _len,
        selection: selection << _len,
        composing: composing << _len,
      );
}

extension on TextEditingDeltaReplacement {
  TextEditingDeltaReplacement format() => TextEditingDeltaReplacement(
        oldText: oldText << _len,
        replacementText: replacementText,
        replacedRange: replacedRange << _len,
        selection: selection << _len,
        composing: composing << _len,
      );
}

extension on TextEditingDeltaNonTextUpdate {
  TextEditingDeltaNonTextUpdate format() => TextEditingDeltaNonTextUpdate(
        oldText: oldText << _len,
        selection: selection << _len,
        composing: composing << _len,
      );
}

extension on TextSelection {
  TextSelection operator <<(int shiftAmount) => shift(-shiftAmount);
  TextSelection operator >>(int shiftAmount) => shift(shiftAmount);
  TextSelection shift(int shiftAmount) => TextSelection(
        baseOffset: max(0, baseOffset + shiftAmount),
        extentOffset: max(0, extentOffset + shiftAmount),
      );
}

extension on TextRange {
  TextRange operator <<(int shiftAmount) => shift(-shiftAmount);
  TextRange operator >>(int shiftAmount) => shift(shiftAmount);
  TextRange shift(int shiftAmount) => !isValid
      ? this
      : TextRange(
          start: max(0, start + shiftAmount),
          end: max(0, end + shiftAmount),
        );
}

extension on String {
  String operator <<(int shiftAmount) => shift(shiftAmount);
  String shift(int shiftAmount) {
    if (shiftAmount > length) {
      throw const FormatException();
    }
    return substring(shiftAmount);
  }
}
