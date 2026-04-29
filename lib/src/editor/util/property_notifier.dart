import 'dart:collection';

import 'package:flutter/foundation.dart';

/// [PropertyValueNotifier] is similar to [ValueNotifier] except it always
/// notifies listeners on assignment, even when the new value compares equal to
/// the previous one.
///
/// It deliberately does NOT extend [ChangeNotifier]. The default
/// [ChangeNotifier] stores listeners in a list and performs a linear scan +
/// array shift on every [removeListener] call. When a single notifier (such as
/// [EditorState.selectionNotifier]) has tens of thousands of listeners — the
/// case for large documents where every visible block component subscribes —
/// disposing many block components on a single frame becomes O(n²). Fast
/// scrolling through a 10k-node document then spends seconds inside dispose
/// methods alone.
///
/// This implementation backs the listener registry with a [LinkedHashSet],
/// giving O(1) add/remove while preserving insertion-order dispatch and the
/// usual [ChangeNotifier] semantics around reentrant add/remove during
/// notification.
class PropertyValueNotifier<T> implements ValueListenable<T> {
  PropertyValueNotifier(this._value);

  T _value;

  @override
  T get value => _value;

  set value(T newValue) {
    _value = newValue;
    notifyListeners();
  }

  final LinkedHashSet<VoidCallback> _listeners = LinkedHashSet<VoidCallback>();

  // Non-null only while a notification dispatch is in progress AND a listener
  // mutated the listener set during that dispatch. Mutations are deferred so
  // dispatch can iterate [_listeners] safely without snapshotting every frame.
  Set<VoidCallback>? _pendingRemovals;
  List<VoidCallback>? _pendingAdditions;
  int _notificationDepth = 0;
  bool _disposed = false;

  bool get hasListeners => _listeners.isNotEmpty;

  @override
  void addListener(VoidCallback listener) {
    assert(_debugAssertNotDisposed());
    if (_notificationDepth > 0) {
      (_pendingAdditions ??= <VoidCallback>[]).add(listener);
    } else {
      _listeners.add(listener);
    }
  }

  @override
  void removeListener(VoidCallback listener) {
    if (_notificationDepth > 0) {
      // If it was queued for addition during this same dispatch, undo that
      // first so contains-checks work as callers expect.
      _pendingAdditions?.remove(listener);
      (_pendingRemovals ??= <VoidCallback>{}).add(listener);
    } else {
      _listeners.remove(listener);
    }
  }

  @protected
  @visibleForTesting
  void notifyListeners() {
    assert(_debugAssertNotDisposed());
    if (_listeners.isEmpty) {
      return;
    }
    _notificationDepth++;
    try {
      for (final listener in _listeners) {
        if (_pendingRemovals != null &&
            _pendingRemovals!.contains(listener)) {
          continue;
        }
        try {
          listener();
        } catch (exception, stack) {
          FlutterError.reportError(
            FlutterErrorDetails(
              exception: exception,
              stack: stack,
              library: 'appflowy_editor',
              context: ErrorDescription(
                'while dispatching notifications for $runtimeType',
              ),
            ),
          );
        }
      }
    } finally {
      _notificationDepth--;
      if (_notificationDepth == 0) {
        final removals = _pendingRemovals;
        if (removals != null) {
          _pendingRemovals = null;
          _listeners.removeAll(removals);
        }
        final additions = _pendingAdditions;
        if (additions != null) {
          _pendingAdditions = null;
          _listeners.addAll(additions);
        }
      }
    }
  }

  void dispose() {
    assert(_debugAssertNotDisposed());
    _disposed = true;
    _listeners.clear();
    _pendingRemovals = null;
    _pendingAdditions = null;
  }

  bool _debugAssertNotDisposed() {
    assert(() {
      if (_disposed) {
        throw FlutterError(
          'A $runtimeType was used after being disposed.\n'
          'Once you have called dispose() on a $runtimeType, it can no longer '
          'be used.',
        );
      }
      return true;
    }());
    return true;
  }
}
