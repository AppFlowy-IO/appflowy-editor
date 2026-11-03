import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'disposing a shrink-wrapped controller detaches document listeners',
    (tester) async {
      final editorState = EditorState.blank(withInitialText: false);
      addTearDown(editorState.dispose);
      final scrollController = EditorScrollController(
        editorState: editorState,
        shrinkWrap: true,
      );

      scrollController.dispose();
      editorState.document.insert([0], [paragraphNode()]);

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'disposing a shrink-wrapped controller detaches external scroll listeners',
    (tester) async {
      final editorState = EditorState.blank(withInitialText: false);
      final externalScrollController = _TestScrollController();
      addTearDown(editorState.dispose);
      addTearDown(externalScrollController.dispose);
      final scrollController = EditorScrollController(
        editorState: editorState,
        shrinkWrap: true,
        scrollController: externalScrollController,
      );

      expect(externalScrollController.listenerCount, 1);
      scrollController.dispose();

      expect(externalScrollController.listenerCount, 0);
    },
  );
}

class _TestScrollController extends ScrollController {
  final Set<VoidCallback> _listeners = {};

  int get listenerCount => _listeners.length;

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
    super.removeListener(listener);
  }
}
