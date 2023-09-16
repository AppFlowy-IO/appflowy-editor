import 'dart:math' as math;

/// If someone wants to use their own implementation for the search algorithm
/// They can do so by extending this abstract class and overriding its
/// `searchMethod(String pattern, String text)`, here `pattern` is the sequence of
/// characters that are to be searched within the `text`.
abstract class SearchAlgorithm {
  List<Range> searchMethod(Pattern pattern, String text);
}

class Range {
  Range({
    required this.start,
    required this.end,
  });

  final int start;
  final int end;
}

class BoyerMoore extends SearchAlgorithm {
  //This is a standard algorithm used for searching patterns in long text samples
  //It is more efficient than brute force searching because it is able to skip
  //characters that will never possibly match with required pattern.
  @override
  List<Range> searchMethod(Pattern pattern, String text) {
    if (pattern is String) {
      return _searchMethod(pattern, text);
    } else if (pattern is RegExp) {
      return _rSearchMethod(pattern, text);
    } else {
      throw TypeError();
    }
  }

  List<Range> _searchMethod(String pattern, String text) {
    int m = pattern.length;
    int n = text.length;

    Map<String, int> badchar = {};
    List<Range> matches = [];

    _badCharHeuristic(pattern, m, badchar);

    int s = 0;

    while (s <= (n - m)) {
      int j = m - 1;

      while (j >= 0 && pattern[j] == text[s + j]) {
        j--;
      }

      //if pattern is present at current shift, the index will become -1
      if (j < 0) {
        matches.add(Range(start: s, end: s + m));
        s += (s + m < n) ? m - (badchar[text[s + m]] ?? -1) : 1;
      } else {
        s += math.max(1, j - (badchar[text[s + j]] ?? -1));
      }
    }

    return matches;
  }

  void _badCharHeuristic(String pat, int size, Map<String, int> badchar) {
    badchar.clear();

    // Fill the actual value of last occurrence of a character
    // (indices of table are characters and values are index of occurrence)
    for (int i = 0; i < size; i++) {
      String ch = pat[i];
      badchar[ch] = i;
    }
  }

  List<Range> _rSearchMethod(RegExp pattern, String text) {
    int n = text.length;
    List<Range> matches = [];

    int s = 0;

    while (s <= n - 1) {
      var match = pattern.firstMatch(text.substring(s));

      if (match != null) {
        int j = match.start - 1;

        while (j >= 0 && pattern.hasMatch(text.substring(s + j, s + j + 1))) {
          j--;
        }

        if (j < 0) {
          // Complete pattern match found, add the starting index to matches
          matches.add(Range(start: s, end: s + match.end - match.start));
          // Move the search position to the character after the match
          s += match.start + 1;
        } else {
          // Calculate the maximum shift based on the bad character
          var badChar = text.substring(s + j, s + j + 1);
          var shift = math.max(
            1,
            j - (match.start - (pattern.firstMatch(badChar)?.start ?? -1)),
          );
          s += shift;
        }
      } else {
        // No match found, move to the next character
        s++;
      }
    }

    return matches;
  }
}
