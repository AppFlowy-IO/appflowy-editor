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
  List<Selection> matchedPositions = [];
  SearchAlgorithm searchAlgorithm = Mixture();
  Pattern queriedPattern = RegExp('');
  int selectedIndex = 0;
  bool isRegex = false;
  bool caseSensitive = true;

  Pattern _getPattern(String targetString) {
    if (isRegex) {
      return RegExp(targetString, caseSensitive: caseSensitive);
    } else if (!caseSensitive) {
      return RegExp(RegExp.escape(targetString), caseSensitive: caseSensitive);
    } else {
      return targetString;
    }
  }

  String Function(Match match) _getReplacer(String replaceString) {
    if (isRegex) {
      return (match) {
        List<String?> groups = match
            .groups(List<int>.generate(match.groupCount + 1, (index) => index));

        String replacedString = replaceString;
        for (int i = 0; i <= match.groupCount; i++) {
          replacedString = replacedString.replaceAll('\\$i', groups[i] ?? '');
        }

        return replacedString;
      };
    } else {
      return (match) => replaceString;
    }
  }

  /// Finds the pattern in editorState.document and stores it in matchedPositions.
  /// Calls the highlightMatch method to highlight the pattern
  /// if it is found.
  void findAndHighlight(String targetString, {bool unhighlight = false}) {
    Pattern pattern = _getPattern(targetString);

    if (queriedPattern != pattern) {
      // this means we have a new pattern, but before we highlight the new matches,
      // lets unhiglight the old pattern
      rFindAndHighlight(queriedPattern, unhighlight: true);
      matchedPositions.clear();
      queriedPattern = pattern;
    }

    if (targetString.isEmpty) return;

    rFindAndHighlight(pattern, unhighlight: unhighlight);
  }

  void rFindAndHighlight(Pattern pattern, {bool unhighlight = false}) {
    //traversing all the nodes
    for (final n in _getAllNodes()) {
      //matches list will contain the offsets where the desired word,
      //is found.
      List<Range> matches =
          searchAlgorithm.searchMethod(pattern, n.delta!.toPlainText());
      //we will store this list of offsets along with their path,
      //in a list of positions.
      for (Range matchedOffset in matches) {
        matchedPositions.add(
          Selection(
            start: Position(path: n.path, offset: matchedOffset.start),
            end: Position(path: n.path, offset: matchedOffset.end),
          ),
        );
      }
    }
    //finally we will highlight all the mathces.
    _highlightAllMatches(unhighlight: unhighlight);

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

  void _highlightAllMatches({
    bool unhighlight = false,
  }) {
    for (final selection in matchedPositions) {
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
    Selection selection, [
    bool isNavigating = false,
  ]) async {
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
      final selection = matchedPositions[selectedIndex];

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
        queriedPattern.toString().isEmpty ||
        matchedPositions.isEmpty) {
      return;
    }

    if (selectedIndex == -1) {
      selectedIndex++;
    }

    final position = matchedPositions[selectedIndex];
    _selectWordAtPosition(position);

    //unhighlight the selected word before it is replaced
    final selection = editorState.selection!;
    editorState.formatDelta(
      selection,
      {AppFlowyRichTextKeys.findBackgroundColor: null},
    );
    editorState.undoManager.forgetRecentUndo();
    final replacer = _getReplacer(replaceText);

    final node = editorState.getNodeAtPath(position.start.path)!;
    final text = node.delta!.toPlainText();
    final String replacement;
    if (isRegex || !caseSensitive) {
      final firstMatch = (queriedPattern as RegExp)
          .firstMatch(text.substring(position.startIndex, position.endIndex));
      replacement = replacer.call(firstMatch!);
    } else {
      replacement = replaceText;
    }

    final textNode = editorState.getNodeAtPath(position.start.path)!;
    final transaction = editorState.transaction
      ..replaceText(
        textNode,
        position.startIndex,
        position.length,
        replacement,
      );

    editorState.apply(transaction);

    matchedPositions.clear();
    rFindAndHighlight(queriedPattern);
  }

  /// Replaces all the found occurances of pattern with replaceText
  void replaceAllMatches(String replaceText) {
    if (replaceText.isEmpty ||
        queriedPattern.toString().isEmpty ||
        matchedPositions.isEmpty) {
      return;
    }

    _highlightAllMatches(unhighlight: true);
    final replacer = _getReplacer(replaceText);

    for (final match in matchedPositions.reversed.toList()) {
      final node = editorState.getNodeAtPath(match.start.path)!;
      final text = node.delta!.toPlainText();
      final String replacement;
      if (isRegex || !caseSensitive) {
        final firstMatch = (queriedPattern as RegExp)
            .firstMatch(text.substring(match.startIndex, match.endIndex));
        replacement = replacer.call(firstMatch!);
      } else {
        replacement = replaceText;
      }

      final transaction = editorState.transaction
        ..replaceText(
          node,
          match.startIndex,
          match.length,
          replacement,
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
      false,
    );
  }
}
