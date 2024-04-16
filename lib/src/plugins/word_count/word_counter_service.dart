import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:appflowy_editor/appflowy_editor.dart';

const _emptyCounters = Counters();

/// There are some nuances to the word regex.
///
/// Previousle we used \w which captures words, but it only captures
/// [a-zA-Z0-9_]. This is not enough for many languages.
///
/// Take for example our previous regex: `\w+(\'\w+)?`
///
/// A more generic approach is simply just matching all non-whitespace
/// characters, and then count the number of matches. That can be done simply
/// with `\S+`.
///
/// This will also account for eg. accents. It is a trivial approach, but it beats
/// writing up a super complex regex to cover all edge cases.
///
final _wordRegex = RegExp(r"\S+");

/// Used by the [WordCountService] to contain
/// count statistics in eg. a [Document] or in
/// the current [Selection].
///
class Counters {
  const Counters({
    int wordCount = 0,
    int charCount = 0,
  })  : _wordCount = wordCount,
        _charCount = charCount;

  final int _wordCount;
  int get wordCount => _wordCount;

  final int _charCount;
  int get charCount => _charCount;

  @override
  bool operator ==(other) =>
      other is Counters &&
      other.wordCount == wordCount &&
      other.charCount == charCount;

  @override
  int get hashCode => Object.hash(wordCount, charCount);
}

/// A Word Counter service that runs based on the
/// changes and updates to an [EditorState].
///
/// Due to this service relying on listening to transactions
/// in the [Document] and iterating the complete [Document]
/// to count the words and characters, this can be a potential
/// slow and cumbersome task.
///
/// To start being notified about updates, run the [register]
/// method, this will add a listener to the [Transaction] updates
/// of the [EditorState], and do an initial run-through to populate
/// the counter stats.
///
class WordCountService with ChangeNotifier {
  WordCountService({
    required this.editorState,
    this.debounceDuration = const Duration(milliseconds: 300),
  });

  final EditorState editorState;

  /// The time to wait before input stops, to recalculate
  /// word and character count.
  ///
  /// This duration is used for debouncing both document
  /// and selection changes.
  ///
  /// If 0 no debouncing will occur
  ///
  final Duration debounceDuration;

  Timer? _selectionTimer;
  Timer? _documentTimer;

  /// Number of words and characters in the [Document].
  ///
  Counters get documentCounters => _documentCounters;
  Counters _documentCounters = const Counters();

  /// Number of words and characters in the [Selection].
  ///
  Counters get selectionCounters => _selectionCounters;
  Counters _selectionCounters = const Counters();

  /// Signifies whether the service is currently running
  /// or not. The service can be stopped/started as needed
  /// for performance.
  ///
  bool isRunning = false;

  StreamSubscription<(TransactionTime, Transaction)>? _streamSubscription;

  /// This method can be used to get the word and character
  /// count of the [Document] of the [EditorState].
  ///
  /// This does not modify the state of the counters
  /// of the service. If the service is running ([isRunning])
  /// it will return the [documentCounters]. Otherwise it
  /// will compute it on demand.
  ///
  Counters getDocumentCounters() =>
      isRunning ? documentCounters : _countersFromNode();

  /// This method can be used to get the word and character
  /// count of the current [Selection] of the [EditorState].
  ///
  /// This does not modify the state of the counters
  /// of the service. If the service is running ([isRunning])
  /// it will return the [selectionCounters]. Otherwise it
  /// will compute it on demand.
  ///
  Counters getSelectionCounters() =>
      isRunning ? selectionCounters : _countersFromSelection();

  /// Registers the Word Counter and starts notifying
  /// about updates to word and character count.
  ///
  void register() {
    if (isRunning) {
      return;
    }

    isRunning = true;
    _documentCounters = _countersFromNode(editorState.document.root);
    if (editorState.selection?.isCollapsed ?? false) {
      _recountOnSelectionUpdate();
    }

    if (documentCounters != _emptyCounters ||
        selectionCounters != _emptyCounters) {
      notifyListeners();
    }

    _streamSubscription = editorState.transactionStream.listen(_onDocUpdate);
    editorState.selectionNotifier.addListener(_onSelUpdate);
  }

  /// Stops the Word Counter and resets the counts.
  ///
  void stop() {
    if (!isRunning) {
      return;
    }

    _documentTimer?.cancel();
    _documentTimer = null;
    _selectionTimer?.cancel();
    _selectionTimer = null;
    _streamSubscription?.cancel();
    _documentCounters = const Counters();
    _selectionCounters = const Counters();
    isRunning = false;

    notifyListeners();
  }

  @override
  void dispose() {
    editorState.selectionNotifier.removeListener(_onSelUpdate);
    _streamSubscription?.cancel();
    _documentTimer?.cancel();
    _selectionTimer?.cancel();
    _documentTimer = null;
    _selectionTimer = null;
    super.dispose();
  }

  void _onSelUpdate() {
    if (debounceDuration.inMilliseconds == 0) {
      return _recountOnSelectionUpdate();
    }

    if (_selectionTimer?.isActive ?? false) {
      _selectionTimer!.cancel();
    }

    _selectionTimer = Timer(debounceDuration, _recountOnSelectionUpdate);
  }

  void _recountOnSelectionUpdate() {
    // If collapsed or null, reset count
    if (editorState.selection?.isCollapsed ?? true) {
      if (_selectionCounters == _emptyCounters) {
        return;
      }

      _selectionCounters = const Counters();
      return notifyListeners();
    }

    final counters = _countersFromSelection();

    if (counters != selectionCounters) {
      _selectionCounters = counters;
      notifyListeners();
    }
  }

  Counters _countersFromSelection() {
    int wordCount = 0;
    int charCount = 0;

    final nodes = editorState.getSelectedNodes();
    for (final node in nodes) {
      final counters = _countersFromNode(node);
      wordCount += counters.wordCount;
      charCount += counters.charCount;
    }

    return Counters(wordCount: wordCount, charCount: charCount);
  }

  void _onDocUpdate((TransactionTime time, Transaction t) event) {
    if (debounceDuration.inMilliseconds == 0) {
      return _recountOnTransactionUpdate(event.$1);
    }

    if (_documentTimer?.isActive ?? false) {
      _documentTimer!.cancel();
    }

    _documentTimer = Timer(
      debounceDuration,
      () => _recountOnTransactionUpdate(event.$1),
    );
  }

  void _recountOnTransactionUpdate(TransactionTime time) {
    if (time != TransactionTime.after) {
      return;
    }

    final counters = _countersFromNode();

    // If there is no update, no need to notify listeners
    if (counters.wordCount != documentCounters.wordCount ||
        counters.charCount != documentCounters.charCount) {
      if (counters != documentCounters) {
        _documentCounters = counters;
        notifyListeners();
      }
    }
  }

  /// Returns [Counters] for a specific [Node].
  ///
  /// If [Node] is null, takes the root [Node] of
  /// the [Document].
  ///
  Counters _countersFromNode([Node? node]) {
    final n = node ?? editorState.document.root;

    int wCount = 0;
    int cCount = 0;

    final plain = _toPlainText(n);
    wCount += _wordsInString(plain);
    cCount += plain.runes.length;

    for (final child in n.children) {
      final counters = _countersFromNode(child);
      wCount += counters.wordCount;
      cCount += counters.charCount;
    }

    return Counters(wordCount: wCount, charCount: cCount);
  }

  int _wordsInString(String delta) => _wordRegex.allMatches(delta).length;

  String _toPlainText(Node node) => node.delta?.toPlainText() ?? '';
}
