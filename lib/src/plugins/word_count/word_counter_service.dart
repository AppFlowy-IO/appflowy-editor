import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:appflowy_editor/appflowy_editor.dart';

const _emptyCounters = Counters();
final _wordRegex = RegExp(r"\w+(\'\w+)?");

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
  WordCountService({required this.editorState});

  final EditorState editorState;

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

    _streamSubscription =
        editorState.transactionStream.listen(_recountOnTransactionUpdate);
    editorState.selectionNotifier.addListener(_recountOnSelectionUpdate);
  }

  /// Stops the Word Counter and resets the counts.
  ///
  void stop() {
    if (!isRunning) {
      return;
    }

    _streamSubscription?.cancel();
    _documentCounters = const Counters();
    _selectionCounters = const Counters();
    isRunning = false;

    notifyListeners();
  }

  @override
  void dispose() {
    editorState.selectionNotifier.removeListener(_recountOnSelectionUpdate);
    _streamSubscription?.cancel();
    super.dispose();
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

    int wordCount = 0;
    int charCount = 0;

    final nodes = editorState.getSelectedNodes();
    for (final node in nodes) {
      final counters = _countersFromNode(node);
      wordCount += counters.wordCount;
      charCount += counters.charCount;
    }

    final newCounters = Counters(
      wordCount: wordCount,
      charCount: charCount,
    );

    if (newCounters != selectionCounters) {
      _selectionCounters = newCounters;
      notifyListeners();
    }
  }

  void _recountOnTransactionUpdate(
    (TransactionTime time, Transaction t) event,
  ) {
    if (event.$1 != TransactionTime.after) {
      return;
    }

    final counters = _countersFromNode(editorState.document.root);

    // If there is no update, no need to notify listeners
    if (counters.wordCount != documentCounters.wordCount ||
        counters.charCount != documentCounters.charCount) {
      if (counters != documentCounters) {
        _documentCounters = counters;
        notifyListeners();
      }
    }
  }

  Counters _countersFromNode(Node node) {
    int wCount = 0;
    int cCount = 0;

    final plain = _toPlainText(node);
    wCount += _wordsInString(plain);
    cCount += plain.runes.length;

    for (final child in node.children) {
      final counters = _countersFromNode(child);
      wCount += counters.wordCount;
      cCount += counters.charCount;
    }

    return Counters(wordCount: wCount, charCount: cCount);
  }

  int _wordsInString(String delta) => _wordRegex.allMatches(delta).length;

  String _toPlainText(Node node) => node.delta?.toPlainText() ?? '';
}
