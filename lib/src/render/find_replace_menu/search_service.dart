import 'package:appflowy_editor/appflowy_editor.dart';
import 'dart:math' as math;

class SearchService {
  SearchService({
    required this.editorState,
  });

  final EditorState editorState;
  //matchedPositions will contain a list of positions of the matched patterns
  //the position here consists of the node and the starting offset of the
  //matched pattern. We will use this to traverse between the matched patterns.
  List<Position> matchedPositions = [];
  String queriedPattern = '';
  int selectedIndex = 0;

  /// Finds the pattern in editorState.document and stores it in matchedPositions.
  /// Calls the highlightMatch method to highlight the pattern
  /// if it is found.
  void findAndHighlight(String pattern) {
    if (queriedPattern != pattern) {
      //this means we have a new pattern, but before we highlight the new matches,
      //lets unhiglight the old pattern
      unHighlight(queriedPattern);
      queriedPattern = pattern;
    }

    final contents = editorState.document.root.children;

    if (contents.isEmpty || pattern.isEmpty) return;

    final firstNode = contents.firstWhere(
      (element) => element is TextNode,
    );

    final lastNode = contents.lastWhere(
      (element) => element is TextNode,
    );

    //iterate within all the text nodes of the document.
    final nodes = NodeIterator(
      document: editorState.document,
      startNode: firstNode,
      endNode: lastNode,
    ).toList();

    //traversing all the nodes
    for (final n in nodes) {
      if (n is TextNode) {
        //matches list will contain the offsets where the desired word,
        //is found.
        List<int> matches = _boyerMooreSearch(pattern, n.toPlainText());
        //we will store this list of offsets along with their path,
        //in a list of positions.
        for (int matchedOffset in matches) {
          matchedPositions.add(Position(path: n.path, offset: matchedOffset));
        }
        //finally we will highlight all the mathces.
        _highlightMatches(n.path, matches, pattern.length);
      }
    }

    selectedIndex = matchedPositions.length - 1;
  }

  void unHighlight(String pattern) {
    findAndHighlight(pattern);
  }

  /// This method takes in a boolean parameter moveUp, if set to true,
  /// the match located above the current selected match is newly selected.
  /// Otherwise the match below the current selected match is newly selected.
  void navigateToMatch(bool moveUp) {
    if (moveUp) {
      selectedIndex =
          selectedIndex - 1 < 0 ? matchedPositions.length - 1 : --selectedIndex;

      final match = matchedPositions[selectedIndex];
      _selectWordAtPosition(match);
      //FIXME: selecting a word should scroll editor automatically.
    } else {
      selectedIndex =
          (selectedIndex + 1) < matchedPositions.length ? ++selectedIndex : 0;

      final match = matchedPositions[selectedIndex];
      _selectWordAtPosition(match);
      //FIXME: selecting a word should scroll editor automatically.
    }
  }

  /// This method takes in the TextNode's path, matches is a list of offsets,
  /// patternLength is the length of the word which is being searched.
  ///
  /// So for example: path= 1, offset= 10, and patternLength= 5 will mean
  /// that the word is located on path 1 from [1,10] to [1,14]
  void _highlightMatches(Path path, List<int> matches, int patternLength) {
    for (final match in matches) {
      Position start = Position(path: path, offset: match);
      _selectWordAtPosition(start);

      formatHighlight(
        editorState,
        editorState.editorStyle.highlightColorHex!,
      );
    }
  }

  void _selectWordAtPosition(Position start) {
    Position end = Position(
      path: start.path,
      offset: start.offset + queriedPattern.length,
    );

    editorState.updateCursorSelection(Selection(start: start, end: end));
  }

  //this is a standard algorithm used for searching patterns in long text samples
  List<int> _boyerMooreSearch(String pattern, String text) {
    int m = pattern.length;
    int n = text.length;

    Map<String, int> badchar = {};
    List<int> matches = [];

    _badCharHeuristic(pattern, m, badchar);

    int s = 0;

    while (s <= (n - m)) {
      int j = m - 1;

      while (j >= 0 && pattern[j] == text[s + j]) {
        j--;
      }

      //if pattern is present at current shift, the index will become -1
      if (j < 0) {
        matches.add(s);
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
