import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  List<HtmlNodeParser> parser = [
    const HtmlTextNodeParser(),
    const HtmlBulletedListNodeParser(),
    const HtmlNumberedListNodeParser(),
    const HtmlTodoListNodeParser(),
    const HtmlQuoteNodeParser(),
    const HtmlHeadingNodeParser(),
    const HtmlImageNodeParser(),
  ];
  group('html_image_node_parser.dart', () {
    test('parser image node', () {
      final node = Node(
        type: 'image',
        attributes: {
          'url': 'https://appflowy.io',
        },
      );

      final result =
          const HtmlImageNodeParser().transform(node, encodeParsers: parser);

      expect(result, '<span><img src="https://appflowy.io"></span>');
    });

    test('ImageNodeParser id getter', () {
      const imageNodeParser = ImageNodeParser();
      expect(imageNodeParser.id, 'image');
    });
  });
}
