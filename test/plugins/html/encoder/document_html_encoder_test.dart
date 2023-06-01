import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:appflowy_editor/appflowy_editor.dart';

void main() async {
  group('document_html_encoder_test.dart', () {
    const example = """<h2>👋 <strong>Welcome to</strong>\n'
            '   <span style="font-weight: bold; font-style: italic">AppFlowy Editor</span>\n'
            ' </h2><p></p><p>AppFlowy Editor is a <strong>highly customizable</strong>\n'
            '   <i>rich-text editor</i> for <u>Flutter</u>\n'
            ' </p><p></p><blockquote><p>\n'
            '   Here is an example you can give a try\n'
            ' </p></blockquote><p></p><p>You can also use <span style="font-weight: bold; font-style: italic">AppFlowy Editor</span> as a component to build your own app. </p><p></p><ol><li><p>\n'
            '     Use / to insert blocks\n'
            '   </p></li><li><p>\n'
            '     Select text to trigger to the toolbar to format your notes.\n'
            '   </p></li></ol><p></p><p>If you have questions or feedback, please submit an issue on Github or join the community along with 1000+ builders!</p><p>\n'
            ' \n'
            ' \n'
            ' \n'
            ' \n'
            ' \n'
            ' \n'
            ' \n'
            ' \n'
            ' \n'
            ' </p>""";

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    test('parser document', () async {
      const delta = {
        'document': {
          'type': 'page',
          'children': [
            {
              'type': 'heading',
              'data': {
                'level': 2,
                'delta': [
                  {'insert': '👋 '},
                  {
                    'insert': 'Welcome to',
                    'attributes': {'bold': true}
                  },
                  {
                    'insert': '\n'
                        '\'\n'
                        '            \'   '
                  },
                  {
                    'insert': 'AppFlowy Editor',
                    'attributes': {'bold': true, 'italic': true}
                  },
                  {
                    'insert': '\n'
                        '\'\n'
                        '            \' '
                  }
                ]
              }
            },
            {
              'type': 'paragraph',
              'data': {'delta': []}
            },
            {
              'type': 'paragraph',
              'data': {
                'delta': [
                  {'insert': 'AppFlowy Editor is a '},
                  {
                    'insert': 'highly customizable',
                    'attributes': {'bold': true}
                  },
                  {
                    'insert': '\n'
                        '\'\n'
                        '            \'   '
                  },
                  {
                    'insert': 'rich-text editor',
                    'attributes': {'italic': true}
                  },
                  {'insert': ' for '},
                  {
                    'insert': 'Flutter',
                    'attributes': {'underline': true}
                  },
                  {
                    'insert': '\n'
                        '\'\n'
                        '            \' '
                  }
                ]
              }
            },
            {
              'type': 'paragraph',
              'data': {'delta': []}
            },
            {
              'type': 'quote',
              'data': {
                'delta': [
                  {
                    'insert': '\n'
                        '\'\n'
                        '            \'   Here is an example you can give a try\n'
                        '\'\n'
                        '            \' '
                  }
                ]
              }
            },
            {
              'type': 'paragraph',
              'data': {'delta': []}
            },
            {
              'type': 'paragraph',
              'data': {
                'delta': [
                  {'insert': 'You can also use '},
                  {
                    'insert': 'AppFlowy Editor',
                    'attributes': {'bold': true, 'italic': true}
                  },
                  {'insert': ' as a component to build your own app. '}
                ]
              }
            },
            {
              'type': 'paragraph',
              'data': {'delta': []}
            },
            {
              'type': 'numbered_list',
              'data': {
                'delta': [
                  {
                    'insert': '\n'
                        '\'\n'
                        '            \'     Use / to insert blocks\n'
                        '\'\n'
                        '            \'   '
                  }
                ]
              }
            },
            {
              'type': 'numbered_list',
              'data': {
                'delta': [
                  {
                    'insert': '\n'
                        '\'\n'
                        '            \'     Select text to trigger to the toolbar to format your notes.\n'
                        '\'\n'
                        '            \'   '
                  }
                ]
              }
            },
            {
              'type': 'paragraph',
              'data': {'delta': []}
            },
            {
              'type': 'paragraph',
              'data': {
                'delta': [
                  {
                    'insert':
                        'If you have questions or feedback, please submit an issue on Github or join the community along with 1000+ builders!'
                  }
                ]
              }
            },
            {
              'type': 'paragraph',
              'data': {
                'delta': [
                  {
                    'insert': '\n'
                        '\'\n'
                        '            \' \n'
                        '\'\n'
                        '            \' \n'
                        '\'\n'
                        '            \' \n'
                        '\'\n'
                        '            \' \n'
                        '\'\n'
                        '            \' \n'
                        '\'\n'
                        '            \' \n'
                        '\'\n'
                        '            \' \n'
                        '\'\n'
                        '            \' \n'
                        '\'\n'
                        '            \' \n'
                        '\'\n'
                        '            \' '
                  }
                ]
              }
            }
          ]
        }
      };
      final result = DocumentHTMLEncoder().convert(Document.fromJson(delta));

      expect(result, example);
    });
  });
}
