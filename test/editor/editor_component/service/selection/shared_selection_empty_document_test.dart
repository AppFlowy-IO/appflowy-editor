import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/selection/mobile_selection_service.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/selection/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../../../test_helper.dart';

/// Regression test for AppFlowy Editor issue #1218.
///
/// The mobile selection service calls `editorState.getNodeInOffset(...)` with
/// `sortedNodes.length - 1` as the `end` argument. When the document is empty
/// (Document.blank(withInitialText: false)), `sortedNodes` is empty and `end`
/// becomes -1. The guard in `shared.dart` used `&&` instead of `||`, so it
/// did not return null for this case, and the code proceeded to index into an
/// empty list, raising a RangeError.
void main() {
  group('EditorStateSelection.getNodeInOffset with empty document', () {
    test('returns null for empty node list (start=0, end=-1)', () {
      final editorState = EditorState.blank(withInitialText: false);
      addTearDown(editorState.dispose);

      // This mirrors the call the mobile selection service makes when the
      // document has no children: getNodeInOffset([], offset, 0, length - 1)
      // where length is 0, so end is -1.
      final result = editorState.getNodeInOffset(
        <Node>[],
        const Offset(100, 100),
        0,
        -1,
      );

      expect(result, isNull);
    });

    test('returns null for empty node list with explicit negative end', () {
      final editorState = EditorState.blank(withInitialText: false);
      addTearDown(editorState.dispose);

      final result = editorState.getNodeInOffset(
        <Node>[],
        const Offset(50, 50),
        -1,
        -1,
      );

      expect(result, isNull);
    });

    test('returns null for empty node list with out-of-bounds end', () {
      final editorState = EditorState.blank(withInitialText: false);
      addTearDown(editorState.dispose);

      final result = editorState.getNodeInOffset(
        <Node>[],
        const Offset(50, 50),
        0,
        100,
      );

      expect(result, isNull);
    });
  });

  group('MobileSelectionServiceWidget with empty document', () {
    testWidgets('getNodeInOffset returns null without crashing', (tester) async {
      final editorState = EditorState.blank(withInitialText: false);
      addTearDown(editorState.dispose);

      final scrollController = EditorScrollController(
        editorState: editorState,
        shrinkWrap: true,
      );
      addTearDown(scrollController.dispose);

      final key = GlobalKey();

      await tester.buildAndPump(
        MultiProvider(
          providers: [
            Provider<EditorState>(create: (_) => editorState),
            Provider<EditorScrollController>(create: (_) => scrollController),
          ],
          child: MobileSelectionServiceWidget(
            key: key,
            child: const SizedBox.shrink(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Access the selection service state and call getNodeInOffset.
      // This is the exact code path triggered when a user taps the editor
      // surface on a mobile device with an empty document.
      final state = key.currentState as AppFlowySelectionService;
      final node = state.getNodeInOffset(const Offset(50, 50));

      expect(node, isNull);
      expect(tester.takeException(), isNull);
    });
  });
}
