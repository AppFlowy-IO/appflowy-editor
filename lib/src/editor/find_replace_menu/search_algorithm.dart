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
    } else {
      throw UnimplementedError();
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
}

class DartBuiltin extends SearchAlgorithm {
  @override
  List<Range> searchMethod(Pattern pattern, String text) {
    return pattern
        .allMatches(text)
        .map((e) => Range(start: e.start, end: e.end))
        .toList();
  }
}

class Mixture extends SearchAlgorithm {
  @override
  List<Range> searchMethod(Pattern pattern, String text) {
    if (pattern is String) {
      return BoyerMoore().searchMethod(pattern, text);
    } else {
      return DartBuiltin().searchMethod(pattern, text);
    }
  }
}
