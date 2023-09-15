import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';

void main() async {
  /// supports
  ///
  /// - numbered list
  /// - bulleted list
  /// - todo list
  /// - quote
  await AppFlowyEditorLocalizations.load(
    const Locale.fromSubtags(languageCode: 'en'),
  );
  testWidgets('custom block icon', (tester) async {
    await mockNetworkImagesFor(() async {
      const widget = CustomBlockIcon();
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      iconMap.forEach((key, value) {
        expect(find.byIcon(value), findsOneWidget);
      });
    });
  });
}

const menu = 'Here\'s a custom menu!';

final iconMap = {
  BulletedListBlockKeys.type: Icons.format_list_bulleted,
  NumberedListBlockKeys.type: Icons.format_list_numbered,
  QuoteBlockKeys.type: Icons.format_quote,
  TodoListBlockKeys.type: Icons.check_box_outline_blank,
};

class CustomBlockIcon extends StatelessWidget {
  const CustomBlockIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final delta = Delta()..insert('Hello World');
    final document = Document.blank()
      ..insert(
        [0],
        [
          bulletedListNode(delta: delta),
          numberedListNode(delta: delta),
          todoListNode(delta: delta, checked: false),
          quoteNode(delta: delta),
        ],
      );

    final customBlockComponentBuilders = {
      ...standardBlockComponentBuilderMap,
      BulletedListBlockKeys.type: BulletedListBlockComponentBuilder(
        iconBuilder: (_, __) => Icon(iconMap[BulletedListBlockKeys.type]),
      ),
      NumberedListBlockKeys.type: NumberedListBlockComponentBuilder(
        iconBuilder: (_, __) => Icon(iconMap[NumberedListBlockKeys.type]),
      ),
      TodoListBlockKeys.type: TodoListBlockComponentBuilder(
        iconBuilder: (_, __) => Icon(iconMap[TodoListBlockKeys.type]),
      ),
      QuoteBlockKeys.type: QuoteBlockComponentBuilder(
        iconBuilder: (_, __) => Icon(iconMap[QuoteBlockKeys.type]),
      ),
    };

    final editorState = EditorState(document: document);
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: SizedBox(
            width: 500,
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
