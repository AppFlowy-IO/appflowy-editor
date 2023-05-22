import 'package:flutter/material.dart';

/// [PropertyValueNotifier] is a subclass of [ValueNotifier].
///
/// The difference is that [PropertyValueNotifier] will notify listeners even
/// when the value is the same as the previous value.
class PropertyValueNotifier<T> extends ValueNotifier<T> {
  PropertyValueNotifier(T value) : super(value);

  @override
  // ignore: unnecessary_overrides
  void notifyListeners() {
    super.notifyListeners();
  }
}
