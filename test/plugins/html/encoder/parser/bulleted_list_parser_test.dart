import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group('bulleted_list_node_parser.dart', () {
    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    test('parser numbered list', () async {
      // * A1
      // * A2
      // * A3
      // * A4
      // to
      // <ul><li>A1</li><li>A2</li><li>A3</li><li>A4</li></ul>
      final encoder = DocumentHTMLEncoder(
        encodeParsers: [
          const HTMLBulletedListNodeParser(),
        ],
      );
      final result = encoder.convert(Document.fromJson(_json1));

      expect(result, _result1);
    });
  });
}

const _result1 = '''<ul><li>A1</li><li>A2</li><li>A3</li><li>A4</li></ul>''';

const _json1 = {
  'document': {
    'type': 'page',
    'children': [
      {
        'type': 'bulleted_list',
        'data': {
          'delta': [
            {'insert': 'A1'},
          ],
        },
      },
      {
        'type': 'bulleted_list',
        'data': {
          'delta': [
            {'insert': 'A2'},
          ],
        },
      },
      {
        'type': 'bulleted_list',
        'data': {
          'delta': [
            {'insert': 'A3'},
          ],
        },
      },
      {
        'type': 'bulleted_list',
        'data': {
          'delta': [
            {'insert': 'A4'},
          ],
        },
      },
    ],
  },
};
