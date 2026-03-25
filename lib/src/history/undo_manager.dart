import 'dart:collection';

import 'package:appflowy_editor/src/core/location/selection.dart';
import 'package:appflowy_editor/src/core/transform/operation.dart';
import 'package:appflowy_editor/src/core/transform/transaction.dart';
import 'package:appflowy_editor/src/editor_state.dart';
import 'package:appflowy_editor/src/infra/log.dart';

/// Describes the origin of a transaction for undo/redo recording.
enum TransactionSource {
  /// A normal user edit. Records to undo stack and clears redo stack
  /// when branching (new edit after undo).
  userEdit,

  /// An undo operation. Records to redo stack.
  undo,

  /// A redo operation. Records to undo stack without clearing redo stack.
  redo,

  /// Not recorded in either stack (e.g. remote or in-memory updates).
  none,
}

/// A [HistoryItem] contains list of operations committed by users.
/// If a [HistoryItem] is not sealed, operations can be added sequentially.
/// Otherwise, the operations should be added to a new [HistoryItem].
final class HistoryItem extends LinkedListEntry<HistoryItem> {
  final List<Operation> operations = [];
  Selection? beforeSelection;
  Selection? afterSelection;
  bool _sealed = false;

  HistoryItem();

  /// Seal the history item.
  /// When an item is sealed, no more operations can be added
  /// to the item.
  ///
  /// The caller should create a new [HistoryItem].
  void seal() {
    _sealed = true;
  }

  bool get sealed => _sealed;

  void add(Operation op) {
    operations.add(op);
  }

  void addAll(Iterable<Operation> iterable) {
    operations.addAll(iterable);
  }

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

  HistoryItem get last => _list.last;

  bool get isEmpty => _list.isEmpty;

  bool get isNonEmpty => _list.isNotEmpty;

  int get length => _list.length;
}

class UndoManager {
  final FixedSizeStack undoStack;
  final FixedSizeStack redoStack;
  EditorState? state;

  UndoManager([int stackSize = 20])
      : undoStack = FixedSizeStack(stackSize),
        redoStack = FixedSizeStack(stackSize);

  /// Record a transaction into the appropriate stack based on [source].
  ///
  /// Returns the [HistoryItem] that was created or updated, or null
  /// if the source is [TransactionSource.none].
  HistoryItem? record(
    Transaction transaction,
    TransactionSource source,
  ) {
    switch (source) {
      case TransactionSource.userEdit:
        return _recordUserEdit(transaction);

      case TransactionSource.undo:
        return _recordFromUndo(transaction);

      case TransactionSource.redo:
        return _recordFromRedo(transaction);

      case TransactionSource.none:
        return null;
    }
  }

  /// User edit: add to current unsealed undo item or create a new one.
  /// Clears redo stack when branching (new sealed item means new edit
  /// after a previous undo).
  HistoryItem _recordUserEdit(Transaction transaction) {
    HistoryItem undoItem;
    if (undoStack.isEmpty) {
      undoItem = HistoryItem();
      undoStack.push(undoItem);
    } else {
      final last = undoStack.last;
      if (last.sealed) {
        redoStack.clear();
        undoItem = HistoryItem();
        undoStack.push(undoItem);
      } else {
        undoItem = last;
      }
    }
    undoItem.addAll(transaction.operations);
    if (undoItem.beforeSelection == null &&
        transaction.beforeSelection != null) {
      undoItem.beforeSelection = transaction.beforeSelection;
    }
    undoItem.afterSelection = transaction.afterSelection;

    return undoItem;
  }

  /// Undo operation: push directly to redo stack.
  HistoryItem _recordFromUndo(Transaction transaction) {
    final redoItem = HistoryItem();
    redoItem.addAll(transaction.operations);
    redoItem.beforeSelection = transaction.beforeSelection;
    redoItem.afterSelection = transaction.afterSelection;
    redoStack.push(redoItem);

    return redoItem;
  }

  /// Redo operation: push directly to undo stack, sealed immediately.
  /// Does NOT clear redo stack.
  HistoryItem _recordFromRedo(Transaction transaction) {
    final undoItem = HistoryItem();
    undoItem.addAll(transaction.operations);
    undoItem.beforeSelection = transaction.beforeSelection;
    undoItem.afterSelection = transaction.afterSelection;
    undoItem.seal();
    undoStack.push(undoItem);

    return undoItem;
  }

  @Deprecated('Use record() with TransactionSource instead')
  HistoryItem getUndoHistoryItem() {
    if (undoStack.isEmpty) {
      final item = HistoryItem();
      undoStack.push(item);

      return item;
    }
    final last = undoStack.last;
    if (last.sealed) {
      redoStack.clear();
      final item = HistoryItem();
      undoStack.push(item);

      return item;
    }

    return last;
  }

  void undo() {
    AppFlowyEditorLog.editor.debug('undo');
    final s = state;
    if (s == null) {
      return;
    }
    final historyItem = undoStack.pop();
    if (historyItem == null) {
      return;
    }
    final transaction = historyItem.toTransaction(s);
    s.apply(
      transaction,
      options: const ApplyOptions(source: TransactionSource.undo),
    );
  }

  void redo() {
    AppFlowyEditorLog.editor.debug('redo');
    final s = state;
    if (s == null) {
      return;
    }
    final historyItem = redoStack.pop();
    if (historyItem == null) {
      return;
    }
    final transaction = historyItem.toTransaction(s);
    s.apply(
      transaction,
      options: const ApplyOptions(source: TransactionSource.redo),
    );
  }

  void forgetRecentUndo() {
    AppFlowyEditorLog.editor.debug('forgetRecentUndo');
    if (state != null) {
      undoStack.pop();
    }
  }
}
