import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../infra/testable_editor.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('slash_handler.dart', () {
    testWidgets('Presses / to trigger selection menu in 0 index',
        (tester) async {
      const text = 'Welcome to Appflowy 😁';
      const lines = 3;
      final editor = tester.editor;
      editor.addParagraphs(lines, initialText: text);

      await editor.startTesting();
      await editor.updateSelection(Selection.single(path: [1], startOffset: 0));
      await editor.pressKey(character: '/');
      await tester.pumpAndSettle(const Duration(milliseconds: 1000));

      expect(
        find.byType(SelectionMenuWidget, skipOffstage: false),
        findsOneWidget,
      );

      for (final item in standardSelectionMenuItems) {
        expect(find.text(item.name), findsOneWidget);
      }

      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
      expect(
        find.byType(SelectionMenuItemWidget, skipOffstage: false),
        findsNothing,
      );
    });

    testWidgets('Presses / to trigger selection menu in not 0 index',
        (tester) async {
      const text = 'Welcome to Appflowy 😁';
      const lines = 3;
      final editor = tester.editor;
      editor.addParagraphs(lines, initialText: text);

      await editor.startTesting();
      await editor.updateSelection(Selection.single(path: [1], startOffset: 5));
      await editor.pressKey(character: '/');

      await tester.pumpAndSettle(const Duration(milliseconds: 1000));

      expect(
        find.byType(SelectionMenuWidget, skipOffstage: false),
        findsOneWidget,
      );

      for (final item in standardSelectionMenuItems) {
        expect(find.text(item.name), findsOneWidget);
      }

      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      expect(
        find.byType(SelectionMenuItemWidget, skipOffstage: false),
        findsNothing,
      );
    });
  });
}
