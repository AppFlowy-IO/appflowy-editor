import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:appflowy_editor/appflowy_editor.dart';

final _wordRegex = RegExp(r"\w+(\'\w+)?");

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

  int _wordCount = 0;

  /// Number of words in the [Document].
  ///
  int get wordCount => _wordCount;

  int _charCount = 0;

  /// Number of characters with spaces in the [Document].
  ///
  int get charCount => _charCount;

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

    final counters = _countersFromNode(editorState.document.root);
    _wordCount = counters.$1;
    _charCount = counters.$2;

    notifyListeners();

    _streamSubscription =
        editorState.transactionStream.listen(_recountOnTransactionUpdate);
  }

  /// Stops the Word Counter and resets the counts.
  ///
  void stop() {
    if (!isRunning) {
      return;
    }

    _streamSubscription?.cancel();
    _wordCount = 0;
    _charCount = 0;
    isRunning = false;

    notifyListeners();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  void _recountOnTransactionUpdate(
    (TransactionTime time, Transaction t) event,
  ) {
    if (event.$1 != TransactionTime.after) {
      return;
    }

    final counters = _countersFromNode(editorState.document.root);

    // If there is no update, no need to notify listeners
    if (counters.$1 != wordCount || counters.$2 != charCount) {
      _wordCount = counters.$1;
      _charCount = counters.$2;

      notifyListeners();
    }
  }

  (int, int) _countersFromNode(Node node) {
    int wCount = 0;
    int cCount = 0;

    final plain = _toPlainText(node);
    wCount += _wordsInString(plain);
    cCount += plain.runes.length;

    for (final child in node.children) {
      final values = _countersFromNode(child);
      wCount += values.$1;
      cCount += values.$2;
    }

    return (wCount, cCount);
  }

  int _wordsInString(String delta) => _wordRegex.allMatches(delta).length;

  String _toPlainText(Node node) => node.delta?.toPlainText() ?? '';
}
