import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/render/image/image_upload_widget.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../infra/test_editor.dart';

void main() {
  group('ImageUploadMenu tests', () {
    testWidgets('showImageUploadMenu', (tester) async {
      final editor = tester.editor..insertTextNode('Welcome to AppFlowy');
      await editor.startTesting();

      await editor.updateSelection(
        Selection.single(path: [0], startOffset: 19),
      );

      await editor.pressLogicKey(character: '/');
      await tester.pumpAndSettle();

      expect(find.byType(SelectionMenuWidget), findsOneWidget);

      final imageMenuItemFinder = find.text('Image');
      expect(imageMenuItemFinder, findsOneWidget);

      await tester.tap(imageMenuItemFinder);
      await tester.pumpAndSettle();
    });

    testWidgets('insertImageNode extension', (tester) async {
      final editor = tester.editor..insertTextNode('Welcome to AppFlowy');
      await editor.startTesting();

      await editor.updateSelection(
        Selection.single(path: [0], startOffset: 19),
      );

      editor.editorState.insertImageNode('no_src');
      await tester.pumpAndSettle();

      expect(editor.documentLength, 2);
    });
  });
}
