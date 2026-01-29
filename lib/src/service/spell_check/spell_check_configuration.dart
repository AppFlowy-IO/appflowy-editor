/// Configuration for spell checking behavior
class AppFlowySpellCheckConfiguration {
  const AppFlowySpellCheckConfiguration({
    this.minWordLength = 3,
    this.checkOnlyCompletedWords = true,
    this.debounceDelay = Duration.zero,
    this.excludePatterns = const [],
    this.customDictionary = const {},
  });

  /// Minimum word length to check for spelling errors.
  /// Words shorter than this will not be spell-checked.
  /// Default: 3 characters
  final int minWordLength;

  /// If true, only check words after whitespace/punctuation (completed words).
  /// If false, check words as you type (immediate feedback).
  ///
  /// Example:
  /// - true: "bas|" -> no redline, "bas " -> show redline
  /// - false: "bas|" -> show redline immediately
  ///
  /// Default: false (immediate checking)
  final bool checkOnlyCompletedWords;

  /// Delay before showing spell check underline.
  /// Useful to avoid flickering while typing.
  ///
  /// Example: Duration(milliseconds: 300) waits 300ms before showing redline
  /// Default: Duration.zero (immediate)
  final Duration debounceDelay;

  /// List of regex patterns to exclude from spell checking.
  ///
  /// Example:
  /// - RegExp(r'^#\w+') excludes hashtags (#flutter)
  /// - RegExp(r'@\w+') excludes mentions (@username)
  /// - RegExp(r'\d+') excludes numbers
  final List<RegExp> excludePatterns;

  /// Custom dictionary to use instead of the bundled dictionary.
  ///
  /// - If empty, uses the bundled dictionary (10,000 words).
  /// - If provided, completely replaces the bundled dictionary with your words.
  ///
  /// Example: {'hello', 'world', 'flutter', 'dart', 'appflowy'}
  final Set<String> customDictionary;

  AppFlowySpellCheckConfiguration copyWith({
    int? minWordLength,
    bool? checkOnlyCompletedWords,
    Duration? debounceDelay,
    List<RegExp>? excludePatterns,
    Set<String>? customDictionary,
  }) {
    return AppFlowySpellCheckConfiguration(
      minWordLength: minWordLength ?? this.minWordLength,
      checkOnlyCompletedWords:
          checkOnlyCompletedWords ?? this.checkOnlyCompletedWords,
      debounceDelay: debounceDelay ?? this.debounceDelay,
      excludePatterns: excludePatterns ?? this.excludePatterns,
      customDictionary: customDictionary ?? this.customDictionary,
    );
  }
}
