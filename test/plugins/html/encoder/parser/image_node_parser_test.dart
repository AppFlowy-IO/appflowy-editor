import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group('html_image_node_parser.dart', () {
    test('parser image node', () {
      final node = Node(
        type: 'image',
        attributes: {
          'url': 'https://appflowy.io',
        },
      );

      final result = const HtmlImageNodeParser().transform(node);

      expect(result, '<img src="https://appflowy.io">');
    });

    test('ImageNodeParser id getter', () {
      const imageNodeParser = ImageNodeParser();
      expect(imageNodeParser.id, 'image');
    });
  });
}
