import 'dart:convert';

import 'package:appflowy_editor/src/plugins/markdown/decoder/document_markdown_decoder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group('document_markdown_decoder.dart', () {
    const example = '''
{
  "document": {
              "type": "editor",
              "children": [
                {
                  "type": "text",
                  "attributes": {"subtype": "heading", "heading": "h2"},
                  "delta": [
                    {"insert": "👋 "},
                    {"insert": "Welcome to", "attributes": {"bold": true}},
                    {"insert": " "},
                    {
                      "insert": "AppFlowy Editor",
                      "attributes": {"italic": true, "bold": true, "href": "appflowy.io"}
                    }
                  ]
                },
                {"type": "text", "delta": []},
                {
                  "type": "text",
                  "delta": [
                    {"insert": "AppFlowy Editor is a "},
                    {"insert": "highly customizable", "attributes": {"bold": true}},
                    {"insert": " "},
                    {"insert": "rich-text editor", "attributes": {"italic": true}}
                  ]
                },
                {
                  "type": "text",
                  "attributes": {"subtype": "checkbox", "checkbox": true},
                  "delta": [{"insert": "Customizable"}]
                },
                {
                  "type": "text",
                  "attributes": {"subtype": "checkbox", "checkbox": true},
                  "delta": [{"insert": "Test-covered"}]
                },
                {
                  "type": "text",
                  "attributes": {"subtype": "checkbox", "checkbox": false},
                  "delta": [{"insert": "more to come!"}]
                },
                {
                  "type": "table",
                  "attributes": {
                    "colsLen": 2,
                    "rowsLen": 2,
                    "colDefaultWidth": 80.0,
                    "rowDefaultHeight": 40.0,
                    "colMinimumWidth": 40.0
                  },
                  "children": [
                    {
                      "type": "table/cell",
                      "attributes": {
                        "colPosition": 0,
                        "rowPosition": 0,
                        "height": 40.0,
                        "width": 80.0
                      },
                      "children": [
                        {
                          "type": "text",
                          "delta": [
                            {"insert": "## a"}
                          ]
                        }
                      ]
                    },
                    {
                      "type": "table/cell",
                      "attributes": {
                        "colPosition": 0,
                        "rowPosition": 1,
                        "height": 40.0,
                        "width": 80.0
                      },
                      "children": [
                        {
                          "type": "text",
                          "delta": [
                            {
                              "insert": "b",
                              "attributes": {"bold": true}
                            }
                          ]
                        }
                      ]
                    },
                    {
                      "type": "table/cell",
                      "attributes": {
                        "colPosition": 1,
                        "rowPosition": 0,
                        "height": 40.0,
                        "width": 80.0
                      },
                      "children": [
                        {
                          "type": "text",
                          "delta": [
                            {
                              "insert": "c",
                              "attributes": {"italic": true}
                            }
                          ]
                        }
                      ]
                    },
                    {
                      "type": "table/cell",
                      "attributes": {
                        "colPosition": 1,
                        "rowPosition": 1,
                        "height": 40.0,
                        "width": 80.0
                      },
                      "children": [
                        {
                          "type": "text",
                          "delta": [
                            {"insert": "d"}
                          ]
                        }
                      ]
                    }
                  ]
                },
                {"type": "text", "delta": []},
                {
                  "type": "text",
                  "attributes": {"subtype": "quote"},
                  "delta": [{"insert": "Here is an example you can give a try"}]
                },
                {"type": "text", "delta": []},
                {
                  "type": "text",
                  "delta": [
                    {"insert": "You can also use "},
                    {
                      "insert": "AppFlowy Editor",
                      "attributes": {"italic": true, "bold": true}
                    },
                    {"insert": " as a component to build your own app."}
                  ]
                },
                {"type": "text", "delta": []},
                {
                  "type": "text",
                  "attributes": {"subtype": "bulleted-list"},
                  "delta": [{"insert": "Use / to insert blocks"}]
                },
                {
                  "type": "text",
                  "attributes": {"subtype": "bulleted-list"},
                  "delta": [
                    {
                      "insert": "Select text to trigger to the toolbar to format your notes."
                    }
                  ]
                },
                {"type": "text", "delta": []},
                {
                  "type": "text",
                  "delta": [
                    {
                      "insert": "If you have questions or feedback, please submit an issue on Github or join the community along with 1000+ builders!"
                    }
                  ]
                },
                {"type": "text", "delta": []},
                {"type": "text", "delta": [{"insert": ""}]}
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
      final data = Map<String, Object>.from(json.decode(example));
      expect(result.toJson(), data);
    });

    test('parser document', () async {
      const markdown = r'''
  |  ## \|a|_c_|
      | -- |   -|''';
      const expected = '''
{
  "document": {
              "type": "editor",
              "children": [
                {
                  "type": "table",
                  "attributes": {
                    "colsLen": 2,
                    "rowsLen": 1,
                    "colDefaultWidth": 80.0,
                    "rowDefaultHeight": 40.0,
                    "colMinimumWidth": 40.0
                  },
                  "children": [
                    {
                      "type": "table/cell",
                      "attributes": {
                        "colPosition": 0,
                        "rowPosition": 0,
                        "height": 40.0,
                        "width": 80.0
                      },
                      "children": [
                        {
                          "type": "text",
                          "delta": [
                            {"insert": "## |a"}
                          ]
                        }
                      ]
                    },
                    {
                      "type": "table/cell",
                      "attributes": {
                        "colPosition": 1,
                        "rowPosition": 0,
                        "height": 40.0,
                        "width": 80.0
                      },
                      "children": [
                        {
                          "type": "text",
                          "delta": [
                            {
                              "insert": "c",
                              "attributes": {"italic": true}
                            }
                          ]
                        }
                      ]
                    }
                  ]
                },
                {"type": "text", "delta": [{"insert": ""}]}
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
