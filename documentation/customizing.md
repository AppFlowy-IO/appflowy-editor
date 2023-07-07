# Customizing Editor Features

## Customizing a Shortcut Event

We will use a simple example to illustrate how to quickly add a shortcut event.

In this example, text that starts and ends with an underscore ( \_ ) character will be rendered in italics for emphasis.  So typing `_xxx_` will automatically be converted into _xxx_.

Let's start with a blank document:

```dart
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class UnderScoreToItalic extends StatelessWidget {
  const UnderScoreToItalic({super.key});

  @override
  Widget build(BuildContext context) {
    return AppFlowyEditor.custom(
      editorState: EditorState.blank(withInitialText: true),
      blockComponentBuilders: standardBlockComponentBuilderMap,
      characterShortcutEvents: const [],
    );
  }
}
```

At this point, nothing magic will happen after typing `_xxx_`.

![Before](./images/customize_a_shortcut_event_before.gif)

To implement our shortcut event we will create a `CharacterShortcutEvent` instance to handle an underscore input.

We need to define `key` and `character` in a `CharacterShortcutEvent` object to customize hotkeys. We recommend using the description of your event as a key. For example, if the underscore `_` is defined to make text italic, the key can be 'Underscore to italic'.


```dart
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

// ...

CharacterShortcutEvent underscoreToItalicEvent = CharacterShortcutEvent(
  key: 'Underscore to italic',
  character: '_',
  handler: (editorState) async => handleFormatByWrappingWithSingleCharacter(
    editorState: editorState,
    character: '_',
    formatStyle: FormatStyleByWrappingWithSingleChar.italic,
  ),
);
```

Now our 'underscore handler' function is done and the only task left is to inject it into the AppFlowyEditor.

```dart
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class UnderScoreToItalic extends StatelessWidget {
  const UnderScoreToItalic({super.key});

  @override
  Widget build(BuildContext context) {
    return AppFlowyEditor.custom(
      editorState: EditorState.blank(withInitialText: true),
      blockComponentBuilders: standardBlockComponentBuilderMap,
      characterShortcutEvents: [
        underScoreToItalicEvent,
      ],
    );
  }
}

CharacterShortcutEvent underScoreToItalicEvent = CharacterShortcutEvent(
  key: 'Underscore to italic',
  character: '_',
  handler: (editorState) async => handleFormatByWrappingWithSingleCharacter(
    editorState: editorState,
    character: '_',
    formatStyle: FormatStyleByWrappingWithSingleChar.italic,
  ),
);
```

![After](./images/customize_a_shortcut_event_after.gif)

Check out the [complete code](https://github.com/AppFlowy-IO/appflowy-editor/blob/main/example/lib/samples/underscore_to_italic.dart) file of this example.


## Customizing a Component

> ⚠️ Notes: The content below is outdated.

We will use a simple example to show how to quickly add a custom component.

In this example we will render an image from the network.

Let's start with a blank document:

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      alignment: Alignment.topCenter,
      child: AppFlowyEditor(
        editorState: EditorState.empty(),
        shortcutEvents: const [],
        customBuilders: const {},
      ),
    ),
  );
}
```

Next, we will choose a unique string for your custom node's type.

We'll use `network_image` in this case. And we add `network_image_src` to the `attributes` to describe the link of the image.

```JSON
{
  "type": "network_image",
  "data": {
    "network_image_src": "https://docs.flutter.dev/assets/images/dash/dash-fainting.gif"
  }
}
```

Then, we create a class that inherits [NodeWidgetBuilder](../lib/src/service/render_plugin_service.dart). As shown in the autoprompt, we need to implement two functions:
1. one returns a widget
2. the other verifies the correctness of the [Node](../lib/src/core/document/node.dart).


```dart
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class NetworkImageNodeWidgetBuilder extends NodeWidgetBuilder {
  @override
  Widget build(NodeWidgetContext<Node> context) {
    throw UnimplementedError();
  }

  @override
  NodeValidator<Node> get nodeValidator => throw UnimplementedError();
}
```

Now, let's implement a simple image widget based on `Image`.

Note that the `State` object that is returned by the `Widget` must implement [Selectable](../lib/src/render/selection/selectable.dart) using the `with` keyword.

```dart
class _NetworkImageNodeWidget extends StatefulWidget {
  const _NetworkImageNodeWidget({
    Key? key,
    required this.node,
  }) : super(key: key);

  final Node node;

  @override
  State<_NetworkImageNodeWidget> createState() =>
      __NetworkImageNodeWidgetState();
}

class __NetworkImageNodeWidgetState extends State<_NetworkImageNodeWidget>
    with SelectableMixin {
  RenderBox get _renderBox => context.findRenderObject() as RenderBox;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      widget.node.attributes['network_image_src'],
      height: 200,
      loadingBuilder: (context, child, loadingProgress) =>
          loadingProgress == null ? child : const CircularProgressIndicator(),
    );
  }

  @override
  Position start() => Position(path: widget.node.path, offset: 0);

  @override
  Position end() => Position(path: widget.node.path, offset: 1);

  @override
  Position getPositionInOffset(Offset start) => end();

  @override
  List<Rect> getRectsInSelection(Selection selection) =>
      [Offset.zero & _renderBox.size];

  @override
  Selection getSelectionInRange(Offset start, Offset end) => Selection.single(
        path: widget.node.path,
        startOffset: 0,
        endOffset: 1,
      );

  @override
  Offset localToGlobal(Offset offset) => _renderBox.localToGlobal(offset);
}
```

Finally, we return `_NetworkImageNodeWidget` in the `build` function of `NetworkImageNodeWidgetBuilder`...

```dart
class NetworkImageNodeWidgetBuilder extends NodeWidgetBuilder {
  @override
  Widget build(NodeWidgetContext<Node> context) {
    return _NetworkImageNodeWidget(
      key: context.node.key,
      node: context.node,
    );
  }

