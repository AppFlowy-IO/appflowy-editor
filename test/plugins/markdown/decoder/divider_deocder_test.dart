import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group('ordered list decoder', () {
    final parser = DocumentMarkdownDecoder(
      markdownElementParsers: [
        const MarkdownDividerParserV2(),
      ],
    );

    test('convert ---', () {
      final result = parser.convert('---');
      expect(result.root.children[0].toJson(), {
        'type': 'divider',
      });
    });

    test('the numbered of - <= 2', () {
      expect(parser.convert('--').isEmpty, true);
      expect(parser.convert('-').isEmpty, true);
    });
  });
}
