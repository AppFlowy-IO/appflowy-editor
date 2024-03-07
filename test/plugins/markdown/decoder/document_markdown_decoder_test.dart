import 'dart:convert';

import 'package:appflowy_editor/src/plugins/markdown/decoder/document_markdown_decoder.dart';
import 'package:appflowy_editor/src/plugins/markdown/decoder/parser/custom_node_parser.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;

import '../custom_parsers/test_custom_node_parsers.dart';
import '../custom_parsers/test_custom_parser.dart';

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
        "children": [
          {
            "type": "table/cell",
            "data": {
              "colPosition": 0,
              "rowPosition": 0,
              "width": 80,
              "height": 40
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
              "rowPosition": 1,
              "width": 80,
              "height": 40
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
              "rowPosition": 0,
              "width": 80,
              "height": 40
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
              "rowPosition": 1,
              "width": 80,
              "height": 40
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
        ],
        "data": {
          "colsLen": 2,
          "rowsLen": 2,
          "colDefaultWidth": 80.0,
          "rowDefaultHeight": 40.0,
          "colMinimumWidth": 40.0
        }
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
          "delta": []
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
                    "insert": "[Example file.pdf](path/to/file.pdf)"
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
        "type": "image",
        "data": {
            "url": "path/to/image.png",
            "align": "center"
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
    const example2 = '''
{
  "document": {
    "type": "page",
    "children": [
      {
        "type": "heading",
        "data": {
          "level": 1,
          "delta": [
            {
              "insert": "Welcome to AppFlowy"
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
        "type": "code",
        "data": {
          "delta": [
            {
              "insert": "void main(){\\nprint(\\"hello world\\");\\n}"
            }
          ],
          "language": "dart"
        }
      },
      {
        "type": "paragraph",
        "data": {
          "delta": []
        }
      },
      {
        "type": "code",
        "data": {
          "delta": [
            {
              "insert": "void main(){\\n  print(\\"Welcome to AppFlowy\\");\\n}"
            }
          ],
          "language": "dart"
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
              "insert": "``````"
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
        "type": "code",
        "data": {
          "delta": [],
          "language": "dart"
        }
      },
      {
        "type": "paragraph",
        "data": {
          "delta": []
        }
      },
      {
        "type": "code",
        "data": {
          "delta": []
        }
      },
      {
        "type": "paragraph",
        "data": {
          "delta": []
        }
      },
      {
        "type": "code",
        "data": {
          "delta": [
            {
              "insert": "hello world"
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
    const example3 = '''
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
        "type": "paragraph",
        "data": {
          "delta": []
        }
      },
      {
        "type": "code",
        "data": {
          "delta": [
            {
              "insert": "void main(){\\nprint(\\"hello world\\");\\n}"
            }
          ],
          "language": "dart"
        }
      },
      {
        "type": "paragraph",
        "data": {
          "delta": []
        }
      },
      {
        "type": "custom node"
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
              "insert": "Hello "
            },
            {
              "insert": "\$",
              "attributes": {
                "mention": {
                  "type": "page",
                  "page_id": "[AppFlowy Subpage](123456789abcd)"
                }
              }
            },
            {
              "insert": " "
            },
            {
              "insert": "Hello",
              "attributes": {
                "bold": true
              }
            },
            {
              "insert": " "
            },
            {
              "insert": "\$",
              "attributes": {
                "mention": {
                  "type": "page",
                  "page_id": "[AppFlowy Subpage](987654321abcd)"
                }
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
        "type": "heading",
        "data": {
          "delta": [
            {
              "insert": "This is a test for custom "
            },
            {
              "insert": "node",
              "attributes": {
                "bold": true
              }
            },
            {
              "insert": " parser and custom "
            },
            {
              "insert": "inline",
              "attributes": {
                "bold": true
              }
            },
            {
              "insert": " syntaxes"
            }
          ],
          "level": 1
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
        "type": "paragraph",
        "data": {
          "delta": []
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
        "type": "paragraph",
        "data": {
          "delta": []
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
        "type": "paragraph",
        "data": {
          "delta": []
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
      },
      {"type": "paragraph", "data": {"delta": []}}
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
|## a|_c_|
|-|-|
|**b**|d|

> Here is an example you can give a try

You can also use ***AppFlowy Editor*** as a component to build your own app.

* Use / to insert blocks
* Select text to trigger to the toolbar to format your notes.

If you have questions or feedback, please submit an issue on Github or join the community along with 1000+ builders!

1. list item 1
2. list item 2

1 list item 1
2 list item 2

[Example file.pdf](path/to/file.pdf)

![Example image](path/to/image.png)
''';
      final result = DocumentMarkdownDecoder().convert(markdown);
      final data = jsonDecode(example);
      expect(result.toJson(), data);
    });

    test('test code block', () async {
      const markdown = '''
# Welcome to AppFlowy

```dart
void main(){
print("hello world");
}
```

```dart
void main(){
  print("Welcome to AppFlowy");
}
```

``````

```dart
```

```
```

```hello world```
''';
      final result = DocumentMarkdownDecoder().convert(markdown);
      final data = jsonDecode(example2);
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
      final result = DocumentMarkdownDecoder().convert(markdown);
      final data = jsonDecode(example4);
      expect(result.toJson(), data);
    });

    test('decode uncommon markdown table', () async {
      const markdown = r'''
  |  ## \|a|_c_|
      | -- |   -|''';
      const expected = '''
{
  "document": {
              "type": "page",
              "children": [
                {
                  "type": "table",
                  "children": [
                    {
                      "type": "table/cell",
                      "data": {
                        "colPosition": 0,
                        "rowPosition": 0,
                        "height": 40.0,
                        "width": 80.0
                      },
                      "children": [
                        {
                          "type": "heading",
                          "data": {
                            "level": 2,
                            "delta": [
                              {"insert": "|a"}
                            ]
                          }
                        }
                      ]
                    },
                    {
                      "type": "table/cell",
                      "data": {
                        "colPosition": 1,
                        "rowPosition": 0,
                        "height": 40.0,
                        "width": 80.0
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
                    }
                  ],
                  "data": {
                    "colsLen": 2,
                    "rowsLen": 1,
                    "colDefaultWidth": 80.0,
                    "rowDefaultHeight": 40.0,
                    "colMinimumWidth": 40.0
                  }
                }
              ]
            }
}
''';
      final result = DocumentMarkdownDecoder().convert(markdown);
      final data = Map<String, Object>.from(json.decode(expected));

      expect(result.toJson(), data);
    });

    test('custom  parser', () async {
      const markdown = '''
# Welcome to AppFlowy

```dart
void main(){
print("hello world");
}
```

[Custom Node](AppFlowy Subpage 1);

Hello [AppFlowy Subpage](123456789abcd) **Hello** [AppFlowy Subpage](987654321abcd)

# This is a test for custom **node** parser and custom **inline** syntaxes
''';
      List<CustomNodeParser> customNodeParsers = [
        TestCustomNodeParser(),
      ];
      List<md.InlineSyntax> customInlineSyntaxes = [
        TestCustomInlineSyntaxes(),
      ];
      final result = DocumentMarkdownDecoder(
        customNodeParsers: customNodeParsers,
        customInlineSyntaxes: customInlineSyntaxes,
      ).convert(markdown);
      final data = jsonDecode(example3);

      expect(result.toJson(), data);
    });
  });
}
