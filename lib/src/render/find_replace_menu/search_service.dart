import 'package:appflowy_editor/appflowy_editor.dart';
import 'dart:math' as math;

class SearchService {
  SearchService({
    required this.editorState,
  });

  final EditorState editorState;
  Map<Node, List<int>> nodeMatchMap = {};

  /// Finds the pattern in editorState.document and stores it in a
  /// map. Calls the highlightMatch method to highlight the pattern
  /// if it is found.
  void findAndHighlight(String pattern) {
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
        //we will store this list of offsets in a hashmap where each node,
        //will be the respective key and its matches will be its value.
        nodeMatchMap[n] = matches;
        //finally we will highlight all the mathces.
        highlightMatches(n.path, matches, pattern.length);
      }
    }
  }

  /// This method takes in the TextNode's path, matches is a list of offsets,
  ///  patternLength is the length of the word which is being searched.
  ///
  /// So for example: path= 1, offset= 10, and patternLength= 5 will mean
  /// that the word is located on path 1 from [1,10] to [1,14]
  void highlightMatches(Path path, List<int> matches, int patternLength) {
    for (final match in matches) {
      Position start = Position(path: path, offset: match);
      Position end = Position(path: path, offset: match + patternLength);

      //we select the matched word and hide the toolbar.
      editorState.updateCursorSelection(Selection(start: start, end: end));

      formatHighlight(
        editorState,
        editorState.editorStyle.highlightColorHex!,
      );
    }
  }

  void unHighlight(String pattern) {
    findAndHighlight(pattern);
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
