import 'dart:collection';

import 'package:appflowy_editor/src/core/location/selection.dart';
import 'package:appflowy_editor/src/core/transform/operation.dart';
import 'package:appflowy_editor/src/core/transform/transaction.dart';
import 'package:appflowy_editor/src/editor_state.dart';
import 'package:appflowy_editor/src/infra/log.dart';

/// A [HistoryItem] contains list of operations committed by users.
/// If a [HistoryItem] is not sealed, operations can be added sequentially.
/// Otherwise, the operations should be added to a new [HistoryItem].
final class HistoryItem extends LinkedListEntry<HistoryItem> {
  final List<Operation> operations = [];
  Selection? beforeSelection;
  Selection? afterSelection;
  bool _sealed = false;
  DateTime _timestamp = DateTime.now();

  HistoryItem();

  /// Seal the history item.
  /// When an item is sealed, no more operations can be added
  /// to the item.
  ///
  /// The caller should create a new [HistoryItem].
  void seal() {
    if (!_sealed) {
      _sealed = true;
      _timestamp = DateTime.now();
    }
  }

  bool get sealed => _sealed;
  DateTime get timestamp => _timestamp;

  void add(Operation op) {
    if (!_sealed) {
      operations.add(op);
    }
  }

  void addAll(Iterable<Operation> iterable) {
    if (!_sealed) {
      operations.addAll(iterable);
    }
  }

  bool get isEmpty => operations.isEmpty;

  /// Create a new [Transaction] by inverting the operations.
  Transaction toTransaction(EditorState state) {
    final builder = Transaction(document: state.document);
    for (var i = operations.length - 1; i >= 0; i--) {
      final operation = operations[i];
      final inverted = operation.invert();
      builder.add(inverted, transform: false);
    }
    builder.afterSelection = beforeSelection;
    builder.beforeSelection = afterSelection;
    return builder;
  }
}

class FixedSizeStack {
  final _list = LinkedList<HistoryItem>();
  final int maxSize;

  FixedSizeStack(this.maxSize);

  void push(HistoryItem stackItem) {
    if (stackItem.isEmpty) {
      return;
    }

    if (_list.length >= maxSize) {
      _list.remove(_list.first);
    }
    _list.add(stackItem);
  }

  HistoryItem? pop() {
    if (_list.isEmpty) {
      return null;
    }
    final last = _list.last;
    _list.remove(last);
    return last;
  }

  void clear() {
    _list.clear();
  }

  HistoryItem? get last => _list.isNotEmpty ? _list.last : null;

  bool get isEmpty => _list.isEmpty;

  bool get isNotEmpty => _list.isNotEmpty;

  int get length => _list.length;
}

class UndoManager {
  final FixedSizeStack undoStack;
  final FixedSizeStack redoStack;
  EditorState? state;

  // Time threshold for merging operations (in milliseconds)
  static const _mergeThreshold = 1000;

  UndoManager([int stackSize = 20])
      : undoStack = FixedSizeStack(stackSize),
        redoStack = FixedSizeStack(stackSize);

  bool get canUndo => undoStack.isNotEmpty;
  bool get canRedo => redoStack.isNotEmpty;

  HistoryItem getUndoHistoryItem() {
    if (undoStack.isEmpty) {
      final item = HistoryItem();
      undoStack.push(item);
      return item;
    }

    final last = undoStack.last;
    if (last == null || last.sealed) {
      final item = HistoryItem();

      // Only clear redo stack when actually adding new operations
      if (last != null &&
          DateTime.now().difference(last.timestamp).inMilliseconds >
              _mergeThreshold) {
        redoStack.clear();
      }

      undoStack.push(item);
      return item;
    }
    return last;
  }

  void undo() {
    AppFlowyEditorLog.editor.debug('undo');
    final s = state;
    if (s == null || !canUndo) {
      return;
    }

    final historyItem = undoStack.pop();
    if (historyItem == null || historyItem.isEmpty) {
      return;
    }

    final transaction = historyItem.toTransaction(s);
    redoStack.push(historyItem);

    s.apply(
      transaction,
      options: const ApplyOptions(
        recordUndo: false,
        recordRedo: false,
      ),
    );
  }

  void redo() {
    AppFlowyEditorLog.editor.debug('redo');
    final s = state;
    if (s == null || !canRedo) {
      return;
    }

    final historyItem = redoStack.pop();
    if (historyItem == null || historyItem.isEmpty) {
      return;
    }

    final transaction = historyItem.toTransaction(s);
    undoStack.push(historyItem);

    s.apply(
      transaction,
      options: const ApplyOptions(
        recordUndo: false,
        recordRedo: false,
      ),
    );
  }

  void forgetRecentUndo() {
    AppFlowyEditorLog.editor.debug('forgetRecentUndo');
    if (state != null && canUndo) {
      undoStack.pop();
    }
  }

  /// Clear both undo and redo stacks
  void clear() {
    undoStack.clear();
    redoStack.clear();
  }
}
