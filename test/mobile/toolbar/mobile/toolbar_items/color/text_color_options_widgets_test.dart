import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../../new/infra/testable_editor.dart';
import '../../test_helpers/mobile_toolbar_style_test_widget.dart';

void main() {
  group('TextColorOptionsWidgets', () {
    testWidgets('renders ClearColorButton', (tester) async {
      const text = 'Welcome to Appflowy 😁';
      final editor = tester.editor..addParagraphs(3, initialText: text);
      await editor.startTesting();

      var selection = Selection.single(
        path: [1],
        startOffset: 2,
        endOffset: text.length - 2,
      );

      await tester.pumpWidget(
        Material(
          child: MobileToolbarStyleTestWidget(
            child: TextColorOptionsWidgets(editor.editorState, selection),
          ),
        ),
      );

      expect(find.byType(ClearColorButton), findsOneWidget);
    });
  });
}
