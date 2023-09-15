import 'dart:ui';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';

void main() async {
  /// customize the image menu
  await AppFlowyEditorLocalizations.load(
    const Locale.fromSubtags(languageCode: 'en'),
  );
  testWidgets('customize the image block\'s menu', (tester) async {
    await mockNetworkImagesFor(() async {
      const widget = CustomImageMenu();
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await tester.pump();
      await gesture.moveTo(
        tester.getCenter(find.byType(ImageBlockComponentWidget)),
      );
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // expect to see the menu
      expect(find.text(menu), findsOneWidget);
    });
  });
}

const menu = 'Here\'s a custom menu!';

class CustomImageMenu extends StatelessWidget {
  const CustomImageMenu({super.key});

  @override
  Widget build(BuildContext context) {
    const url =
        'https://images.unsplash.com/photo-1682961941145-e73336a53bc6?dl=katsuma-tanaka-cWpkMDSQbWQ-unsplash.jpg';
    final document = Document.blank()
      ..insert(
        [0],
        [
          imageNode(
            url: url,
            width: 400,
            height: 400,
          ),
        ],
      );
    final customBlockComponentBuilders = {
      ...standardBlockComponentBuilderMap,
      ImageBlockKeys.type: ImageBlockComponentBuilder(
        showMenu: true,
        menuBuilder: (node, _) {
          return const Positioned(
            right: 10,
            child: Text(menu),
          );
        },
      ),
    };

    final editorState = EditorState(document: document);
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
