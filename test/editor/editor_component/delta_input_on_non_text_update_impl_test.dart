import 'package:appflowy_editor/src/editor/editor_component/service/ime/delta_input_impl.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('onNonTextUpdate', () {
    // Pro-performa test
    test('call', () async {
      await onNonTextUpdate(
        const TextEditingDeltaNonTextUpdate(
          oldText: 'AppFlowy',
          selection: TextSelection(baseOffset: 0, extentOffset: 3),
          composing: TextRange(start: 0, end: 3),
        ),
      );
    });
  });
}
