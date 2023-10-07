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
  ValueNotifier<List<Selection>> matchedPositions = ValueNotifier([]);
  ValueNotifier<List<Match>> matchedMatches = ValueNotifier([]);
  SearchAlgorithm searchAlgorithm = DartBuiltIn();
  String targetString = '';
  Pattern queriedPattern = RegExp('');

  bool _regex = false;
  bool get regex => _regex;
  set regex(bool value) {
    _regex = value;
    findAndHighlight(targetString);
  }

  bool _caseSensitive = false;
  bool get caseSensitive => _caseSensitive;
  set caseSensitive(bool value) {
    _caseSensitive = value;
    findAndHighlight(targetString);
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


  Pattern _getPattern(String targetString) {
    if (regex) {
      return RegExp(targetString, caseSensitive: caseSensitive);
    } else {
      return RegExp(RegExp.escape(targetString), caseSensitive: caseSensitive);
    }
  }

  String _getRegexReplaced(String replaceText, Match match) {
    List<String?> groups = match
        .groups(List<int>.generate(match.groupCount + 1, (index) => index));

    String replacedText = replaceText;
    for (int i = 0; i <= match.groupCount; i++) {
      replacedText = replacedText.replaceAll('\\$i', groups[i] ?? '');
    }

    return replacedText;
  }

  void dispose() {
    matchedPositions.dispose();
    matchedMatches.dispose();
    currentSelectedIndex.dispose();
  }


  // Public entry method for _findAndHighlight, do necessary checks
  // and clear previous highlights before calling the private method
  void findAndHighlight(String target, {bool unHighlight = false}) {
    Pattern pattern = _getPattern(target);

    if (queriedPattern != pattern) {
      // this means we have a new pattern, but before we highlight the new matches,
      // lets unHiglight the old pattern
      _findAndHighlight(queriedPattern, unHighlight: true);
      matchedPositions.value.clear();
      matchedMatches.value.clear();
      queriedPattern = pattern;
      targetString = target;
    }

    if (target.isEmpty) return;

    _findAndHighlight(pattern, unHighlight: unHighlight);
  }

  /// Finds the pattern in editorState.document and stores it in matchedPositions.
  /// Calls the highlightMatch method to highlight the pattern
  /// if it is found.
  void _findAndHighlight(
    Pattern pattern, {
    bool unHighlight = false,
  }) {
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

  List<Selection> _getMatchedPositions({
    required Pattern pattern,
    Iterable<Node> nodes = const [],
  }) {
    final List<Selection> result = [];
    for (final node in nodes) {
      if (node.delta != null) {
        final text = node.delta!.toPlainText();
        matchedMatches.value = searchAlgorithm.searchMethod(pattern, text).toList();
        // we will store this list of offsets along with their path,
        // in a list of positions.
        for (Match match in matchedMatches.value) {
          result.add(
            Selection(
              start: Position(path: node.path, offset: match.start),
              end: Position(path: node.path, offset: match.end),
            ),
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
    Pattern pattern,
  ) {
    final selection = matchedPositions.value[selectedIndex];

    // https://github.com/google/flutter.widgets/issues/151
    // there's a bug in the scrollable_positioned_list package
    // we can't scroll to the index without animation.
    // so we just scroll the position if the index is the first or the last.
    final length = matchedPositions.value.length - 1;
    if (_prevSelectedIndex != selectedIndex &&
        ((_prevSelectedIndex == length && selectedIndex == 0) ||
            (_prevSelectedIndex == 0 && selectedIndex == length))) {
      editorState.scrollService?.jumpTo(selection.start.path.first);
    }

    editorState.updateSelectionWithReason(
      selection,
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
        queriedPattern.toString().isEmpty ||
        matchedPositions.value.isEmpty) {
      return;
    }

    final selection = matchedPositions.value[selectedIndex];
    final node = editorState.getNodeAtPath(selection.start.path)!;
    final match = matchedMatches.value[selectedIndex];

    final String replaced;
    if (regex) {
      replaced = _getRegexReplaced(replaceText, match);
    } else {
      replaced = replaceText;
    }

    final transaction = editorState.transaction
      ..replaceText(
        node,
        selection.start.offset,
        selection.length,
        replaced,
      );
    await editorState.apply(transaction);

    matchedPositions.value.clear();
    _findAndHighlight(queriedPattern);
  }

  /// Replaces all the found occurances of pattern with replaceText
  void replaceAllMatches(String replaceText) {
    if (replaceText.isEmpty ||
        queriedPattern.toString().isEmpty ||
        matchedPositions.value.isEmpty) {
      return;
    }

    // _highlightAllMatches(queriedPattern.length, unHighlight: true);
    final reversedMatches = matchedMatches.value.reversed.toList();
    for (final (index, position) in matchedPositions.value.reversed.indexed) {
      final node = editorState.getNodeAtPath(position.start.path)!;
      final String replaced;
      if (regex) {
        replaced = _getRegexReplaced(replaceText, reversedMatches[index]);
      } else {
        replaced = replaceText;
      }

      final transaction = editorState.transaction
        ..replaceText(
          node,
          position.startIndex,
          position.length,
          replaced,
        );

      editorState.apply(transaction);
    }
    matchedPositions.value.clear();
  }
}
