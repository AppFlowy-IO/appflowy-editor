import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import '../../infra/testable_editor.dart';

void main() async {
  group('text block component', () {
    testWidgets('insert rtl text in paragraph with auto direction',
        (tester) async {
      final editor = tester.editor
        ..addParagraph(
          initialText: 'س',
          decorator: (i, n) => n.updateAttributes(
            {blockComponentTextDirection: blockComponentTextDirectionAuto},
          ),
        );
      await editor.startTesting();

      final editorOffset =
          editor.editorState.renderBox?.localToGlobal(Offset.zero) ??
              Offset.zero;
      final editorSize = editor.editorState.renderBox?.size ?? Size.zero;
      final editorRect = editorOffset & editorSize;
      final editorCenter = editorRect.center;

      final flowyRichText = find.byType(AppFlowyRichText);
      expect(flowyRichText, findsOneWidget);
      expect(
        tester.getTopLeft(flowyRichText).dx > editorCenter.dx,
        true,
        reason: "${tester.getTopLeft(flowyRichText).dx} < ${editorCenter.dx}",
      );
      await editor.dispose();
    });

    testWidgets('insert ltr text in paragraph with auto direction',
        (tester) async {
      final editor = tester.editor
        ..addParagraph(
          initialText: 'a',
          decorator: (i, n) => n.updateAttributes(
            {blockComponentTextDirection: blockComponentTextDirectionAuto},
          ),
        );
      await editor.startTesting();

      final editorOffset =
          editor.editorState.renderBox?.localToGlobal(Offset.zero) ??
              Offset.zero;
      final editorSize = editor.editorState.renderBox?.size ?? Size.zero;
      final editorRect = editorOffset & editorSize;
      final editorCenter = editorRect.center;

      final flowyRichText = find.byType(AppFlowyRichText);
      expect(flowyRichText, findsOneWidget);
      expect(
        tester.getTopLeft(flowyRichText).dx < editorCenter.dx,
        true,
        reason: "${tester.getTopLeft(flowyRichText).dx} < ${editorCenter.dx}",
      );
      await editor.dispose();
    });
  });
}
