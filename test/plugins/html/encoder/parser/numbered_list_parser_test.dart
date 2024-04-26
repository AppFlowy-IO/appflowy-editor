import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group('numbered_list_node_parser.dart', () {
    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    test('parser numbered list', () async {
      // 1. A1
      // 2. A2
      // 3. A3
      // 4. A4
      // to
      // <ol><li>A1</li><li>A2</li><li>A3</li><li>A4</li></ol>
      final encoder = DocumentHTMLEncoder(
        encodeParsers: [
          const HTMLNumberedListNodeParser(),
        ],
      );
      final result = encoder.convert(Document.fromJson(_json1));

      expect(result, _result1);
    });

    test('parser numbered list', () async {
      // 100. A1
      // 101. A2
      // 102. A3
      // 103. A4
      // to
      // <ol start="100"><li>A1</li><li>A2</li><li>A3</li><li>A4</li></ol>
      final encoder = DocumentHTMLEncoder(
        encodeParsers: [
          const HTMLNumberedListNodeParser(),
        ],
      );
      final result = encoder.convert(Document.fromJson(_json2));

      expect(result, _result2);
    });
  });
}

const _result1 = '''<ol><li>A1</li><li>A2</li><li>A3</li><li>A4</li></ol>''';
const _result2 =
    '''<ol start="100"><li>A1</li><li>A2</li><li>A3</li><li>A4</li></ol>''';

const _json1 = {
  'document': {
    'type': 'page',
    'children': [
      {
        'type': 'numbered_list',
        'data': {
          'delta': [
            {'insert': 'A1'},
          ],
        },
      },
      {
        'type': 'numbered_list',
        'data': {
          'delta': [
            {'insert': 'A2'},
          ],
        },
      },
      {
        'type': 'numbered_list',
        'data': {
          'delta': [
            {'insert': 'A3'},
          ],
        },
      },
      {
        'type': 'numbered_list',
        'data': {
          'delta': [
            {'insert': 'A4'},
          ],
        },
      },
    ],
  },
};

const _json2 = {
  'document': {
    'type': 'page',
    'children': [
      {
        'type': 'numbered_list',
        'data': {
          'number': 100,
          'delta': [
            {'insert': 'A1'},
          ],
        },
      },
      {
        'type': 'numbered_list',
        'data': {
          'delta': [
            {'insert': 'A2'},
          ],
        },
      },
      {
        'type': 'numbered_list',
        'data': {
          'delta': [
            {'insert': 'A3'},
          ],
        },
      },
      {
        'type': 'numbered_list',
        'data': {
          'delta': [
            {'insert': 'A4'},
          ],
        },
      },
    ],
  },
};
