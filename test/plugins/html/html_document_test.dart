import 'package:flutter_test/flutter_test.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'dart:developer';

void main() {
  group('html_document_test.dart tests', () {
    test('htmlToDocument()', () {
      final document = htmlToDocument(rawHTML);
      expect(document.toJson(), data);
    });
    test('nestedhtmlToDocument()', () {
      final document = htmlToDocument(nestedhtml);
      expect(document.toJson(), nestedDelta);
    });
  });
  group('document_html_test.dart tests', () {
    test('documentToHtml()', () {
      final document = documentToHTML(Document.fromJson(data));

      expect(document, rawHTML);
    });
    test('nesteddocumentToHtml()', () {
      final document = documentToHTML(Document.fromJson(nestedDelta));

      expect(document, nestedhtml);
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
    '''<h1>AppFlowyEditor</h1><h2>👋 <strong>Welcome to</strong>   <span style="font-weight: bold; font-style: italic">AppFlowy Editor</span></h2><p>AppFlowy Editor is a <strong>highly customizable</strong>   <i>rich-text editor</i></p><p>   <u>Here</u> is an example <del>your</del> you can give a try</p><p>   <span style="font-weight: bold; font-style: italic">Span element</span></p><p>   <u>Span element two</u></p><p>   <span style="font-weight: bold; text-decoration: line-through">Span element three</span></p><p>   <a href="https://appflowy.io">This is an anchor tag!</a></p><h3>Features!</h3><ul><li>[x] Customizable</li><li>[x] Test-covered</li><li>[ ] more to come!</li><li>First item</li><li>Second item</li><li>List element</li></ul><blockquote>This is a quote!</blockquote><p><code> Code block</code></p><p>   <i>Italic one</i></p><p>   <i>Italic two</i></p><p>   <strong>Bold tag</strong></p><p>You can also use <span style="font-weight: bold; font-style: italic">AppFlowy Editor</span> as a component to build your own app. </p><h3>Awesome features</h3><p>If you have questions or feedback, please submit an issue on Github or join the community along with 1000+ builders!</p><p></p><p></p>''';

const nestedhtml =
    '''<h1>Welcome to the playground</h1><blockquote>In case you were wondering what the black box at the bottom is – it\'s the debug view, showing the current state of the editor. You can disable it by pressing on the settings control in the bottom-left of your screen and toggling the debug view setting. The playground is a demo environment built with <code>@lexical/react</code>. Try typing in <strong>some text</strong> with <i>different</i> formats.</blockquote><p>\t</p><img src="https://richtexteditor.com/images/editor-image.png"><p>Make sure to check out the various plugins in the toolbar. You can also use #hashtags or @-mentions too!</p><p></p><p>If you\'d like to find out more about Lexical, you can:</p><ul><li>Visit the <a href="https://lexical.dev/">Lexical website</a> for documentation and more information.</li><li>\t<span><img src="https://richtexteditor.com/images/editor-image.png"></span></li><li>Check out the code on our <a href="https://github.com/facebook/lexical">GitHub repository</a>.</li><li>Playground code can be found <a href="https://github.com/facebook/lexical/tree/main/packages/lexical-playground">here</a>.</li><li>Join our <a href="https://discord.com/invite/KmG4wQnnD9">Discord Server</a> and chat with the team.</li><li>Playground code can be found <a href="https://github.com/facebook/lexical/tree/main/packages/lexical-playground">here</a>.</li></ul><p>Lastly, we\'re constantly adding cool new features to this playground. So make sure you check back here when you next get a chance 🙂.</p><p></p>''';
const nestedDelta = {
  'document': {
    'type': 'page',
    'children': [
      {
        'type': 'heading',
        'data': {
          'level': 1,
          'delta': [
            {'insert': 'Welcome to the playground'}
          ]
        }
      },
      {
        'type': 'quote',
        'data': {
          'delta': [
            {
              'insert':
                  'In case you were wondering what the black box at the bottom is – it\'s the debug view, showing the current state of the editor. You can disable it by pressing on the settings control in the bottom-left of your screen and toggling the debug view setting. The playground is a demo environment built with '
            },
            {
              'insert': '@lexical/react',
              'attributes': {'code': true}
            },
            {'insert': '. Try typing in '},
            {
              'insert': 'some text',
              'attributes': {'bold': true}
            },
            {'insert': ' with '},
            {
              'insert': 'different',
              'attributes': {'italic': true}
            },
            {'insert': ' formats.'}
          ]
        }
      },
      {
        'type': 'paragraph',
        'data': {
          'delta': [
            {'insert': '\t'}
          ]
        }
      },
      {
        'type': 'image',
        'data': {
          'url': 'https://richtexteditor.com/images/editor-image.png',
          'align': 'center',
          'height': null,
          'width': null
        }
      },
      {
        'type': 'paragraph',
        'data': {
          'delta': [
            {
              'insert':
                  'Make sure to check out the various plugins in the toolbar. You can also use #hashtags or @-mentions too!'
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
                  'If you\'d like to find out more about Lexical, you can:'
            }
          ]
        }
      },
      {
        'type': 'bulleted_list',
        'data': {
          'delta': [
            {'insert': 'Visit the '},
            {
              'insert': 'Lexical website',
              'attributes': {'href': 'https://lexical.dev/'}
            },
            {'insert': ' for documentation and more information.'}
          ]
        }
      },
      {
        'type': 'bulleted_list',
        'children': [
          {
            'type': 'image',
            'data': {
              'url': 'https://richtexteditor.com/images/editor-image.png',
              'align': 'center',
              'height': null,
              'width': null
            }
          }
        ],
        'data': {
          'delta': [
            {'insert': '\t'}
          ]
        }
      },
      {
        'type': 'bulleted_list',
        'data': {
          'delta': [
            {'insert': 'Check out the code on our '},
            {
              'insert': 'GitHub repository',
              'attributes': {'href': 'https://github.com/facebook/lexical'}
            },
            {'insert': '.'}
          ]
        }
      },
      {
        'type': 'bulleted_list',
        'data': {
          'delta': [
            {'insert': 'Playground code can be found '},
            {
              'insert': 'here',
              'attributes': {
                'href':
                    'https://github.com/facebook/lexical/tree/main/packages/lexical-playground'
              }
            },
            {'insert': '.'}
          ]
        }
      },
      {
        'type': 'bulleted_list',
        'data': {
          'delta': [
            {'insert': 'Join our '},
            {
              'insert': 'Discord Server',
              'attributes': {'href': 'https://discord.com/invite/KmG4wQnnD9'}
            },
            {'insert': ' and chat with the team.'}
          ]
        }
      },
      {
        'type': 'bulleted_list',
        'data': {
          'delta': [
            {'insert': 'Playground code can be found '},
            {
              'insert': 'here',
              'attributes': {
                'href':
                    'https://github.com/facebook/lexical/tree/main/packages/lexical-playground'
              }
            },
            {'insert': '.'}
          ]
        }
      },
      {
        'type': 'paragraph',
        'data': {
          'delta': [
            {
              'insert':
                  'Lastly, we\'re constantly adding cool new features to this playground. So make sure you check back here when you next get a chance 🙂.'
            }
          ]
        }
      },
      {
        'type': 'paragraph',
        'data': {'delta': []}
      }
    ]
  }
};
