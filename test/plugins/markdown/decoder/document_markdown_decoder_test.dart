import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group('document_markdown_decoder.dart', () {
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
          "delta": [
            {
              "insert": "If you have questions or feedback, please submit an issue on Github or join the community along with 1000+ builders!"
            }
          ]
        }
      },
      {
        "type": "numbered_list",
        "data": {
          "delta": [
            {
              "insert": "list item 1"
            }
          ]
        }
      },
      {
        "type": "numbered_list",
        "data": {
          "delta": [
            {
              "insert": "list item 2"
            }
          ]
        }
      },
      {
        "type": "paragraph",
        "data": {
          "delta": [
            {
              "insert": "1 list item 1"
            }
          ]
        }
      },
      {
        "type": "paragraph",
        "data": {
          "delta": [
            {
              "insert": "2 list item 2"
            }
          ]
        }
      },

      {
        "type": "image",
        "data": {
            "url": "path/to/image.png",
            "align": "center"
          }
      }
    ]
  }
}
''';

    const example4 = '''
{
  "document": {
    "type": "page",
    "children": [
      {
        "type": "heading",
        "data": {
          "delta": [
            {
              "insert": "Welcome to AppFlowy"
            }
          ],
          "level": 1
        }
      },
      {
        "type": "heading",
        "data": {
          "delta": [
            {
              "insert": "Tasks"
            }
          ],
          "level": 2
        }
      },
      {
        "type": "bulleted_list",
        "children": [
          {
            "type": "bulleted_list",
            "children": [
              {
                "type": "bulleted_list",
                "data": {
                  "delta": [
                    {
                      "insert": "Task Two"
                    }
                  ]
                }
              }
            ],
            "data": {
              "delta": [
                {
                  "insert": "Task One + Parent"
                }
              ]
            }
          },
          {
            "type": "bulleted_list",
            "data": {
              "delta": [
                {
                  "insert": "Task Three"
                }
              ]
            }
          }
        ],
        "data": {
          "delta": [
            {
              "insert": "Task Parent One"
            }
          ]
        }
      },
      {
        "type": "bulleted_list",
        "data": {
          "delta": [
            {
              "insert": "Task Four"
            }
          ]
        }
      },
      {
        "type": "bulleted_list",
        "data": {
          "delta": [
            {
              "insert": "Task Five"
            }
          ]
        }
      },
      {
        "type": "numbered_list",
        "children": [
          {"type": "numbered_list", "data": {"delta": [{"insert": "Which"}]}},
          {"type": "numbered_list", "data": {"delta": [{"insert": "Is"}]}},
          {"type": "numbered_list", "data": {"delta": [{"insert": "Nested"}]}}
        ],
        "data": {"delta": [{"insert": "Numbered List"}]}
      },
      {
        "type": "numbered_list",
        "data": {"delta": [{"insert": "Back to top level"}]}
      }
    ]
  }
}
''';

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    test('parser document', () async {
      const markdown = '''
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

1. list item 1
2. list item 2

1 list item 1

2 list item 2

![Example image](path/to/image.png)
''';

      final result = markdownToDocument(markdown);
      final data = jsonDecode(example);
      expect(result.toJson(), data);
    });

    test('test nested list', () async {
      const markdown = '''
# Welcome to AppFlowy

## Tasks

- Task Parent One
    - Task One + Parent
      - Task Two
    - Task Three
- Task Four
- Task Five

1. Numbered List
    1. Which
    2. Is
    3. Nested
2. Back to top level
''';
      final result = markdownToDocument(markdown);
      final data = jsonDecode(example4);
      expect(result.toJson(), data);
    });
  });
}
