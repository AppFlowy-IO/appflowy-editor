import 'package:appflowy_editor/src/editor/editor_component/service/ime/non_delta_input_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NonDeltaTextInputService', () {
    test('actions', () {
      bool onInsert = false,
          onDelete = false,
          onReplace = false,
          onNonTextUpdate = false,
          onPerformAction = false;

      final inputService = NonDeltaTextInputService(
        onInsert: (_) async => onInsert = true,
        onDelete: (_) async => onDelete = true,
        onReplace: (_) async => onReplace = true,
        onNonTextUpdate: (_) async => onNonTextUpdate = true,
        onPerformAction: (_) async => onPerformAction = true,
      );

      expect(inputService.attached, false);

      expect(
        () => inputService.currentAutofillScope,
        throwsA(isA<UnimplementedError>()),
      );

      // Insert
      const insertion = TextEditingDeltaInsertion(
        oldText: 'oldText',
        textInserted: 'textInserted',
        insertionOffset: 0,
        selection: TextSelection(baseOffset: 0, extentOffset: 0),
        composing: TextRange(start: 0, end: 0),
      );

      inputService.apply([insertion]);
      expect(onInsert, true);

      // Delete
      const deletion = TextEditingDeltaDeletion(
        oldText: 'oldText',
        deletedRange: TextRange(start: 0, end: 1),
        selection: TextSelection(baseOffset: 0, extentOffset: 0),
        composing: TextRange(start: 0, end: 0),
      );

      inputService.apply([deletion]);
      expect(onDelete, true);

      // Replace
      const replace = TextEditingDeltaReplacement(
        oldText: 'oldText',
        replacementText: 'replacementText',
        replacedRange: TextRange(start: 0, end: 1),
        selection: TextSelection(baseOffset: 0, extentOffset: 0),
        composing: TextRange(start: 0, end: 0),
      );

      inputService.apply([replace]);
      expect(onReplace, true);

      // Non-text Update
      const nonTextUpdate = TextEditingDeltaNonTextUpdate(
        oldText: 'oldText',
        selection: TextSelection(baseOffset: 0, extentOffset: 0),
        composing: TextRange(start: 0, end: 0),
      );

      inputService.apply([nonTextUpdate]);
      expect(onNonTextUpdate, true);

      // Perform action
      inputService.performAction(TextInputAction.newline);
      expect(onPerformAction, true);
    });
  });
}
