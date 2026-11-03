// coverage:ignore-file

import 'dart:async';

import 'scroll_offset_listener.dart';

class ScrollOffsetNotifier implements ScrollOffsetListener {
  ScrollOffsetNotifier({this.recordProgrammaticScrolls = true});
  final bool recordProgrammaticScrolls;

  final _streamController = StreamController<double>();

  @override
  Stream<double> get changes => _streamController.stream;

  StreamController get changeController => _streamController;

  void dispose() {
    _streamController.close();
  }
}
