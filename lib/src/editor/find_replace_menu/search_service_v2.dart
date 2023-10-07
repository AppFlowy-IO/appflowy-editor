import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/find_replace_menu/search_algorithm.dart';
import 'package:flutter/foundation.dart';

const selectionExtraInfoDisableToolbar = 'selectionExtraInfoDisableToolbar';

class SearchServiceV2 {
  SearchServiceV2({
    required this.editorState,
  });

  final EditorState editorState;

  //matchedPositions.value will contain a list of positions of the matched patterns
  //the position here consists of the node and the starting offset of the
  //matched pattern. We will use this to traverse between the matched patterns.
  ValueNotifier<List<Position>> matchedPositions = ValueNotifier([]);
  SearchAlgorithm searchAlgorithm = BoyerMoore();
  String queriedPattern = '';
  bool _caseSensitive = false;
  bool get caseSensitive => _caseSensitive;
  set caseSensitive(bool value) {
    _caseSensitive = value;
    findAndHighlight(queriedPattern);
  }

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;
  set selectedIndex(int index) {
    _prevSelectedIndex = _selectedIndex;
    _selectedIndex = matchedPositions.value.isEmpty
        ? -1
        : index.clamp(0, matchedPositions.value.length - 1);
    currentSelectedIndex.value = _selectedIndex;
  }

  // only used for scrolling to the first or the last match.
  int _prevSelectedIndex = 0;

  ValueNotifier<int> currentSelectedIndex = ValueNotifier(0);

  void dispose() {
    matchedPositions.dispose();
    currentSelectedIndex.dispose();
  }

  void findAndHighlight(
    String pattern, {
    bool unHighlight = false,
  }) {
    if (queriedPattern != pattern) {
      matchedPositions.value.clear();
      queriedPattern = pattern;
    }

    if (pattern.isEmpty) return;

    matchedPositions.value = _getMatchedPositions(
      pattern: pattern,
      nodes: editorState.document.root.children,
    );

    if (matchedPositions.value.isNotEmpty) {
      selectedIndex = selectedIndex;
      _highlightCurrentMatch(
        pattern,
      );
    } else {
      editorState.updateSelectionWithReason(null);
    }
  }

  List<Position> _getMatchedPositions({
    required String pattern,
    Iterable<Node> nodes = const [],
  }) {
    final List<Position> result = [];
    for (final node in nodes) {
      if (node.delta != null) {
        final text = node.delta!.toPlainText();
        List<int> matches = searchAlgorithm
            .searchMethod(
              caseSensitive ? pattern : pattern.toLowerCase(),
              caseSensitive ? text : text.toLowerCase(),
            )
            .map((e) => e.start)
            .toList();
        // we will store this list of offsets along with their path,
        // in a list of positions.
        for (int matchedOffset in matches) {
          result.add(
            Position(path: node.path, offset: matchedOffset),
          );
        }
      }
      result.addAll(
        _getMatchedPositions(pattern: pattern, nodes: node.children),
      );
    }
    return result;
  }

  void _highlightCurrentMatch(
    String pattern,
  ) {
    final start = matchedPositions.value[selectedIndex];
    final end = Position(
      path: start.path,
      offset: start.offset + pattern.length,
    );

    // https://github.com/google/flutter.widgets/issues/151
    // there's a bug in the scrollable_positioned_list package
    // we can't scroll to the index without animation.
    // so we just scroll the position if the index is the first or the last.
    final length = matchedPositions.value.length - 1;
    if (_prevSelectedIndex != selectedIndex &&
        ((_prevSelectedIndex == length && selectedIndex == 0) ||
            (_prevSelectedIndex == 0 && selectedIndex == length))) {
      editorState.scrollService?.jumpTo(start.path.first);
    }

    editorState.updateSelectionWithReason(
      Selection(start: start, end: end),
      extraInfo: {
        selectionExtraInfoDisableToolbar: true,
      },
    );
  }

  /// This method takes in a boolean parameter moveUp, if set to true,
  /// the match located above the current selected match is newly selected.
  /// Otherwise the match below the current selected match is newly selected.
  void navigateToMatch({bool moveUp = false}) {
    if (matchedPositions.value.isEmpty) return;

    if (moveUp) {
      selectedIndex = selectedIndex <= 0
          ? matchedPositions.value.length - 1
          : selectedIndex - 1;
    } else {
      selectedIndex = selectedIndex >= matchedPositions.value.length - 1
          ? 0
          : selectedIndex + 1;
    }

    _highlightCurrentMatch(queriedPattern);
  }

  /// Replaces the current selected word with replaceText.
  /// After replacing the selected word, this method selects the next
  /// matched word if that exists.
  Future<void> replaceSelectedWord(String replaceText) async {
    if (replaceText.isEmpty ||
        queriedPattern.isEmpty ||
        matchedPositions.value.isEmpty) {
      return;
    }

    final start = matchedPositions.value[selectedIndex];
    final node = editorState.getNodeAtPath(start.path)!;
    final transaction = editorState.transaction
      ..replaceText(
        node,
        start.offset,
        queriedPattern.length,
        replaceText,
      );
    await editorState.apply(transaction);

    matchedPositions.value.clear();
    findAndHighlight(queriedPattern);
  }

  /// Replaces all the found occurances of pattern with replaceText
  void replaceAllMatches(String replaceText) {
    if (replaceText.isEmpty ||
        queriedPattern.isEmpty ||
        matchedPositions.value.isEmpty) {
      return;
    }

    // _highlightAllMatches(queriedPattern.length, unHighlight: true);
    for (final match in matchedPositions.value.reversed.toList()) {
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
    matchedPositions.value.clear();
  }
}
