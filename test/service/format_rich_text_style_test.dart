import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/service/default_text_operations/format_rich_text_style.dart';
import 'package:flutter_test/flutter_test.dart';
import '../new/infra/testable_editor.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('format rich text style', () {
    testWidgets('insertNodeAfterSelection', (tester) async {
      final editor = tester.editor..addParagraph();
      await editor.startTesting();

      await editor.updateSelection(Selection.collapsed(Position(path: [0])));
      final inserted =
          insertNodeAfterSelection(editor.editorState, paragraphNode());
      await tester.pumpAndSettle();

      expect(inserted, true);
      final node = editor.nodeAtPath([1])!;
      expect(node.attributes[blockComponentTextDirection], null);

      await editor.dispose();
    });

    testWidgets('insertNodeAfterSelection on empty node', (tester) async {
      final editor = tester.editor..addNode(paragraphNode());
      await editor.startTesting();

      await editor.updateSelection(Selection.collapsed(Position(path: [0])));
      final inserted =
          insertNodeAfterSelection(editor.editorState, paragraphNode());
      await tester.pumpAndSettle();

      expect(inserted, true);
      final node = editor.nodeAtPath([0])!;
      expect(node.attributes[blockComponentTextDirection], null);

      await editor.dispose();
    });

    testWidgets('insertNodeAfterSelection on node with text direction',
        (tester) async {
      final editor = tester.editor
        ..addNode(
          paragraphNode(
            text: ' ',
            textDirection: blockComponentTextDirectionAuto,
          ),
        );
      await editor.startTesting();

      await editor.updateSelection(Selection.collapsed(Position(path: [0])));
      final inserted =
          insertNodeAfterSelection(editor.editorState, paragraphNode());
      await tester.pumpAndSettle();

      final node = editor.nodeAtPath([1])!;
      expect(inserted, true);
      expect(
        node.attributes[blockComponentTextDirection],
        blockComponentTextDirectionAuto,
      );

      await editor.dispose();
    });

    testWidgets('insertNodeAfterSelection on empty node with text direction',
        (tester) async {
      final editor = tester.editor
        ..addNode(
          paragraphNode(textDirection: blockComponentTextDirectionLTR),
        );
      await editor.startTesting();

      await editor.updateSelection(Selection.collapsed(Position(path: [0])));
      final inserted =
          insertNodeAfterSelection(editor.editorState, paragraphNode());
      await tester.pumpAndSettle();

      final node = editor.nodeAtPath([0])!;
      expect(inserted, true);
      expect(
        node.attributes[blockComponentTextDirection],
        blockComponentTextDirectionLTR,
      );

      await editor.dispose();
    });

    testWidgets('insertHeadingAfterSelection on rtl node', (tester) async {
      final editor = tester.editor
        ..addNode(
          paragraphNode(
            text: ' ',
            textDirection: blockComponentTextDirectionRTL,
          ),
        );
      await editor.startTesting();

      await editor.updateSelection(Selection.collapsed(Position(path: [0])));
      insertHeadingAfterSelection(editor.editorState, 1);
      await tester.pumpAndSettle();

      final node = editor.nodeAtPath([1])!;
      expect(
        node.attributes[blockComponentTextDirection],
        blockComponentTextDirectionRTL,
      );

      await editor.dispose();
    });
  });
}
