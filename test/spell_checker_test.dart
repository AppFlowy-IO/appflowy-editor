import 'package:appflowy_editor/src/service/spell_check/spell_checker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SpellChecker', () {
    test('should load dictionary and find common words', () async {
      // Test common English words
      final hello = await SpellChecker.instance.contains('hello');
      final world = await SpellChecker.instance.contains('world');
      final more = await SpellChecker.instance.contains('more');
      final come = await SpellChecker.instance.contains('come');

      expect(hello, true, reason: 'hello should be in dictionary');
      expect(world, true, reason: 'world should be in dictionary');
      expect(more, true, reason: 'more should be in dictionary');
      expect(come, true, reason: 'come should be in dictionary');
    });

    test('should not find misspelled words', () async {
      final hillo = await SpellChecker.instance.contains('hillo');
      final damb = await SpellChecker.instance.contains('damb');
      final wrld = await SpellChecker.instance.contains('wrld');

      expect(hillo, false, reason: 'hillo should not be in dictionary');
      expect(damb, false, reason: 'damb should not be in dictionary');
      expect(wrld, false, reason: 'wrld should not be in dictionary');
    });

    test('should provide suggestions for misspelled words', () async {
      final suggestions = await SpellChecker.instance.suggest('hillo', maxSuggestions: 5);

      expect(suggestions, isNotEmpty, reason: 'should return suggestions for hillo');
      expect(suggestions.contains('hello'), true, reason: 'hello should be suggested for hillo');
    });

    test('should return empty suggestions for correct words', () async {
      final suggestions = await SpellChecker.instance.suggest('hello', maxSuggestions: 5);

      expect(suggestions, isEmpty, reason: 'should not suggest for correctly spelled words');
    });
  });
}
