import 'dart:ui';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test_helper.dart';

void main() {
  group('DesktopSelectionServiceWidget', () {
    testWidgets(
      'does not crash when selection is cleared before metric debounce fires',
      (tester) async {
        final editorState = EditorState(document: Document.blank());

        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        tester.view.devicePixelRatio = 1.0;

        await tester.buildAndPump(
          AppFlowyEditor(
            editorState: editorState,
          ),
        );

        editorState.selectionService.updateSelection(
          Selection.collapsed(Position(path: [0])),
        );
        await tester.pump();

        tester.view.physicalSize = const Size(1600, 1200);
        await tester.pump();

        editorState.selection = null;
        await tester.pump(const Duration(milliseconds: 101));

        expect(tester.takeException(), isNull);
        expect(editorState.selectionService.currentSelection.value, isNull);
      },
    );
  });
}
