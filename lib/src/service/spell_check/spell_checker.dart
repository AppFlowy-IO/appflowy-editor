import 'dart:async';

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

  Set<String>? _words;
  Future<void>? _loading;

  // Common suffixes and prefixes that indicate grammatical forms
  static final _commonSuffixes = [
    's', 'es', 'ed', 'ing', 'er', 'est', 'ly', 'tion', 'sion', 
    'ness', 'ment', 'ful', 'less', 'able', 'ible', 'al', 'ial',
    'ic', 'ical', 'ous', 'ious', 'y', 'ive', 'ize', 'ise',
  ];

  static final _commonPrefixes = [
    'un', 're', 'in', 'im', 'il', 'ir', 'dis', 'en', 'em',
    'non', 'over', 'mis', 'sub', 'pre', 'inter', 'fore',
    'de', 'trans', 'super', 'semi', 'anti', 'mid', 'under',
  ];

  // Common nouns to exclude from spell checking
  static final _commonNouns = {
    'appflowy', 'flutter', 'dart', 'widget', 'app', 'api', 'ui', 'ux',
    'html', 'css', 'json', 'xml', 'svg', 'png', 'jpg', 'gif', 'pdf',
    'http', 'https', 'url', 'uri', 'sql', 'db', 'id', 'uuid',
  };

  /// Check if a word should be excluded from spell checking
  bool _shouldExcludeWord(String word) {
    final lc = word.toLowerCase();
    
    // Exclude very short words (likely to be abbreviations or common)
    if (lc.length <= 2) return true;
    
    // Exclude common nouns
    if (_commonNouns.contains(lc)) return true;
    
    // Check if the word is a common variation with suffix/prefix
    // Try removing common suffixes and checking if the base word exists
    for (final suffix in _commonSuffixes) {
      if (lc.endsWith(suffix) && lc.length > suffix.length + 2) {
        final base = lc.substring(0, lc.length - suffix.length);
        if (_words?.contains(base) ?? false) return true;
        // Also check with 'e' added back (e.g., "hoping" -> "hope")
        if (_words?.contains('$base' 'e') ?? false) return true;
      }
    }
    
    // Check if the word is a common variation with prefix
    for (final prefix in _commonPrefixes) {
      if (lc.startsWith(prefix) && lc.length > prefix.length + 2) {
        final base = lc.substring(prefix.length);
        if (_words?.contains(base) ?? false) return true;
      }
    }
    
    // Check if word contains numbers or special characters (likely technical term)
    if (RegExp(r'[0-9_\-]').hasMatch(lc)) return true;
    
    // Check if word is all caps (likely acronym)
    if (word == word.toUpperCase() && word.length >= 2) return true;
    
    return false;
  }

  Future<void> _ensureLoaded() {
    if (_words != null) return Future.value();
    if (_loading != null) return _loading!;

    _loading = rootBundle
        .loadString('packages/appflowy_editor/assets/dictionary/words.txt')
        .then((content) {
      final lines = content.split(RegExp(r'\r?\n'));
      _words = lines
          .map((l) => l.trim().toLowerCase())
          .where((l) => l.isNotEmpty && !l.startsWith(RegExp(r'[0-9&]')))
          .toSet();
      print('SpellChecker: Loaded ${_words!.length} words');
    }).catchError((err) {
      print('SpellChecker: Failed to load dictionary: $err');
      _words = <String>{};
    });
    return _loading!;
  }

  /// Returns true if the [word] exists in the dictionary or should be excluded.
  Future<bool> contains(String word) async {
    await _ensureLoaded();
    
    // Check if word should be excluded from spell checking
    if (_shouldExcludeWord(word)) {
      print('SpellChecker: Word "$word" excluded from checking');
      return true;
    }
    
    final lc = word.toLowerCase();
    final result = _words!.contains(lc);
    print('SpellChecker: Word "$word" ${result ? "FOUND" : "NOT FOUND"} in dictionary');
    return result;
  }

  /// Suggests up to [maxSuggestions] corrections for [word].
  ///
  /// If the word is found in the dictionary, an empty list is returned.
  Future<List<String>> suggest(String word, {int maxSuggestions = 5}) async {
    await _ensureLoaded();
    final input = word.trim().toLowerCase();
    if (input.isEmpty) return [];
    if (_words!.contains(input)) {
      print('SpellChecker: No suggestions needed for "$word" (found in dictionary)');
      return [];
    }
    
    // Don't suggest for excluded words
    if (_shouldExcludeWord(input)) {
      print('SpellChecker: No suggestions for "$word" (excluded)');
      return [];
    }

    print('SpellChecker: Generating suggestions for "$word"...');

    // Pre-filter candidates by first character and length difference to speed up.
    final first = input[0];
    final candidates = <String>[];
    for (final w in _words!) {
      if (w.isEmpty) continue;
      if (w[0] != first) continue;
      if ((w.length - input.length).abs() > 2) continue;
      candidates.add(w);
      if (candidates.length >= 200) break; // limit prefilter size
    }

    final scanList = candidates.isNotEmpty ? candidates : _words!.toList();

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
    print('SpellChecker: Found ${suggestions.length} suggestions for "$word": $suggestions');
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

    for (var i = 0; i <= m; i++) v0[i] = i;

    for (var i = 0; i < n; i++) {
      v1[0] = i + 1;
      for (var j = 0; j < m; j++) {
        final cost = s[i] == t[j] ? 0 : 1;
        v1[j + 1] = [
          v1[j] + 1, // insertion
          v0[j + 1] + 1, // deletion
          v0[j] + cost // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
      for (var j = 0; j <= m; j++) v0[j] = v1[j];
    }

    return v1[m];
  }
}

class _Candidate {
  final String word;
  final int distance;
  _Candidate(this.word, this.distance);
}
