import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group('document_markdown_encoder.dart', () {
    const example = '''
{
  "document": {
    "type": "page",
    "children": [
      {
        "type": "heading",
        "data": {
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
        "data": {
          "delta": []
        }
      },
      {
        "type": "paragraph",
        "data": {
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
        "data": {
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
        "data": {
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
        "data": {
          "checked": false,
          "delta": [
            {
              "insert": "more to come!"
            }
          ]
        }
      },
      {
        "type": "table",
        "data": {
          "colsLen": 2,
          "rowsLen": 2,
          "colDefaultWidth": 60,
          "rowDefaultHeight": 50,
          "colMinimumWidth": 30
        },
        "children": [
          {
            "type": "table/cell",
            "data": {
              "colPosition": 0,
              "rowPosition": 0,
              "width": 35
            },
            "children": [
              {
                "type": "heading",
                "data": {
                  "level": 2,
                  "delta": [
                    {"insert": "a"}
                  ]
                }
              }
            ]
          },
          {
            "type": "table/cell",
            "data": {
              "colPosition": 0,
              "rowPosition": 1
            },
            "children": [
              {
                "type": "paragraph",
                "data": {
                  "delta": [
                    {
                      "insert": "b",
                      "attributes": {"bold": true}
                    }
                  ]
                }
              }
            ]
          },
          {
            "type": "table/cell",
            "data": {
              "colPosition": 1,
              "rowPosition": 0
            },
            "children": [
              {
                "type": "paragraph",
                "data": {
                    "delta": [
                    {
                      "insert": "c",
                      "attributes": {"italic": true}
                    }
                  ]
                }
              }
            ]
          },
          {
            "type": "table/cell",
            "data": {
              "colPosition": 1,
              "rowPosition": 1
            },
            "children": [
              {
                "type": "paragraph",
                "data": {
                    "delta": [
                    {"insert": "d"}
                  ]
                }
              }
            ]
          }
        ]
      },
      {
        "type": "paragraph",
        "data": {
          "delta": []
        }
      },
      {
        "type": "quote",
        "data": {
          "delta": [
            {
              "insert": "Here is an example you can give a try"
            }
          ]
        }
      },
      {
        "type": "paragraph",
        "data": {
          "delta": []
        }
      },
      {
        "type": "paragraph",
        "data": {
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
        "data": {
          "delta": []
        }
      },
      {
        "type": "bulleted_list",
        "data": {
          "delta": [
            {
              "insert": "Use / to insert blocks"
            }
          ]
        }
      },
      {
        "type": "bulleted_list",
        "data": {
          "delta": [
            {
              "insert": "Select text to trigger to the toolbar to format your notes."
            }
          ]
        }
      },
      {
        "type": "paragraph",
        "data": {
          "delta": []
        }
      },
      {
        "type": "paragraph",
        "data": {
          "delta": [
            {
              "insert": "If you have questions or feedback, please submit an issue on Github or join the community along with 1000+ builders!"
            }
          ]
        }
      },
      {
        "type": "paragraph",
        "data": {
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
          const TableNodeParser(),
        ],
      ).convert(document);
      expect(result, '''
## 👋 **Welcome to** ***[AppFlowy Editor](appflowy.io)***

AppFlowy Editor is a **highly customizable** _rich-text editor_
- [x] Customizable
- [x] Test-covered
- [ ] more to come!
|## a|_c_|
|-|-|
|**b**|d|

> Here is an example you can give a try

You can also use ***AppFlowy Editor*** as a component to build your own app.

* Use / to insert blocks
* Select text to trigger to the toolbar to format your notes.

If you have questions or feedback, please submit an issue on Github or join the community along with 1000+ builders!

''');
    });
  });
}
