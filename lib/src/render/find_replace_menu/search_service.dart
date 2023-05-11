import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/render/find_replace_menu/search_algorithm.dart';

class SearchService {
  SearchService({
    required this.editorState,
  });

  final EditorState editorState;
  //matchedPositions will contain a list of positions of the matched patterns
  //the position here consists of the node and the starting offset of the
  //matched pattern. We will use this to traverse between the matched patterns.
  List<Position> matchedPositions = [];
  BayerMooreAlgorithm searchAlgorithm = BayerMooreAlgorithm();
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
        List<int> matches =
            searchAlgorithm.boyerMooreSearch(pattern, n.toPlainText());
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
  void navigateToMatch({bool moveUp = false}) {
    if (matchedPositions.isEmpty) return;
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

  /// Replaces the current selected word with replaceText.
  /// After replacing the selected word, this method selects the next
  /// matched word if that exists.
  void replaceSelectedWord(String replaceText) {
    if (replaceText.isEmpty ||
        queriedPattern.isEmpty ||
        matchedPositions.isEmpty) {
      return;
    }

    final matchedPosition = matchedPositions[selectedIndex];
    _selectWordAtPosition(matchedPosition);

    //unhighlight the selected word before it is replaced
    formatHighlight(
      editorState,
      editorState.editorStyle.highlightColorHex!,
    );
    editorState.undoManager.forgetRecentUndo();

    final textNode = editorState.service.selectionService.currentSelectedNodes
        .whereType<TextNode>()
        .first;

    final transaction = editorState.transaction;

    transaction.replaceText(
      textNode,
      matchedPosition.offset,
      queriedPattern.length,
      replaceText,
    );

    editorState.apply(transaction);

    matchedPositions.removeAt(selectedIndex);
    navigateToMatch(moveUp: false);
  }

  /// Replaces all the found occurances of pattern with replaceText
  void replaceAllMatches(String replaceText) {
    if (replaceText.isEmpty || queriedPattern.isEmpty) {
      return;
    }
    //we need to create a final variable matchesLength here, because
    //when we replaceSelectedWord we reduce the length of matchedPositions
    //list, this causes the value to shrink dynamically and thus it may
    //result in pretermination.
    final int matchesLength = matchedPositions.length;

    for (int i = 0; i < matchesLength; i++) {
      replaceSelectedWord(replaceText);
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
      editorState.undoManager.forgetRecentUndo();
    }
  }

  void _selectWordAtPosition(Position start) {
    Position end = Position(
      path: start.path,
      offset: start.offset + queriedPattern.length,
    );

    editorState.updateCursorSelection(Selection(start: start, end: end));
  }
}
