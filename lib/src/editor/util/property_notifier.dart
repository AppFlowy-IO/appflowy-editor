import 'package:flutter/foundation.dart';

/// [PropertyValueNotifier] is a subclass of [ValueNotifier].
///
/// The difference is that [PropertyValueNotifier] will notify listeners even
/// when the value is the same as the previous value.
///
///

class PropertyValueNotifier<T> extends ChangeNotifier
    implements ValueListenable<T> {
  /// Creates a [ChangeNotifier] that wraps this value.
  PropertyValueNotifier(this._value);

  /// The current value stored in this notifier.
  ///
  /// When the value is replaced with something that is not equal to the old
  /// value as evaluated by the equality operator ==, this class notifies its
  /// listeners.
  @override
  T get value => _value;
  T _value;
  set value(T newValue) {
    _value = newValue;
    notifyListeners();
  }
}
