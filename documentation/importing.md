# Importing data

Currently, we have supported three methods for importing data to initialize AppFlowy Editor.

1. From AppFlowy Document JSON

```dart
const document = r'''{
  "document": {
    "type": "page",
    "children": [
      {
        "type": "heading",
        "data": {
            "delta": [{ "insert": "Hello AppFlowy!" }],
            "level": 1
        }
      }
    ]
  }
}''';
final json = Map<String, Object>.from(jsonDecode(document));
final editorState = EditorState(
  document: Document.fromJson(json),
);
```

2. From Markdown

```dart
const markdown = r'''# Hello AppFlowy!''';
final editorState = EditorState(
  document: markdownToDocument(markdown),
);
```

3. From Quill Delta

```dart
const json = r'''[{"insert":"Hello AppFlowy!"},{"attributes":{"header":1},"insert":"\n"}]''';
final delta = Delta.fromJson(jsonDecode(json));
final document = quillDeltaEncoder.convert(delta);
final editorState = EditorState(document: document);
```

> Notes: Some styles, such as font-size, font-family and text-align, are not supported yet.

For more details, please refer to the function `_importFile` through this [link](https://github.com/AppFlowy-IO/appflowy-editor/blob/main/example/lib/home_page.dart#L298).