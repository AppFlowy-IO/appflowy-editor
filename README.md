<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

<h1 align="center"><b>AppFlowy Editor</b></h1>

<p align="center">A highly customizable rich-text editor for Flutter</p>

<p align="center">
    <a href="https://discord.gg/ZCCYN4Anzq"><b>Discord</b></a> •
    <a href="https://twitter.com/appflowy"><b>Twitter</b></a>
</p>

<p align="center">
    <a href="https://codecov.io/github/AppFlowy-IO/appflowy-editor" >
        <img src="https://codecov.io/github/AppFlowy-IO/appflowy-editor/branch/main/graph/badge.svg?token=BXTGUXTWRU"/>
    </a>
</p>

<div align="center">
    <img src="https://github.com/AppFlowy-IO/appflowy-editor/blob/main/documentation/images/showcase.png?raw=true" width = "700" style = "padding: 100">
</div>

## Key Features

* Build rich, intuitive editors
* Design and modify an ever-expanding list of customizable features including
  * block components (such as form input controls, numbered lists, and rich text widgets)
  * shortcut events
  * themes
  * selection menu
  * toolbar menu
* [Test Coverage](https://github.com/AppFlowy-IO/appflowy-editor/blob/main/documentation/testing.md) and ongoing maintenance by AppFlowy's core team and community of more than 1,000 builders

## Getting Started

Add the AppFlowy editor [Flutter package](https://docs.flutter.dev/development/packages-and-plugins/using-packages) to your environment.

```shell
flutter pub add appflowy_editor
flutter pub get
```

## Creating Your First Editor

Start by creating a new empty AppFlowyEditor object.

```dart
final editorState = EditorState.blank(withInitialText: true); // with an empty paragraph
final editor = AppFlowyEditor(
  editorState: editorState,
);
```

You can also create an editor from a JSON object in order to configure your initial state. Or you can [create an editor from Markdown or Quill Delta](https://github.com/AppFlowy-IO/appflowy-editor/blob/main/documentation/importing.md).

```dart
final json = jsonDecode('YOUR INPUT JSON STRING');
final editorState = EditorState(document: Document.fromJson(json));
final editor = AppFlowyEditor(
  editorState: editorState,
);
```

> Note: The parameters `localizationsDelegates` need to be assigned in MaterialApp widget
```dart
MaterialApp(
  localizationsDelegates: const [
    AppFlowyEditorLocalizations.delegate,
  ]，
);
```

To get a sense of how the AppFlowy Editor works, run our example:

```shell
git clone https://github.com/AppFlowy-IO/appflowy-editor.git
flutter pub get
flutter run
```

## Customizing Your Editor

### Customizing theme

Please refer to our documentation on customizing AppFlowy for a detailed discussion about [customizing theme](https://github.com/AppFlowy-IO/appflowy-editor/blob/main/documentation/customizing.md#customizing-a-theme).

 * See further examples of [how AppFlowy custom the theme](https://github.com/AppFlowy-IO/AppFlowy/blob/main/frontend/appflowy_flutter/lib/plugins/document/presentation/editor_style.dart)

### Customizing Block Components

Please refer to our documentation on customizing AppFlowy for a detailed discussion about [customizing components](https://github.com/AppFlowy-IO/appflowy-editor/blob/main/documentation/customizing.md#customize-a-component).

Below are some examples of component customizations:

 * [Todo List Block Component](https://github.com/AppFlowy-IO/appflowy-editor/blob/main/lib/src/editor/block_component/todo_list_block_component/todo_list_block_component.dart) demonstrates how to extend new styles based on existing rich text components
 * [Divider Block Component](https://github.com/AppFlowy-IO/appflowy-editor/blob/main/lib/src/editor/block_component/divider_block_component/divider_block_component.dart) demonstrates how to extend a new block component and render it
 * See further examples of [AppFlowy](https://github.com/AppFlowy-IO/AppFlowy/blob/main/frontend/appflowy_flutter/lib/plugins/document/presentation/editor_page.dart)

### Customizing Shortcut Events

Please refer to our documentation on customizing AppFlowy for a detailed discussion about [customizing shortcut events](https://github.com/AppFlowy-IO/appflowy-editor/blob/main/documentation/customizing.md#customize-a-shortcut-event).

Below are some examples of shortcut event customizations:

 * [BIUS](https://github.com/AppFlowy-IO/appflowy-editor/tree/main/lib/src/editor/editor_component/service/shortcuts/character_shortcut_events/format_single_character) demonstrates how to make text bold/italic/underline/strikethrough through shortcut keys
 * Need more examples? Check out [shortcuts](https://github.com/AppFlowy-IO/appflowy-editor/tree/main/lib/src/editor/editor_component/service/shortcuts)

## Migration Guide
Please refer to the [migration documentation](https://github.com/AppFlowy-IO/appflowy-editor/blob/main/documentation/migration.md).

## Glossary
Please refer to the API documentation.

## Contributing
Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are greatly appreciated.

Please look at [CONTRIBUTING.md](https://appflowy.gitbook.io/docs/essential-documentation/contribute-to-appflowy/contributing-to-appflowy) for details.

## License
All code contributed to the AppFlowy Editor project is dual-licensed, and released under both of the following licenses:
1. The GNU Affero General Public License Version 3
2. The Mozilla Public License, Version 2.0 (the “MPL”)

See [LICENSE](https://github.com/AppFlowy-IO/appflowy-editor/blob/main/LICENSE) for more information.
