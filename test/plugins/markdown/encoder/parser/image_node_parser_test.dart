import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group('image_node_parser.dart', () {
    test('parser image node', () {
      final node = Node(
        type: 'image',
        attributes: {
          'url': 'https://appflowy.io',
        },
      );

      final result = const ImageNodeParser().transform(node, null);
      expect(result, '![](https://appflowy.io)');
    });

    test('ImageNodeParser id getter', () {
      const imageNodeParser = ImageNodeParser();
      expect(imageNodeParser.id, 'image');
    });
  });
}
