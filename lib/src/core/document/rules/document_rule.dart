import 'package:appflowy_editor/appflowy_editor.dart';

abstract class DocumentRule {
  const DocumentRule();

  /// Whether the rule should be applied.
  bool shouldApply({
    required EditorState editorState,
    required EditorTransactionValue value,
  });

  /// Apply the rule to the document.
  Future<void> apply({
    required EditorState editorState,
    required EditorTransactionValue value,
  });
}