  @override
  NodeValidator<Node> get nodeValidator => (node) {
        return node.type == 'network_image' &&
            node.attributes['network_image_src'] is String;
      };
}
```

... and register `NetworkImageNodeWidgetBuilder` in the `AppFlowyEditor`.

```dart
final editorState = EditorState(
  document: StateTree.empty()
    ..insert(
      [0],
      [
        TextNode.empty(),
        Node.fromJson({
          'type': 'network_image',
          'attributes': {
            'network_image_src':
                'https://docs.flutter.dev/assets/images/dash/dash-fainting.gif'
          }
        })
      ],
    ),
);
return AppFlowyEditor(
  editorState: editorState,
  shortcutEvents: const [],
  customBuilders: {
    'network_image': NetworkImageNodeWidgetBuilder(),
  },
);
```

![Whew!](./images/customize_a_component.gif)

Check out the [complete code](https://github.com/AppFlowy-IO/appflowy-editor/blob/main/example/lib/plugin/network_image_node_widget.dart) file of this example.

## Customizing a Theme (New Feature in 0.0.7)

We will use a simple example to illustrate how to quickly customize a theme.

Let's start with a blank document:

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      alignment: Alignment.topCenter,
      child: AppFlowyEditor(
        editorState: EditorState.empty(),
        shortcutEvents: const [],
        customBuilders: const {},
      ),
    ),
  );
}
```

At this point, the editor looks like ...
![Before](./images/customizing_a_theme_before.png)


Next, we will customize the `EditorStyle`.

```dart
ThemeData customizeEditorTheme(BuildContext context) {
  final dark = EditorStyle.dark;
  final editorStyle = dark.copyWith(
    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 150),
    cursorColor: Colors.red.shade600,
    selectionColor: Colors.yellow.shade600.withOpacity(0.5),
    textStyle: GoogleFonts.poppins().copyWith(
      fontSize: 14,
      color: Colors.white,
    ),
    placeholderTextStyle: GoogleFonts.poppins().copyWith(
      fontSize: 14,
      color: Colors.grey.shade400,
    ),
    code: dark.code?.copyWith(
      backgroundColor: Colors.lightBlue.shade200,
      fontStyle: FontStyle.italic,
    ),
    highlightColorHex: '0x60FF0000', // red
  );

  final quote = QuotedTextPluginStyle.dark.copyWith(
    textStyle: (_, __) => GoogleFonts.poppins().copyWith(
      fontSize: 14,
      color: Colors.blue.shade400,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w700,
    ),
  );

  return Theme.of(context).copyWith(extensions: [
    editorStyle,
    ...darkPlguinStyleExtension,
    quote,
  ]);
}
```

Now our 'customize style' function is done and the only task left is to inject it into the AppFlowyEditor.

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      alignment: Alignment.topCenter,
      child: AppFlowyEditor(
        editorState: EditorState.empty(),
        themeData: customizeEditorTheme(context),
        shortcutEvents: const [],
        customBuilders: const {},
      ),
    ),
  );
}
```

![After](./images/customizing_a_theme_after.png)

### Note:

`themeData` has since been depreciated, and you should now use `textStyleConfiguration`. If you would like to use dark mode, the following code will set the text colour to white:

```dart
editorStyle: const EditorStyle.desktop().copyWith(
  textStyleConfiguration: TextStyleConfiguration(
    text: TextStyle(
      color: Theme.of(context).primaryColorLight,
    )
  )
)
```

The above example of `customizeEditorTheme` would turn into the following, which is how AppFlowy customises its editor style:

```dart
EditorStyle desktop() {
  final theme = Theme.of(context);
  final fontSize = context
      .read<DocumentAppearanceCubit>()
      .state
      .fontSize;
  return EditorStyle.desktop(
    padding: padding,
    backgroundColor: theme.colorScheme.surface,
    cursorColor: theme.colorScheme.primary,
    textStyleConfiguration: TextStyleConfiguration(
      text: TextStyle(
        fontFamily: 'Poppins',
        fontSize: fontSize,
        color: theme.colorScheme.onBackground,
        height: 1.5,
      ),
      bold: const TextStyle(
        fontFamily: 'Poppins-Bold',
        fontWeight: FontWeight.w600,
      ),
      italic: const TextStyle(fontStyle: FontStyle.italic),
      underline: const TextStyle(decoration: TextDecoration.underline),
      strikethrough: const TextStyle(decoration: TextDecoration.lineThrough),
      href: TextStyle(
        color: theme.colorScheme.primary,
        decoration: TextDecoration.underline,
      ),
      code: GoogleFonts.robotoMono(
        textStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.normal,
          color: Colors.red,
          backgroundColor: theme.colorScheme.inverseSurface,
        ),
      ),
    ),
  );
}
```
