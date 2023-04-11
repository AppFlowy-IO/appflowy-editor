import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/service/default_text_operations/format_rich_text_style.dart';
import 'dart:math' as math;

class SearchService {
  SearchService({
    required this.editorState,
  });

  final EditorState editorState;
  Map<Node, List<int>> nodeMatchMap = {};

  void findAndHighlight(String pattern) {
    final contents = editorState.document.root.children;

    if (contents.isEmpty || pattern.isEmpty) return;

    final firstNode = contents.firstWhere(
      (element) => element is TextNode,
    );

    final lastNode = contents.lastWhere(
      (element) => element is TextNode,
    );

    final nodes = NodeIterator(
      document: editorState.document,
      startNode: firstNode,
      endNode: lastNode,
    ).toList();

    for (var n in nodes) {
      if (n is TextNode) {
        //we will try to find the pattern using bayer moore search.
        List<int> matches = boyerMooreSearch(pattern, n.toPlainText());
        nodeMatchMap[n] = matches;
        highlightMatches(n.path, matches, pattern.length);
      }
    }
  }

  void highlightMatches(Path path, List<int> matches, int patternLength) {
    for (var match in matches) {
      Position start = Position(path: path, offset: match);
      Position end = Position(path: path, offset: match + patternLength);

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

  List<int> boyerMooreSearch(String pattern, String text) {
    int m = pattern.length;
    int n = text.length;

    Map<String, int> badchar = {};
    List<int> matches = [];

    badCharHeuristic(pattern, m, badchar);

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

  void badCharHeuristic(String pat, int size, Map<String, int> badchar) {
    // Initialize all occurrences as -1
    badchar.clear();

    // Fill the actual value of last occurrence
    // of a character (indices of table are characters and values are index of occurrence)
    for (int i = 0; i < size; i++) {
      String ch = pat[i];
      badchar[ch] = i;
    }
  }
}
