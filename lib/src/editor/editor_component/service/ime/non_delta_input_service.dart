import 'dart:io';
import 'dart:math';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/ime/text_diff.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/ime/text_input_service.dart';
import 'package:flutter/services.dart';

class NonDeltaTextInputService extends TextInputService with TextInputClient {
  NonDeltaTextInputService({
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
  @override
  TextEditingValue? get currentTextEditingValue => _currentTextEditingValue;

  TextEditingValue? _currentTextEditingValue;
  set currentTextEditingValue(TextEditingValue? newValue) {
    _currentTextEditingValue = newValue;
  }

  TextInputConnection? _textInputConnection;

  final String debounceKey = 'updateEditingValue';

  int skipUpdateEditingValue = 0;

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
  void attach(
    TextEditingValue textEditingValue,
    TextInputConfiguration configuration,
  ) {
    final formattedValue = textEditingValue.format();
    if (currentTextEditingValue == formattedValue) {
      return;
    }

    if (_textInputConnection == null ||
        _textInputConnection!.attached == false) {
      _textInputConnection = TextInput.attach(
        this,
        configuration,
      );
    }

    Debounce.cancel(debounceKey);

    // the set editing state will update the text editing value in macOS.
    // we just skip the unnecessary update.
    if (Platform.isMacOS) {
      skipUpdateEditingValue += 1;
    }

    _textInputConnection!
      ..setEditingState(formattedValue)
      ..show();

    currentTextEditingValue = formattedValue;

    Log.input.debug(
      'attach text editing value: $textEditingValue',
    );
  }

  @override
  void updateEditingValue(TextEditingValue value) {
    if (Platform.isMacOS && skipUpdateEditingValue > 0) {
      skipUpdateEditingValue -= 1;
      return;
    }
    if (currentTextEditingValue == value) {
      return;
    }
    final deltas = getTextEditingDeltas(currentTextEditingValue, value);
    // On mobile, the IME will send a lot of updateEditingValue events, so we
    // need to debounce it to combine them together.
    Debounce.debounce(
      debounceKey,
      PlatformExtension.isMobile
          ? const Duration(milliseconds: 10)
          : Duration.zero,
      () {
        currentTextEditingValue = value;
        apply(deltas);
      },
    );
  }

  @override
  void close() {
    currentTextEditingValue = null;
    composingTextRange = null;
    _textInputConnection?.close();
    _textInputConnection = null;
  }

  // TODO: support IME in linux / ios / android
  // Only verify in macOS and Windows now.
  @override
  void updateCaretPosition(Size size, Matrix4 transform, Rect rect) {
    _textInputConnection
      ?..setEditableSizeAndTransform(size, transform)
      ..setCaretRect(rect)
      ..setComposingRect(rect.translate(0, rect.height));
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

    if (PlatformExtension.isWindows && delta is TextEditingDeltaNonTextUpdate) {
      composingTextRange = delta.composing;
    }
  }
}

const String _whitespace = ' ';
const int _len = _whitespace.length;

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
      return '';
    }
    return substring(shiftAmount);
  }
}
