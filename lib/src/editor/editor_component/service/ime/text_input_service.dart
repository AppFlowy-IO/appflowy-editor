import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract class TextInputService {
  TextInputService({
    required this.onInsert,
    required this.onDelete,
    required this.onReplace,
    required this.onNonTextUpdate,
    required this.onPerformAction,
    this.onFloatingCursor,
    this.contentInsertionConfiguration,
  });

  Future<void> Function(TextEditingDeltaInsertion insertion) onInsert;
  Future<void> Function(TextEditingDeltaDeletion deletion) onDelete;
  Future<void> Function(TextEditingDeltaReplacement replacement) onReplace;
  Future<void> Function(TextEditingDeltaNonTextUpdate nonTextUpdate)
      onNonTextUpdate;
  Future<void> Function(TextInputAction action) onPerformAction;
  Future<void> Function(RawFloatingCursorPoint point)? onFloatingCursor;

  final ContentInsertionConfiguration? contentInsertionConfiguration;

  TextRange? get composingTextRange;
  bool get attached;

  void updateCaretPosition(Size size, Matrix4 transform, Rect rect);

  /// Updates the [TextEditingValue] of the text currently being edited.
  ///
  /// Note that if there are IME-related requirements,
  /// please config `composing` value within [TextEditingValue]
  ///
  /// [BuildContext] is used to get current keyboard appearance(light or dark)
  void attach(
    TextEditingValue textEditingValue,
    TextInputConfiguration configuration,
  );

  /// Applies insertion, deletion and replacement
  ///   to the text currently being edited.
  ///
  /// For more information, please check [TextEditingDelta].
  Future<void> apply(List<TextEditingDelta> deltas);

  /// Closes the editing state of the text currently being edited.
  void close();
}
