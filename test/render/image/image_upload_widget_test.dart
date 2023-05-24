import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../new/infra/testable_editor.dart';

void main() {
  group('ImageUploadMenu tests', () {
    testWidgets('showImageUploadMenu', (tester) async {
      final editor = tester.editor
        ..addParagraph(initialText: 'Welcome to AppFlowy');
      await editor.startTesting();

      await editor.updateSelection(
        Selection.single(path: [0], startOffset: 19),
      );

      await editor.pressKey(character: '/');
      await tester.pumpAndSettle();

      expect(find.byType(SelectionMenuWidget), findsOneWidget);

      final imageMenuItemFinder = find.text('Image');
      expect(imageMenuItemFinder, findsOneWidget);

      await tester.tap(imageMenuItemFinder);
      await tester.pumpAndSettle();

      await editor.dispose();
    });
  });
}
