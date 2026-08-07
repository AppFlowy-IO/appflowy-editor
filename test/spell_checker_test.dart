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
      final suggestions = await SpellChecker.instance.suggest(
        'hillo',
        maxSuggestions: 5,
      );

      expect(
        suggestions,
        isNotEmpty,
        reason: 'should return suggestions for hillo',
      );
      expect(
        suggestions.contains('hello'),
        true,
        reason: 'hello should be suggested for hillo',
      );
    });

    test('should return empty suggestions for correct words', () async {
      final suggestions = await SpellChecker.instance.suggest(
        'hello',
        maxSuggestions: 5,
      );

      expect(
        suggestions,
        isEmpty,
        reason: 'should not suggest for correctly spelled words',
      );
    });

    test('should exclude common technical nouns', () async {
      // Test that technical terms are not marked as misspelled
      final flutter = await SpellChecker.instance.contains('flutter');
      final appflowy = await SpellChecker.instance.contains('appflowy');
      final dart = await SpellChecker.instance.contains('dart');
      final json = await SpellChecker.instance.contains('json');
      final api = await SpellChecker.instance.contains('api');

      expect(flutter, true, reason: 'flutter should be excluded');
      expect(appflowy, true, reason: 'appflowy should be excluded');
      expect(dart, true, reason: 'dart should be excluded');
      expect(json, true, reason: 'json should be excluded');
      expect(api, true, reason: 'api should be excluded');
    });

    test('should recognize grammatical variations', () async {
      // Test plurals and verb forms
      final running = await SpellChecker.instance.contains('running');
      final jumped = await SpellChecker.instance.contains('jumped');
      final happier = await SpellChecker.instance.contains('happier');
      final quickly = await SpellChecker.instance.contains('quickly');

      expect(
        running,
        true,
        reason: 'running should be recognized as variation of run',
      );
      expect(
        jumped,
        true,
        reason: 'jumped should be recognized as variation of jump',
      );
      expect(
        happier,
        true,
        reason: 'happier should be recognized as variation of happy',
      );
      expect(
        quickly,
        true,
        reason: 'quickly should be recognized as variation of quick',
      );
    });

    test('should exclude words with numbers and special chars', () async {
      final version1 = await SpellChecker.instance.contains('v1.0');
      final appName = await SpellChecker.instance.contains('app-name');
      final testCase = await SpellChecker.instance.contains('test_case');

      expect(
        version1,
        true,
        reason: 'v1.0 should be excluded (contains numbers)',
      );
      expect(
        appName,
        true,
        reason: 'app-name should be excluded (contains hyphen)',
      );
      expect(
        testCase,
        true,
        reason: 'test_case should be excluded (contains underscore)',
      );
    });

    test('should exclude ALL CAPS acronyms', () async {
      final api = await SpellChecker.instance.contains('API');
      final json = await SpellChecker.instance.contains('JSON');
      final html = await SpellChecker.instance.contains('HTML');

      expect(api, true, reason: 'API should be excluded (all caps)');
      expect(json, true, reason: 'JSON should be excluded (all caps)');
      expect(html, true, reason: 'HTML should be excluded (all caps)');
    });

    test('should exclude camelCase and PascalCase identifiers', () async {
      final camelCaseWord = await SpellChecker.instance.contains('camelCase');
      final pascalCaseWord = await SpellChecker.instance.contains('PascalCase');
      final myVariable = await SpellChecker.instance.contains('myVariable');

      expect(camelCaseWord, true, reason: 'camelCase should be excluded');
      expect(pascalCaseWord, true, reason: 'PascalCase should be excluded');
      expect(myVariable, true, reason: 'myVariable should be excluded');
    });

    test(
      'should exclude words starting with capital letter (proper nouns)',
      () async {
        // Any word starting with a capital letter should be excluded
        final johnCapital = await SpellChecker.instance.contains('John');
        final londonCapital = await SpellChecker.instance.contains('London');
        final microsoftCapital = await SpellChecker.instance.contains(
          'Microsoft',
        );
        final appFlowyCapital = await SpellChecker.instance.contains(
          'AppFlowy',
        );
        final praveenCapital = await SpellChecker.instance.contains('Praveen');

        expect(
          johnCapital,
          true,
          reason: 'John should be excluded (starts with capital)',
        );
        expect(
          londonCapital,
          true,
          reason: 'London should be excluded (starts with capital)',
        );
        expect(
          microsoftCapital,
          true,
          reason: 'Microsoft should be excluded (starts with capital)',
        );
        expect(
          appFlowyCapital,
          true,
          reason: 'AppFlowy should be excluded (starts with capital)',
        );
        expect(
          praveenCapital,
          true,
          reason: 'Praveen should be excluded (starts with capital)',
        );

        // But lowercase should still be checked
        // 'john' is actually in the dictionary (slang for toilet)
        final john = await SpellChecker.instance.contains('john');
        final london = await SpellChecker.instance.contains('london');

        expect(
          john,
          true,
          reason: 'john is in the dictionary (slang for toilet)',
        );
        expect(london, true, reason: 'london is in dictionary');
      },
    );
  });
}
