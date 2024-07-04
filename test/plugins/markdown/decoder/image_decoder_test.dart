import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group('ordered list decoder', () {
    final parser = DocumentMarkdownDecoder(
      markdownElementParsers: [
        const MarkdownImageParserV2(),
      ],
    );

    test('convert image', () {
      final result = parser.convert('![image_name](appflowy.io/image.png)');
      expect(result.root.children[0].toJson(), {
        'type': 'image',
        'data': {
          'url': 'appflowy.io/image.png',
          'align': 'center',
        },
      });
    });
  });
}
