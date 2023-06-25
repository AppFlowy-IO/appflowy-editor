import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../new/infra/testable_editor.dart';
import 'test_helpers/mobile_app_with_toolbar_widget.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });
  group('MobileToolbar', () {
    testWidgets('return SizeBox when it is no selection', (tester) async {
      final editor = tester.editor;
      await editor.startTesting();

      final toolbarItems = [
        textDecorationMobileToolbarItem,
        linkMobileToolbarItem,
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: MobileToolbar(
            editorState: editor.editorState,
            toolbarItems: toolbarItems,
          ),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('show MobileToolbarWidget when some text is selected ',
        (tester) async {
      const text = 'Welcome to Appflowy 😁';
      final editor = tester.editor..addParagraphs(3, initialText: text);
      await editor.startTesting();

      var selection = Selection.single(
        path: [1],
        startOffset: 2,
        endOffset: text.length - 2,
      );
      await editor.updateSelection(selection);

      await tester.pumpWidget(
        Material(
          child: MobileAppWithToolbarWidget(editorState: editor.editorState),
        ),
      );

      expect(find.byType(MobileToolbarWidget), findsOneWidget);
    });
  });
}
