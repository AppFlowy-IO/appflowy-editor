import 'dart:ui';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';

void main() async {
  /// customize the action builder
  await AppFlowyEditorLocalizations.load(
    const Locale.fromSubtags(languageCode: 'en'),
  );
  testWidgets('customize the image block\'s menu', (tester) async {
    await mockNetworkImagesFor(() async {
      const widget = CustomActionBuilder();
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await tester.pump();
      await gesture.moveTo(
        tester.getCenter(find.byType(TextBlockComponentWidget)),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // expect to see the menu
      final menuButton = find.text(menu);
      expect(menuButton, findsOneWidget);
      await tester.tap(menuButton);
      await tester.pumpAndSettle();

      final selectionAreaRect = tester.getTopLeft(
        find.byWidgetPredicate(
          (widget) =>
              widget is BlockSelectionArea &&
              widget.supportTypes.contains(BlockSelectionType.block),
        ),
      );
      expect(selectionAreaRect.dx, greaterThan(0));
    });
  });
}

const menu = 'menu';

class CustomActionBuilder extends StatelessWidget {
  const CustomActionBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    const text = 'Hello AppFlowy!';
    final document = Document.blank()
      ..insert([
        0,
      ], [
        paragraphNode(text: text),
      ]);

    final editorState = EditorState(document: document);

    final paragraphBuilder = TextBlockComponentBuilder(
      configuration: standardBlockComponentConfiguration,
    );
    paragraphBuilder.showActions = (_) => true;
    paragraphBuilder.actionBuilder = (blockComponentContext, state) {
      return Container(
        width: 50,
        height: 30,
        color: Colors.red,
        child: TextButton(
          onPressed: () {
            // update block selection
            editorState.selectionType = SelectionType.block;
            editorState.selection = Selection.single(
              path: [0],
              startOffset: 0,
              endOffset: text.length,
            );
          },
          child: const Text(menu),
        ),
      );
    };

    final customBlockComponentBuilders = {
      PageBlockKeys.type: PageBlockComponentBuilder(),
      ParagraphBlockKeys.type: paragraphBuilder,
    };

    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Container(
            width: 500,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
            ),
            child: AppFlowyEditor(
              editorState: editorState,
              blockComponentBuilders: customBlockComponentBuilders,
            ),
          ),
        ),
      ),
    );
  }
}
