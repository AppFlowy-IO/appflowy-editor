import 'dart:async';

import 'package:appflowy_editor/src/infra/log.dart';
import 'package:flutter/services.dart';

/// A very small, local spell checker using the word list at
/// `assets/dictionary/words.txt`.
///
/// - Loads the dictionary lazily on first use.
/// - Provides simple suggestions using Levenshtein distance with
///   light pre-filtering for speed.
class SpellChecker {
  SpellChecker._internal();

  static final SpellChecker instance = SpellChecker._internal();

  Set<String> _words = {};
  Future<void>? _loading;

  // Indexed words by first character and length for faster lookup in suggest()
  Map<String, Map<int, List<String>>> _wordIndex = {};

  // Common suffixes and prefixes that indicate grammatical forms
  static final _commonSuffixes = [
    's',
    'es',
    'ed',
    'ing',
    'er',
    'est',
    'ly',
    'tion',
    'sion',
    'ness',
    'ment',
    'ful',
    'less',
    'able',
    'ible',
    'al',
    'ial',
    'ic',
    'ical',
    'ous',
    'ious',
    'y',
    'ive',
    'ize',
    'ise',
  ];

  static final _commonPrefixes = [
    'un',
    're',
    'in',
    'im',
    'il',
    'ir',
    'dis',
    'en',
    'em',
    'non',
    'over',
    'mis',
    'sub',
    'pre',
    'inter',
    'fore',
    'de',
    'trans',
    'super',
    'semi',
    'anti',
    'mid',
    'under',
  ];

  // Common nouns to exclude from spell checking
  static final _commonNouns = {
    'appflowy',
    'flutter',
    'dart',
    'widget',
    'app',
    'api',
    'ui',
    'ux',
    'html',
    'css',
    'json',
    'xml',
    'svg',
    'png',
    'jpg',
    'gif',
    'pdf',
    'http',
    'https',
    'url',
    'uri',
    'sql',
    'db',
    'id',
    'uuid',
    'github',
    'git',
    'npm',
    'webpack',
    'babel',
    'eslint',
    'prettier',
    'typescript',
    'javascript',
    'python',
    'java',
    'kotlin',
    'swift',
    'ios',
    'android',
    'macos',
    'windows',
    'linux',
    'ubuntu',
    'docker',
    'kubernetes',
    'aws',
    'gcp',
    'azure',
    'firebase',
    'react',
    'vue',
    'angular',
    'node',
    'deno',
    'bun',
    'mongodb',
    'postgresql',
    'mysql',
    'redis',
    'graphql',
    'rest',
  };

  // Frequently used regex patterns
  static final _numbersAndSpecialCharsRegex = RegExp('[0-9_-]');
  static final _camelCaseRegex = RegExp('^[a-z]+[A-Z]');
  static final _pascalCaseRegex = RegExp('^[A-Z][a-z]+[A-Z]');

  /// Check if a word should be excluded from spell checking
  bool _shouldExcludeWord(String word) {
    final lc = word.toLowerCase();

    // Exclude very short words (likely to be abbreviations or common)
    if (lc.length <= 2) {
      AppFlowyEditorLog.editor.debug('  → Excluded: too short (≤2 chars)');

      return true;
    }

    // Exclude words that start with a capital letter (proper nouns, names, etc.)
    if (word.isNotEmpty &&
        word[0] == word[0].toUpperCase() &&
        word[0] != word[0].toLowerCase()) {
      AppFlowyEditorLog.editor
          .debug('  → Excluded: starts with capital letter (proper noun)');

      return true;
    }

    // Exclude common nouns (case-insensitive)
    if (_commonNouns.contains(lc)) {
      AppFlowyEditorLog.editor
          .debug('  → Excluded: common technical term/noun');

      return true;
    }

    // Check if word contains numbers or special characters (likely technical term)
    if (_numbersAndSpecialCharsRegex.hasMatch(lc)) {
      AppFlowyEditorLog.editor
          .debug('  → Excluded: contains numbers/hyphens/underscores');

      return true;
    }

    // Check if word is all caps (likely acronym) with 2+ chars
    if (word == word.toUpperCase() && word.length >= 2) {
      AppFlowyEditorLog.editor.debug('  → Excluded: ALL CAPS (acronym)');

      return true;
    }

    // Check if word is PascalCase or camelCase (likely a code identifier)
    if (_camelCaseRegex.hasMatch(word) || _pascalCaseRegex.hasMatch(word)) {
      AppFlowyEditorLog.editor.debug('  → Excluded: camelCase/PascalCase');

      return true;
    }

    return false;
  }

  /// Check if a word is a valid grammatical variation of a dictionary word
  bool _isGrammaticalVariation(String word) {
    final lc = word.toLowerCase();

    // Check if the word is a common variation with suffix
    for (final suffix in _commonSuffixes) {
      if (lc.endsWith(suffix) && lc.length > suffix.length + 2) {
        final base = lc.substring(0, lc.length - suffix.length);

        // Check base word
        if (_words.contains(base)) return true;

        // Check with 'e' added back (e.g., "hoping" -> "hope")
        if (_words.contains('${base}e')) return true;

        // For words ending in 'i' with -er/-est suffix, check with 'y'
        // (e.g., "happier" -> base is "happi" -> check "happy")
        if ((suffix == 'er' || suffix == 'est') && base.endsWith('i')) {
          final baseWithY = '${base.substring(0, base.length - 1)}y';
          if (_words.contains(baseWithY)) return true;
        }

        // For words ending in consonant doubling (e.g., "running" -> "run")
        if (base.length >= 2 &&
            base[base.length - 1] == base[base.length - 2]) {
          final singleConsonant = base.substring(0, base.length - 1);
          if (_words.contains(singleConsonant)) return true;
        }
      }
    }

    // Check if the word is a common variation with prefix
    for (final prefix in _commonPrefixes) {
      if (lc.startsWith(prefix) && lc.length > prefix.length + 2) {
        final base = lc.substring(prefix.length);
        if (_words.contains(base)) return true;
      }
    }

    return false;
  }

