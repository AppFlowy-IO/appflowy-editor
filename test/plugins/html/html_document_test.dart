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
      final document = documentToHTML(Document.fromJson(encoderdelta));
      expect(document, encoderRawHtml);
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
            {'insert': ' '},
            {
              'insert': 'AppFlowy Editor',
              'attributes': {
                'bold': true,
                'italic': true,
                'href': 'appflowy.io'
              }
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
            {'insert': ' '},
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
        'type': 'numbered_list',
        'data': {
          'delta': [
            {'insert': 'First item'}
          ]
        }
      },
      {
        'type': 'numbered_list',
        'data': {
          'delta': [
            {'insert': 'Second item'}
          ]
        }
      },
      {
        'type': 'paragraph',
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
            {
              'insert': '\n'
                  '  This is a quote!\n'
                  ''
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
            {'insert': ' as a component to build your own app.'}
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
        'data': {
          'delta': [
            {
              'insert': '\n'
                  '\n'
                  '  \n'
                  '\n'
                  '\n'
                  '\n'
                  '\n'
                  '\n'
                  ''
            },
            {
              'insert': 'Span element',
              'attributes': {'bold': true, 'italic': true}
            },
            {
              'insert': '\n'
                  '\n'
                  ''
            },
            {
              'insert': 'Span element two',
              'attributes': {'underline': true}
            },
            {
              'insert': '\n'
                  '\n'
                  ''
            },
            {
              'insert': 'Span element three',
              'attributes': {'bold': true, 'strikethrough': true}
            },
            {
              'insert': '\n'
                  '\n'
                  ''
            },
            {
              'insert': 'This is an anchor tag!',
              'attributes': {'href': 'https://appflowy.io'}
            },
            {
              'insert': '\n'
                  '\n'
                  '\n'
                  '\n'
                  '\n'
                  '\n'
                  '\n'
                  '\n'
                  '\n'
                  '\n'
                  '\n'
                  '\n'
                  '\n'
                  '\n'
                  ''
            },
            {
              'insert': '\n'
                  '  Code block\n'
                  '',
              'attributes': {'code': true}
            },
            {
              'insert': '\n'
                  '\n'
                  ''
            },
            {
              'insert': 'Italic one',
              'attributes': {'italic': true}
            },
            {'insert': ' '},
            {
              'insert': 'Italic two',
              'attributes': {'italic': true}
            },
            {
              'insert': '\n'
                  '\n'
                  ''
            },
            {
              'insert': 'Bold tag',
              'attributes': {'bold': true}
            },
            {
              'insert': '\n'
                  '\n'
                  '\n'
                  '\n'
                  '\n'
                  ''
            }
          ]
        }
      }
    ]
  }
};
const rawHTML = """<h1>AppFlowyEditor</h1>
<h2>👋 <strong>Welcome to</strong> <strong><em><a href="appflowy.io">AppFlowy Editor</a></em></strong></h2>
  <p>AppFlowy Editor is a <strong>highly customizable</strong> <em>rich-text editor</em></p>

<hr />

<p><u>Here</u> is an example <del>your</del> you can give a try</p>

<span style="font-weight: bold;background-color: #cccccc;font-style: italic;">Span element</span>

<span style="font-weight: medium;text-decoration: underline;">Span element two</span>

<span style="font-weight: 900;text-decoration: line-through;">Span element three</span>

<a href="https://appflowy.io">This is an anchor tag!</a>

<img src="https://images.squarespace-cdn.com/content/v1/617f6f16b877c06711e87373/c3f23723-37f4-44d7-9c5d-6e2a53064ae7/Asset+10.png?format=1500w" />

<h3>Features!</h3>

<ul>
  <li>[x] Customizable</li>
  <li>[x] Test-covered</li>
  <li>[ ] more to come!</li>
</ul>

<ol>
  <li>First item</li>
  <li>Second item</li>
</ol>

<li>List element</li>

<blockquote>
  <p>This is a quote!</p>
</blockquote>

<code>
  Code block
</code>

<em>Italic one</em> <i>Italic two</i>

<b>Bold tag</b>
<img src="http://appflowy.io" alt="AppFlowy">
<p>You can also use <strong><em>AppFlowy Editor</em></strong> as a component to build your own app.</p>
<h3>Awesome features</h3>
<p>If you have questions or feedback, please submit an issue on Github or join the community along with 1000+ builders!</p>
<hr>""";

const encoderRawHtml = """<h2>👋 <strong>Welcome to</strong>\n'
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
const encoderdelta = {
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
