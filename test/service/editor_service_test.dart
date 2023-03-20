import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../infra/test_editor.dart';

void main() {
  group('AppFlowyEditor tests', () {
    testWidgets('shrinkWrap is false', (tester) async {
      final editor = tester.editor;
      await editor.startTesting();

      expect(find.byType(AppFlowyScroll), findsOneWidget);
    });

    testWidgets('shrinkWrap is true', (tester) async {
      final editor = tester.editor;
      await editor.startTesting(shrinkWrap: true);

      expect(find.byType(AppFlowyScroll), findsNothing);
    });

    testWidgets('without autoFocus', (tester) async {
      final editor = tester.editor..insertTextNode('Hello');
      await editor.startTesting(shrinkWrap: true, autoFocus: false);

      final selectedNodes =
          editor.editorState.service.selectionService.currentSelectedNodes;

      expect(selectedNodes.isEmpty, true);
    });

    testWidgets('with autoFocus', (tester) async {
      final editor = tester.editor..insertTextNode('Hello');
      await editor.startTesting(shrinkWrap: true, autoFocus: true);

      final selectedNodes =
          editor.editorState.service.selectionService.currentSelectedNodes;

      expect(selectedNodes.isEmpty, false);
    });
  });
}
