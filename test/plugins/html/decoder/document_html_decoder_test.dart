import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:appflowy_editor/appflowy_editor.dart';

void main() async {
  group('document_html_decoder_test.dart', () {
    const example = {
      'document': {
        'type': 'document',
        'children': [
          {
            'type': 'heading',
            'attributes': {
              'level': 1,
              'delta': [
                {'insert': 'AppFlowyEditor'}
              ]
            }
          },
          {
            'type': 'heading',
            'attributes': {
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
            'attributes': {
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
            'attributes': {
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
            'attributes': {
              'level': 3,
              'delta': [
                {'insert': 'Features!'}
              ]
            }
          },
          {
            'type': 'numbered_list',
            'attributes': {
              'delta': [
                {'insert': '[x] Customizable'}
              ]
            }
          },
          {
            'type': 'numbered_list',
            'attributes': {
              'delta': [
                {'insert': '[x] Test-covered'}
              ]
            }
          },
          {
            'type': 'numbered_list',
            'attributes': {
              'delta': [
                {'insert': '[ ] more to come!'}
              ]
            }
          },
          {
            'type': 'numbered_list',
            'attributes': {
              'delta': [
                {'insert': 'First item'}
              ]
            }
          },
          {
            'type': 'numbered_list',
            'attributes': {
              'delta': [
                {'insert': 'Second item'}
              ]
            }
          },
          {
            'type': 'paragraph',
            'attributes': {
              'delta': [
                {'insert': 'List element'}
              ]
            }
          },
          {
            'type': 'quote',
            'attributes': {
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
            'attributes': {
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
            'attributes': {
              'level': 3,
              'delta': [
                {'insert': 'Awesome features'}
              ]
            }
          },
          {
            'type': 'paragraph',
            'attributes': {
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
            'attributes': {
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
                  'attributes': {'bold': true, 'strike': true}
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

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    test('parser document', () async {
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
      final result = DocumentHTMLDecoder().convert(rawHTML);

      expect(result.toJson(), example);
    });
  });
}
