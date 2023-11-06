import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/find_replace_menu/search_algorithm.dart';
import 'package:flutter/foundation.dart';

const selectionExtraInfoDisableToolbar = 'selectionExtraInfoDisableToolbar';

class SearchServiceV3 {
  SearchServiceV3({
    required this.editorState,
  });

  final EditorState editorState;

  //matchWrappers.value will contain a list of matchWrappers of the matched patterns
  //the position here consists of the match and the node path of
  //matched pattern. We will use this to traverse between the matched patterns.
  ValueNotifier<List<MatchWrapper>> matchWrappers = ValueNotifier([]);
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
    _selectedIndex = matchWrappers.value.isEmpty
        ? -1
        : index.clamp(0, matchWrappers.value.length - 1);
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
    matchWrappers.dispose();
    currentSelectedIndex.dispose();
  }

  // Public entry method for _findAndHighlight, do necessary checks
  // and clear previous highlights before calling the private method
  String findAndHighlight(String target, {bool unHighlight = false}) {
    Pattern pattern;

    try {
      pattern = _getPattern(target);
    } on FormatException {
      matchWrappers.value.clear();
      return 'Regex';
    }

    if (queriedPattern != pattern) {
      // this means we have a new pattern, but before we highlight the new matches,
      // lets unhighlight the old pattern
      _findAndHighlight(queriedPattern, unHighlight: true);
      matchWrappers.value.clear();
      queriedPattern = pattern;
      targetString = target;
    }

    if (target.isEmpty) return 'Empty';

    _findAndHighlight(pattern, unHighlight: unHighlight);

    return '';
  }

  /// Finds the pattern in editorState.document and stores it in matchedPositions.
  /// Calls the highlightMatch method to highlight the pattern
  /// if it is found.
  void _findAndHighlight(
    Pattern pattern, {
    bool unHighlight = false,
  }) {
    matchWrappers.value = _getMatchWrappers(
      pattern: pattern,
      nodes: editorState.document.root.children,
    );

    if (matchWrappers.value.isNotEmpty) {
      selectedIndex = selectedIndex;
      _highlightCurrentMatch(
        pattern,
      );
    } else {
      editorState.updateSelectionWithReason(null);
    }
  }

  List<MatchWrapper> _getMatchWrappers({
    required Pattern pattern,
    Iterable<Node> nodes = const [],
  }) {
    final List<MatchWrapper> result = [];
    for (final node in nodes) {
      if (node.delta != null) {
        final text = node.delta!.toPlainText();
        final matches = searchAlgorithm.searchMethod(pattern, text);
        // we will store this list of offsets along with their path,
        // in a list of positions.
        for (Match match in matches) {
          result.add(
            MatchWrapper(match, node.path),
          );
        }
      }
      result.addAll(
        _getMatchWrappers(pattern: pattern, nodes: node.children),
      );
    }
    return result;
  }

  void _highlightCurrentMatch(
    Pattern pattern,
  ) {
    final selection = matchWrappers.value[selectedIndex].selection;

    // https://github.com/google/flutter.widgets/issues/151
    // there's a bug in the scrollable_positioned_list package
    // we can't scroll to the index without animation.
    // so we just scroll the position if the index is the first or the last.
    final length = matchWrappers.value.length - 1;
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
    if (matchWrappers.value.isEmpty) return;

    if (moveUp) {
      selectedIndex = selectedIndex <= 0
          ? matchWrappers.value.length - 1
          : selectedIndex - 1;
    } else {
      selectedIndex = selectedIndex >= matchWrappers.value.length - 1
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
        matchWrappers.value.isEmpty) {
      return;
    }

    final matchWrap = matchWrappers.value[selectedIndex];
    final node = editorState.getNodeAtPath(matchWrap.path)!;

    final String replaced;
    if (regex) {
      replaced = _getRegexReplaced(replaceText, matchWrap.match);
    } else {
      replaced = replaceText;
    }

    final transaction = editorState.transaction
      ..replaceText(
        node,
        matchWrap.selection.start.offset,
        matchWrap.selection.length,
        replaced,
      );
    await editorState.apply(transaction);

    matchWrappers.value.clear();
    _findAndHighlight(queriedPattern);
  }

  /// Replaces all the found occurrences of pattern with replaceText
  void replaceAllMatches(String replaceText) {
    if (replaceText.isEmpty ||
        queriedPattern.isEmpty ||
        matchWrappers.value.isEmpty) {
      return;
    }

    // _highlightAllMatches(queriedPattern.length, unHighlight: true);
    for (final matchWrap in matchWrappers.value.reversed) {
      final node = editorState.getNodeAtPath(matchWrap.path)!;
      final String replaced;
      if (regex) {
        replaced = _getRegexReplaced(replaceText, matchWrap.match);
      } else {
        replaced = replaceText;
      }

      final transaction = editorState.transaction
        ..replaceText(
          node,
          matchWrap.selection.startIndex,
          matchWrap.selection.length,
          replaced,
        );

      editorState.apply(transaction);
    }
    matchWrappers.value.clear();
  }
}

class MatchWrapper {
  MatchWrapper(this.match, this.path);

  final Match match;
  final Path path;

  Selection get selection => Selection(
        start: Position(path: path, offset: match.start),
        end: Position(path: path, offset: match.end),
      );
}

extension on Pattern {
  bool get isEmpty {
    if (this is String) {
      return (this as String).isEmpty;
    } else if (this is RegExp) {
      return (this as RegExp).pattern.isEmpty;
    } else {
      return toString().isEmpty;
    }
  }
}
