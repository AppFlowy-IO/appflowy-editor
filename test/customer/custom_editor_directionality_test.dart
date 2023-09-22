import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';

void main() async {
  await AppFlowyEditorLocalizations.load(
    const Locale.fromSubtags(languageCode: 'en'),
  );
  testWidgets('wrapp editor with directionality', (tester) async {
    await mockNetworkImagesFor(() async {
      const widget = DirectionalityTester();
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      final editorState = tester
          .widget(find.byType(AppFlowyEditor))
          .unwrapOrNull<AppFlowyEditor>()!
          .editorState;
      Node headerNode = editorState.getNodeAtPath([0])!;
      Node textNode = editorState.getNodeAtPath([1])!;

      expect(headerNode.selectable?.textDirection(), TextDirection.rtl);
      expect(textNode.selectable?.textDirection(), TextDirection.rtl);
    });
  });
}

class DirectionalityTester extends StatelessWidget {
  const DirectionalityTester({super.key});

  @override
  Widget build(BuildContext context) {
    final document = Document.blank()
      ..insert(
        [0],
        [
          headingNode(level: 1, delta: Delta()..insert('سلام از Appflowy')),
          paragraphNode(text: 'این یک متن راست به چپ است'),
        ],
      );

    final editorState = EditorState(document: document);
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: SizedBox(
            width: 500,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: AppFlowyEditor(
                editorState: editorState,
                blockComponentBuilders: standardBlockComponentBuilderMap,
                commandShortcutEvents: standardCommandShortcutEvents,
                characterShortcutEvents: standardCharacterShortcutEvents,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
