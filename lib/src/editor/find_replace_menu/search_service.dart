import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/find_replace_menu/search_algorithm.dart';
import 'package:flutter/material.dart';

class SearchStyle {
  SearchStyle({
    this.selectedHighlightColor = const Color(0xFFFFB931),
    this.unselectedHighlightColor = const Color(0x60ECBC5F),
  });

  //selected highlight color is used as background color on the selected found pattern.
  final Color selectedHighlightColor;
  //unselected highlight color is used on every other found pattern which can be selected.
  final Color unselectedHighlightColor;
}

class SearchService {
  SearchService({
    required this.editorState,
    required this.style,
  });

  final EditorState editorState;
  final SearchStyle style;

  //matchedPositions will contain a list of positions of the matched patterns
  //the position here consists of the node and the starting offset of the
  //matched pattern. We will use this to traverse between the matched patterns.
  List<Position> matchedPositions = [];
  SearchAlgorithm searchAlgorithm = BoyerMoore();
  String queriedPattern = '';
  int selectedIndex = 0;

  /// Finds the pattern in editorState.document and stores it in matchedPositions.
  /// Calls the highlightMatch method to highlight the pattern
  /// if it is found.
  void findAndHighlight(String pattern, {bool unhighlight = false}) {
    if (queriedPattern != pattern) {
      //this means we have a new pattern, but before we highlight the new matches,
      //lets unhiglight the old pattern
      findAndHighlight(queriedPattern, unhighlight: true);
      matchedPositions.clear();
      queriedPattern = pattern;
    }

    if (pattern.isEmpty) return;

    //traversing all the nodes
    for (final n in _getAllTextNodes()) {
      //matches list will contain the offsets where the desired word,
      //is found.
      List<int> matches =
          searchAlgorithm.searchMethod(pattern, n.delta!.toPlainText());
      //we will store this list of offsets along with their path,
      //in a list of positions.
      for (int matchedOffset in matches) {
        matchedPositions.add(Position(path: n.path, offset: matchedOffset));
      }
      //finally we will highlight all the mathces.
      _highlightMatches(
        n.path,
        matches,
        pattern.length,
        unhighlight: unhighlight,
      );
    }

    selectedIndex = -1;
  }

  List<Node> _getAllTextNodes() {
    final contents = editorState.document.root.children;

    if (contents.isEmpty) return [];

    final firstNode = contents.firstWhere(
      (el) => el.delta != null,
    );

    final lastNode = contents.lastWhere(
      (el) => el.delta != null,
    );

    //iterate within all the text nodes of the document.
    final nodes = NodeIterator(
      document: editorState.document,
      startNode: firstNode,
      endNode: lastNode,
    ).toList();

    nodes.removeWhere((node) => node.delta == null);

    return nodes;
  }

  /// This method takes in the TextNode's path, matches is a list of offsets,
  /// patternLength is the length of the word which is being searched.
  ///
  /// So for example: path= 1, offset= 10, and patternLength= 5 will mean
  /// that the word is located on path 1 from [1,10] to [1,14]
  void _highlightMatches(
    Path path,
    List<int> matches,
    int patternLength, {
    bool unhighlight = false,
  }) {
    for (final match in matches) {
      final start = Position(path: path, offset: match);
      final end = Position(
        path: start.path,
        offset: start.offset + queriedPattern.length,
      );

      final selection = Selection(start: start, end: end);

      if (unhighlight) {
        editorState.formatDelta(
          selection,
          {AppFlowyRichTextKeys.findBackgroundColor: null},
        );
      } else {
        _applySelectedHighlightColor(selection);
      }
      editorState.undoManager.forgetRecentUndo();
    }
  }

  Future<void> _selectWordAtPosition(
    Position start, [
    bool isNavigating = false,
  ]) async {
    Position end = Position(
      path: start.path,
      offset: start.offset + queriedPattern.length,
    );

    final selection = Selection(start: start, end: end);
    _applySelectedHighlightColor(selection, isSelected: true);

    await editorState.updateSelectionWithReason(
      selection,
      reason: isNavigating
          ? SelectionUpdateReason.searchNavigate
          : SelectionUpdateReason.searchHighlight,
    );
  }

  /// This method takes in a boolean parameter moveUp, if set to true,
  /// the match located above the current selected match is newly selected.
  /// Otherwise the match below the current selected match is newly selected.
  void navigateToMatch({bool moveUp = false}) {
    if (matchedPositions.isEmpty) return;

    //lets change the highlight color to indicate that the current match is
    //not selected.
    if (selectedIndex > -1) {
      final currentMatch = matchedPositions[selectedIndex];
      Position end = Position(
        path: currentMatch.path,
        offset: currentMatch.offset + queriedPattern.length,
      );

      final selection = Selection(start: currentMatch, end: end);
      _applySelectedHighlightColor(selection);
    }

    if (moveUp) {
      selectedIndex =
          selectedIndex - 1 < 0 ? matchedPositions.length - 1 : --selectedIndex;
    } else {
      selectedIndex =
          (selectedIndex + 1) < matchedPositions.length ? ++selectedIndex : 0;
    }
    final match = matchedPositions[selectedIndex];
    _selectWordAtPosition(match, true);
  }

  /// Replaces the current selected word with replaceText.
  /// After replacing the selected word, this method selects the next
  /// matched word if that exists.
  void replaceSelectedWord(String replaceText, [bool fromFirst = false]) {
    if (replaceText.isEmpty ||
        queriedPattern.isEmpty ||
        matchedPositions.isEmpty) {
      return;
    }

    if (selectedIndex == -1) {
      selectedIndex++;
    }

    final position =
        fromFirst ? matchedPositions.first : matchedPositions[selectedIndex];
    _selectWordAtPosition(position);

    //unhighlight the selected word before it is replaced
    final selection = editorState.selection!;
    editorState.formatDelta(
      selection,
      {AppFlowyRichTextKeys.findBackgroundColor: null},
    );
    editorState.undoManager.forgetRecentUndo();

    final textNode = editorState.getNodeAtPath(position.path)!;

    final transaction = editorState.transaction;

    transaction.replaceText(
      textNode,
      position.offset,
      queriedPattern.length,
      replaceText,
    );

    editorState.apply(transaction);

    if (fromFirst) {
      matchedPositions.removeAt(0);
    } else {
      matchedPositions.removeAt(selectedIndex);
      --selectedIndex;

      if (matchedPositions.isNotEmpty) {
        if (selectedIndex == -1) {
          selectedIndex = 0;
        }

        _selectWordAtPosition(matchedPositions[selectedIndex]);
      }
    }
  }

  /// Replaces all the found occurances of pattern with replaceText
  void replaceAllMatches(String replaceText) {
    if (replaceText.isEmpty || queriedPattern.isEmpty) {
      return;
    }
    // We need to create a final variable matchesLength here, because
    // when we replaceSelectedWord we reduce the length of matchedPositions
    // list, this causes the value to shrink dynamically and thus it may
    // result in pretermination.
    final int matchesLength = matchedPositions.length;

    for (int i = 0; i < matchesLength; i++) {
      replaceSelectedWord(replaceText, true);
    }
  }

  void _applySelectedHighlightColor(
    Selection selection, {
    bool isSelected = false,
  }) {
    final color = isSelected
        ? style.selectedHighlightColor.toHex()
        : style.unselectedHighlightColor.toHex();
    editorState.formatDelta(
      selection,
      {AppFlowyRichTextKeys.findBackgroundColor: color},
      false,
    );
  }
}
