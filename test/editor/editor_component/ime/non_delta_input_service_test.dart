import 'dart:async';

import 'package:appflowy_editor/src/editor/editor_component/service/ime/non_delta_input_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

    test('content insertion configuration is handled', () {
      final completer = Completer<bool>();
      final config = ContentInsertionConfiguration(
        allowedMimeTypes: ['mimeType'],
        onContentInserted: (value) => completer.complete(true),
      );
      final inputService = NonDeltaTextInputService(
        onInsert: (_) async => true,
        onDelete: (_) async => true,
        onReplace: (_) async => true,
        onNonTextUpdate: (_) async => true,
        onPerformAction: (_) async {},
        contentInsertionConfiguration: config,
      );

      inputService.insertContent(
        const KeyboardInsertedContent(
          mimeType: 'mimeType',
          uri: 'uri',
        ),
      );

      expect(completer.future, completion(true));
    });

    test('Delta insertion format', () {
      const insertion = TextEditingDeltaInsertion(
        oldText: '',
        textInserted: 'A',
        insertionOffset: 0,
        selection: TextSelection.collapsed(offset: 1),
        composing: TextRange(start: 0, end: 1),
      );
      final formatInsertion = insertion.format();
      assert(formatInsertion.selection == insertion.selection);
      assert(formatInsertion.composing == insertion.composing);

      const insertion2 = TextEditingDeltaInsertion(
        oldText: ' ',
        textInserted: 'A',
        insertionOffset: 1,
        selection: TextSelection.collapsed(offset: 2),
        composing: TextRange.empty,
      );

      final formatInsertion2 = insertion2.format();
      assert(formatInsertion2.insertionOffset == 0);
      assert(
        formatInsertion2.selection == const TextSelection.collapsed(offset: 1),
      );

      const insertion3 = TextEditingDeltaInsertion(
        oldText: ' A',
        textInserted: 'B',
        insertionOffset: 2,
        selection: TextSelection.collapsed(offset: 3),
        composing: TextRange.empty,
      );

      final formatInsertion3 = insertion3.format();
      assert(formatInsertion3.insertionOffset == 1);

      assert(
        formatInsertion3.selection == const TextSelection.collapsed(offset: 2),
      );
    });
  });

  testWidgets('Delta insertion format with deletion', (tester) async {
    TextEditingValue value =
        const TextEditingValue(selection: TextSelection.collapsed(offset: 0));
    const space = ' ';
    final inputService = NonDeltaTextInputService(
      onInsert: (v) async {
        value = v.apply(value);
        return true;
      },
      onDelete: (v) async {
        value = v.apply(value);
        return true;
      },
      onReplace: (v) async {
        value = v.apply(value);
        return true;
      },
      onNonTextUpdate: (v) async {
        value = v.apply(value);
        return true;
      },
      onPerformAction: (_) async {},
    );
    inputService.attach(value, const TextInputConfiguration());
    await inputService.apply(
      const [
        TextEditingDeltaInsertion(
          oldText: '',
          textInserted: space,
          insertionOffset: 0,
          selection: TextSelection.collapsed(offset: 1),
          composing: TextRange.empty,
        ),
      ],
    );
    assert(value.text == space);
    await inputService.apply(
      [
        TextEditingDeltaDeletion(
          oldText: value.text,
          deletedRange: const TextRange(start: 0, end: 1),
          selection: const TextSelection.collapsed(offset: 0),
          composing: TextRange.empty,
        ),
      ],
    );
    assert(value.text == '');
    await inputService.apply(
      [
        TextEditingDeltaInsertion(
          oldText: value.text,
          textInserted: 'A' * 100,
          insertionOffset: 0,
          selection: const TextSelection.collapsed(offset: 100),
          composing: TextRange.empty,
        ),
      ],
    );
    assert(value.text == 'A' * 100);
    inputService.currentTextEditingValue = value;
    final currentSelection = inputService.currentTextEditingValue?.selection;
    assert(currentSelection?.baseOffset == 100);
  });
}
