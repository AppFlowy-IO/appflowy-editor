import 'package:flutter_test/flutter_test.dart';
import 'package:appflowy_editor/appflowy_editor.dart';

void main() {
  group('html_document_test.dart tests', () {
    test('htmlToDocument()', () {
      final document = htmlToDocument(rawHTML);
      expect(document.toJson(), data);
    });
  });
  group('document_html_test.dart tests', () {
    test('documentToHtml()', () {
      final document = documentToHTML(Document.fromJson(data));
      expect(document, rawHTML);
    });
  });
}

const data = {
  'document': {
    'type': 'page',
    'children': [
      {
        'type': 'heading',
        'data': {
          'level': 1,
          'delta': [
            {'insert': 'AppFlowyEditor'}
          ]
        }
      },
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
            {'insert': '   '},
            {
              'insert': 'AppFlowy Editor',
              'attributes': {'bold': true, 'italic': true}
            }
          ]
        }
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
            {'insert': '   '},
            {
              'insert': 'rich-text editor',
              'attributes': {'italic': true}
            }
          ]
        }
      },
      {
        'type': 'paragraph',
        'data': {
          'delta': [
            {'insert': '   '},
            {
              'insert': 'Here',
              'attributes': {'underline': true}
            },
            {'insert': ' is an example '},
            {
              'insert': 'your',
              'attributes': {'strikethrough': true}
            },
            {'insert': ' you can give a try'}
          ]
        }
      },
      {
        'type': 'paragraph',
        'data': {
          'delta': [
            {'insert': '   '},
            {
              'insert': 'Span element',
              'attributes': {'bold': true, 'italic': true}
            }
          ]
        }
      },
      {
        'type': 'paragraph',
        'data': {
          'delta': [
            {'insert': '   '},
            {
              'insert': 'Span element two',
              'attributes': {'underline': true}
            }
          ]
        }
      },
      {
        'type': 'paragraph',
        'data': {
          'delta': [
            {'insert': '   '},
            {
              'insert': 'Span element three',
              'attributes': {'bold': true, 'strikethrough': true}
            }
          ]
        }
      },
      {
        'type': 'paragraph',
        'data': {
          'delta': [
            {'insert': '   '},
            {
              'insert': 'This is an anchor tag!',
              'attributes': {'href': 'https://appflowy.io'}
            }
          ]
        }
      },
      {
        'type': 'heading',
        'data': {
          'level': 3,
          'delta': [
            {'insert': 'Features!'}
          ]
        }
      },
      {
        'type': 'bulleted_list',
        'data': {
          'delta': [
            {'insert': '[x] Customizable'}
          ]
        }
      },
      {
        'type': 'bulleted_list',
        'data': {
          'delta': [
            {'insert': '[x] Test-covered'}
          ]
        }
      },
      {
        'type': 'bulleted_list',
        'data': {
          'delta': [
            {'insert': '[ ] more to come!'}
          ]
        }
      },
      {
        'type': 'bulleted_list',
        'data': {
          'delta': [
            {'insert': 'First item'}
          ]
        }
      },
      {
        'type': 'bulleted_list',
        'data': {
          'delta': [
            {'insert': 'Second item'}
          ]
        }
      },
      {
        'type': 'bulleted_list',
        'data': {
          'delta': [
            {'insert': 'List element'}
          ]
        }
      },
      {
        'type': 'quote',
        'data': {
          'delta': [
            {'insert': 'This is a quote!'}
          ]
        }
      },
      {
        'type': 'paragraph',
        'data': {
          'delta': [
            {
              'insert': ' Code block',
              'attributes': {'code': true}
            }
          ]
        }
      },
      {
        'type': 'paragraph',
        'data': {
          'delta': [
            {'insert': '   '},
            {
              'insert': 'Italic one',
              'attributes': {'italic': true}
            }
          ]
        }
      },
      {
        'type': 'paragraph',
        'data': {
          'delta': [
            {'insert': '   '},
            {
              'insert': 'Italic two',
              'attributes': {'italic': true}
            }
          ]
        }
      },
      {
        'type': 'paragraph',
        'data': {
          'delta': [
            {'insert': '   '},
            {
              'insert': 'Bold tag',
              'attributes': {'bold': true}
            }
          ]
        }
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
        'type': 'heading',
        'data': {
          'level': 3,
          'delta': [
            {'insert': 'Awesome features'}
          ]
        }
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
        'data': {'delta': []}
      },
      {
        'type': 'paragraph',
        'data': {'delta': []}
      }
    ]
  }
};
const rawHTML =
    '''<h1>AppFlowyEditor</h1><h2>👋 <strong>Welcome to</strong>   <span style="font-weight: bold; font-style: italic">AppFlowy Editor</span></h2><p>AppFlowy Editor is a <strong>highly customizable</strong>   <i>rich-text editor</i></p><p>   <u>Here</u> is an example <del>your</del> you can give a try</p><p>   <span style="font-weight: bold; font-style: italic">Span element</span></p><p>   <u>Span element two</u></p><p>   <span style="font-weight: bold; text-decoration: line-through">Span element three</span></p><p>   <a href="https://appflowy.io">This is an anchor tag!</a></p><h3>Features!</h3><ul><li><p>[x] Customizable</p></li><li><p>[x] Test-covered</p></li><li><p>[ ] more to come!</p></li><li><p>First item</p></li><li><p>Second item</p></li><li><p>List element</p></li></ul><blockquote><p>This is a quote!</p></blockquote><p><code> Code block</code></p><p>   <i>Italic one</i></p><p>   <i>Italic two</i></p><p>   <strong>Bold tag</strong></p><p>You can also use <span style="font-weight: bold; font-style: italic">AppFlowy Editor</span> as a component to build your own app. </p><h3>Awesome features</h3><p>If you have questions or feedback, please submit an issue on Github or join the community along with 1000+ builders!</p><p></p><p></p>''';
