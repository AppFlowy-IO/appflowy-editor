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
  void findAndHighlight(String pattern, {bool unHighlight = false}) {
    if (queriedPattern != pattern) {
      //this means we have a new pattern, but before we highlight the new matches,
      //lets unhiglight the old pattern
      findAndHighlight(queriedPattern, unHighlight: true);
      matchedPositions.clear();
      queriedPattern = pattern;
    }

    if (pattern.isEmpty) return;

    //traversing all the nodes
    for (final n in _getAllNodes()) {
      //matches list will contain the offsets where the desired word,
      //is found.
      List<int> matches = searchAlgorithm
          .searchMethod(pattern, n.delta!.toPlainText())
          .map((e) => e.start)
          .toList();
      //we will store this list of offsets along with their path,
      //in a list of positions.
      for (int matchedOffset in matches) {
        matchedPositions.add(Position(path: n.path, offset: matchedOffset));
      }
    }
    //finally we will highlight all the mathces.
    _highlightAllMatches(pattern.length, unHighlight: unHighlight);

    selectedIndex = -1;
  }

  List<Node> _getAllNodes() {
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

  void _highlightAllMatches(
    int patternLength, {
    bool unHighlight = false,
  }) {
    for (final match in matchedPositions) {
      final start = Position(path: match.path, offset: match.offset);
      final end = Position(
        path: match.path,
        offset: match.offset + patternLength,
      );

      final selection = Selection(start: start, end: end);
      if (!unHighlight) {
        editorState.selection = selection;
      }
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
  void replaceSelectedWord(String replaceText) {
    if (replaceText.isEmpty ||
        queriedPattern.isEmpty ||
        matchedPositions.isEmpty) {
      return;
    }

    if (selectedIndex == -1) {
      selectedIndex++;
    }

    final position = matchedPositions[selectedIndex];
    _selectWordAtPosition(position);

    //unHighlight the selected word before it is replaced
    final selection = editorState.selection!;
    editorState.formatDelta(
      selection,
      {AppFlowyRichTextKeys.findBackgroundColor: null},
    );
    editorState.undoManager.forgetRecentUndo();

    final textNode = editorState.getNodeAtPath(position.path)!;
    final transaction = editorState.transaction
      ..replaceText(
        textNode,
        position.offset,
        queriedPattern.length,
        replaceText,
      );

    editorState.apply(transaction);

    matchedPositions.clear();
    findAndHighlight(queriedPattern);
  }

  /// Replaces all the found occurances of pattern with replaceText
  void replaceAllMatches(String replaceText) {
    if (replaceText.isEmpty ||
        queriedPattern.isEmpty ||
        matchedPositions.isEmpty) {
      return;
    }

    _highlightAllMatches(queriedPattern.length, unHighlight: true);
    for (final match in matchedPositions.reversed.toList()) {
      final node = editorState.getNodeAtPath(match.path)!;

      final transaction = editorState.transaction
        ..replaceText(
          node,
          match.offset,
          queriedPattern.length,
          replaceText,
        );

      editorState.apply(transaction);
    }
    matchedPositions.clear();
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
      withUpdateSelection: false,
    );
  }
}
