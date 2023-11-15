import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  List<HTMLNodeParser> parser = [
    const HTMLTextNodeParser(),
    const HTMLBulletedListNodeParser(),
    const HTMLNumberedListNodeParser(),
    const HTMLTodoListNodeParser(),
    const HTMLQuoteNodeParser(),
    const HTMLHeadingNodeParser(),
    const HTMLImageNodeParser(),
    const HtmlTableNodeParser(),
  ];
  group('html_image_node_parser.dart', () {
    test('parser image node', () {
      final node = Node(
        type: 'image',
        attributes: {
          'url': 'https://appflowy.io',
        },
      );

      final result = const HTMLImageNodeParser()
          .transformNodeToHTMLString(node, encodeParsers: parser);

      expect(result, '<img src="https://appflowy.io">');
    });

    test('ImageNodeParser id getter', () {
      const imageNodeParser = ImageNodeParser();
      expect(imageNodeParser.id, 'image');
    });
  });
}
