import 'dart:convert';

import 'package:appflowy_editor/src/plugins/markdown/decoder/document_markdown_decoder.dart';
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
          "delta": [],
          "language": null
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
          ],
          "language": null
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
  });
}
