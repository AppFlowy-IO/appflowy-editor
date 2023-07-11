import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';

import '../infra/test_editor.dart';

void main() async {
  testWidgets('wrapp editor with directionality', (tester) async {
    await mockNetworkImagesFor(() async {
      const widget = DirectionalityTester();
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      final editorState = tester.editor.editorState;
      final heading = editorState.getNodeAtPath([0])!;
      final paragraph = editorState.getNodeAtPath([1])!;

      expect(heading.selectable?.textDirection(), TextDirection.rtl);
      expect(paragraph.selectable?.textDirection(), TextDirection.rtl);
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
          paragraphNode(text: 'این یک متن راست به چپ است')
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
