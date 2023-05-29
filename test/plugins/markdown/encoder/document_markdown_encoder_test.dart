import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/plugins/markdown/encoder/parser/parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group('document_markdown_encoder.dart', () {
    const example = '''
{
  "document": {
    "type": "document",
    "children": [
      {
        "type": "heading",
        "attributes": {
          "level": 2,
          "delta": [
            {
              "insert": "👋 "
            },
            {
              "insert": "Welcome to",
              "attributes": {
                "bold": true
              }
            },
            {
              "insert": " "
            },
            {
              "insert": "AppFlowy Editor",
              "attributes": {
                "italic": true,
                "bold": true,
                "href": "appflowy.io"
              }
            }
          ]
        }
      },
      {
        "type": "paragraph",
        "attributes": {
          "delta": []
        }
      },
      {
        "type": "paragraph",
        "attributes": {
          "delta": [
            {
              "insert": "AppFlowy Editor is a "
            },
            {
              "insert": "highly customizable",
              "attributes": {
                "bold": true
              }
            },
            {
              "insert": " "
            },
            {
              "insert": "rich-text editor",
              "attributes": {
                "italic": true
              }
            }
          ]
        }
      },
      {
        "type": "todo_list",
        "attributes": {
          "checked": true,
          "delta": [
            {
              "insert": "Customizable"
            }
          ]
        }
      },
      {
        "type": "todo_list",
        "attributes": {
          "checked": true,
          "delta": [
            {
              "insert": "Test-covered"
            }
          ]
        }
      },
      {
        "type": "todo_list",
        "attributes": {
          "checked": false,
          "delta": [
            {
              "insert": "more to come!"
            }
          ]
        }
      },
      {
        "type": "paragraph",
        "attributes": {
          "delta": []
        }
      },
      {
        "type": "quote",
        "attributes": {
          "delta": [
            {
              "insert": "Here is an example you can give a try"
            }
          ]
        }
      },
      {
        "type": "paragraph",
        "attributes": {
          "delta": []
        }
      },
      {
        "type": "paragraph",
        "attributes": {
          "delta": [
            {
              "insert": "You can also use "
            },
            {
              "insert": "AppFlowy Editor",
              "attributes": {
                "italic": true,
                "bold": true
              }
            },
            {
              "insert": " as a component to build your own app."
            }
          ]
        }
      },
      {
        "type": "paragraph",
        "attributes": {
          "delta": []
        }
      },
      {
        "type": "bulleted_list",
        "attributes": {
          "delta": [
            {
              "insert": "Use / to insert blocks"
            }
          ]
        }
      },
      {
        "type": "bulleted_list",
        "attributes": {
          "delta": [
            {
              "insert": "Select text to trigger to the toolbar to format your notes."
            }
          ]
        }
      },
      {
        "type": "paragraph",
        "attributes": {
          "delta": []
        }
      },
      {
        "type": "paragraph",
        "attributes": {
          "delta": [
            {
              "insert": "If you have questions or feedback, please submit an issue on Github or join the community along with 1000+ builders!"
            }
          ]
        }
      },
      {
        "type": "paragraph",
        "attributes": {
          "delta": []
        }
      }
    ]
  }
}
''';
    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    test('parser document', () async {
      final data = Map<String, Object>.from(json.decode(example));
      final document = Document.fromJson(data);
      final result = DocumentMarkdownEncoder(
        parsers: [
          const TextNodeParser(),
          const BulletedListNodeParser(),
          const NumberedListNodeParser(),
          const TodoListNodeParser(),
          const QuoteNodeParser(),
          const CodeBlockNodeParser(),
          const HeadingNodeParser(),
          const ImageNodeParser(),
        ],
      ).convert(document);
      expect(result, '''
## 👋 **Welcome to** ***[AppFlowy Editor](appflowy.io)***

AppFlowy Editor is a **highly customizable** _rich-text editor_
- [x] Customizable
- [x] Test-covered
- [ ] more to come!

> Here is an example you can give a try

You can also use ***AppFlowy Editor*** as a component to build your own app.

* Use / to insert blocks
* Select text to trigger to the toolbar to format your notes.

If you have questions or feedback, please submit an issue on Github or join the community along with 1000+ builders!
''');
    });
  });
}