  Future<void> _ensureLoaded() {
    if (_words.isNotEmpty) return Future.value();
    if (_loading != null) return _loading!;

    _loading = rootBundle
        .loadString('packages/appflowy_editor/assets/dictionary/words.txt')
        .then((content) {
      final words = content.split(RegExp(r'\s+'));
      _words = words
          .map((w) => w.trim().toLowerCase())
          .where((w) => w.isNotEmpty && !w.startsWith(RegExp('[0-9&]')))
          .toSet();

      // Build index for faster lookup in suggest()
      _buildWordIndex();
    }).catchError((err) {
      AppFlowyEditorLog.editor
          .error('Failed to load spell check dictionary: $err');
      _words = <String>{};
    });

    return _loading!;
  }

  /// Build a `Map<firstChar, Map<length, List<words>>>` for faster candidate filtering
  void _buildWordIndex() {
    _wordIndex = {};
    for (final word in _words) {
      if (word.isEmpty) continue;
      final firstChar = word[0];
      final len = word.length;

      _wordIndex.putIfAbsent(firstChar, () => {});
      _wordIndex[firstChar]!.putIfAbsent(len, () => []);
      _wordIndex[firstChar]![len]!.add(word);
    }
  }

  /// Returns true if the [word] exists in the dictionary or should be excluded.
  Future<bool> contains(String word) async {
    await _ensureLoaded();

    // First check if word should be excluded from spell checking (technical terms, etc.)
    if (_shouldExcludeWord(word)) {
      AppFlowyEditorLog.editor
          .debug('SpellChecker: "$word" excluded by _shouldExcludeWord');

      return true;
    }

    final lc = word.toLowerCase();

    // Check if word exists in dictionary
    if (_words.contains(lc)) {
      AppFlowyEditorLog.editor
          .debug('SpellChecker: "$word" found in dictionary');

      return true;
    }

    // Check if it's a grammatical variation of a dictionary word
    if (_isGrammaticalVariation(word)) {
      AppFlowyEditorLog.editor
          .debug('SpellChecker: "$word" is grammatical variation');

      return true;
    }

    AppFlowyEditorLog.editor.debug(
      'SpellChecker: "$word" NOT FOUND - will be marked as misspelled',
    );

    return false;
  }

  /// Suggests up to [maxSuggestions] corrections for [word].
  ///
  /// If the word is found in the dictionary, an empty list is returned.
  Future<List<String>> suggest(String word, {int maxSuggestions = 5}) async {
    await _ensureLoaded();
    final input = word.trim().toLowerCase();
    if (input.isEmpty) return [];

    // Don't suggest for words in dictionary
    if (_words.contains(input)) return [];

    // Don't suggest for excluded words (technical terms)
    if (_shouldExcludeWord(input)) return [];

    // Don't suggest for grammatical variations
    if (_isGrammaticalVariation(input)) return [];

    // Use the word index to get candidates by first character and similar lengths
    final first = input[0];
    final inputLen = input.length;
    final candidates = <String>[];

    final charIndex = _wordIndex[first];
    if (charIndex != null) {
      // Get words with length within ±2 of input length
      for (int len = inputLen - 2; len <= inputLen + 2; len++) {
        final wordsOfLen = charIndex[len];
        if (wordsOfLen != null) {
          candidates.addAll(wordsOfLen);
        }
      }
    }

    final scanList = candidates.isNotEmpty ? candidates : _words.toList();

    final scored = <_Candidate>[];
    for (final c in scanList) {
      final d = _levenshtein(input, c);
      scored.add(_Candidate(c, d));
    }

    scored.sort((a, b) {
      final cmp = a.distance.compareTo(b.distance);
      if (cmp != 0) return cmp;

      return a.word.compareTo(b.word);
    });

    final suggestions = scored.take(maxSuggestions).map((e) => e.word).toList();

    return suggestions;
  }

  // Simple Levenshtein distance.
  static int _levenshtein(String s, String t) {
    final n = s.length;
    final m = t.length;
    if (n == 0) return m;
    if (m == 0) return n;
    final v0 = List<int>.filled(m + 1, 0);
    final v1 = List<int>.filled(m + 1, 0);

    for (var i = 0; i <= m; i++) {
      v0[i] = i;
    }

    for (var i = 0; i < n; i++) {
      v1[0] = i + 1;
      for (var j = 0; j < m; j++) {
        final cost = s[i] == t[j] ? 0 : 1;
        v1[j + 1] = [
          v1[j] + 1, // insertion
          v0[j + 1] + 1, // deletion
          v0[j] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
      for (var j = 0; j <= m; j++) {
        v0[j] = v1[j];
      }
    }

    return v1[m];
  }
}

class _Candidate {
  final String word;
  final int distance;

  _Candidate(
    this.word,
    this.distance,
  );
}
