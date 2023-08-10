import 'package:appflowy_editor/src/editor/editor_component/service/ime/text_diff.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Diff', () {
    test('Diff()', () {
      final diff = Diff(0, 'elcome', 'welcome');

      const str = 'Diff[0, "elcome", "welcome"]';
      expect(diff.toString(), str);
    });

    test('getDiff', () {
      const oldText = 'elcome';
      const newText = 'Welcome';

      final diff = getDiff(oldText, newText, 0);
      expect(diff.toString(), 'Diff[0, "", "W"]');
    });

    test('getTextEditingDeltas insertion', () {
      const oldValue = TextEditingValue(text: 'elcome');
      const newValue = TextEditingValue(text: 'Welcome');

      final deltas = getTextEditingDeltas(oldValue, newValue);
      expect(deltas.length, 1);
      expect(deltas.first is TextEditingDeltaInsertion, true);
    });

    test('getTextEditingDeltas insertion & deletion', () {
      const oldValue = TextEditingValue(text: 'elcome');
      const newValue = TextEditingValue(text: 'Welcom');

      final deltas = getTextEditingDeltas(oldValue, newValue);
      expect(deltas.length, 1);
      expect(deltas.first is TextEditingDeltaReplacement, true);
    });

    test('getTextEditingDeltas null oldValue', () {
      const newValue = TextEditingValue(text: 'Welcom');

      final deltas = getTextEditingDeltas(null, newValue);
      expect(deltas.length, 1);
      expect(deltas.first is TextEditingDeltaNonTextUpdate, true);
    });

    test('getTextEditingDeltas no change', () {
      const oldValue = TextEditingValue(text: 'Welcome');
      const newValue = TextEditingValue(text: 'Welcome');

      final deltas = getTextEditingDeltas(oldValue, newValue);
      expect(deltas.length, 1);
      expect(deltas.first is TextEditingDeltaNonTextUpdate, true);
    });
  });
}
