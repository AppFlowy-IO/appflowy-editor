import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomizeThemeForEditor extends StatefulWidget {
  const CustomizeThemeForEditor({super.key});

  @override
  State<CustomizeThemeForEditor> createState() =>
      _CustomizeThemeForEditorState();
}

class _CustomizeThemeForEditorState extends State<CustomizeThemeForEditor> {
  late final Future<EditorState> editorState;

  @override
  void initState() {
    super.initState();

    final jsonString = PlatformExtension.isDesktopOrWeb
        ? rootBundle.loadString('assets/example.json')
        : rootBundle.loadString('assets/mobile_example.json');
    editorState = jsonString.then((value) {
      return EditorState(
        document: Document.fromJson(
          Map<String, Object>.from(
            json.decode(value),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Custom Theme For Editor'),
        titleTextStyle: const TextStyle(color: Colors.white),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: FutureBuilder(
        future: editorState,
        builder: (context, snapshot) {
          return !snapshot.hasData
              ? const Center(child: CircularProgressIndicator())
              : buildEditor(snapshot.data!);
        },
      ),
    );
  }

  Widget buildEditor(EditorState editorState) {
    return Container(
      color: Colors.grey[900],
      child: AppFlowyEditor(
        editorState: editorState,
        editorStyle: customizeEditorStyle(),
        blockComponentBuilders: customBuilder(),
      ),
    );
  }

  /// custom the block style
  Map<String, BlockComponentBuilder> customBuilder() {
    final configuration = BlockComponentConfiguration(
      padding: (node) {
        if (HeadingBlockKeys.type == node.type) {
          return const EdgeInsets.symmetric(vertical: 30);
        }
        return const EdgeInsets.symmetric(vertical: 10);
      },
      textStyle: (node) {
        if (HeadingBlockKeys.type == node.type) {
          return const TextStyle(color: Colors.yellow);
        }
        return const TextStyle();
      },
    );

    // customize heading block style
    return {
      ...standardBlockComponentBuilderMap,
      // heading block
      HeadingBlockKeys.type: HeadingBlockComponentBuilder(
        configuration: configuration,
      ),
      // todo-list block
      TodoListBlockKeys.type: TodoListBlockComponentBuilder(
        configuration: configuration,
        iconBuilder: (context, node) {
          final checked = node.attributes[TodoListBlockKeys.checked] as bool;
          return Icon(
            checked ? Icons.check_box : Icons.check_box_outline_blank,
            size: 20,
            color: Colors.white,
          );
        },
      ),
      // bulleted list block
      BulletedListBlockKeys.type: BulletedListBlockComponentBuilder(
        configuration: configuration,
        iconBuilder: (context, node) {
          return Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            child: const Icon(
              Icons.circle,
              size: 10,
              color: Colors.red,
            ),
          );
        },
      ),
      // quote block
      QuoteBlockKeys.type: QuoteBlockComponentBuilder(
        configuration: configuration,
        iconBuilder: (context, node) {
          return const EditorSvg(
            width: 20,
            height: 20,
            padding: EdgeInsets.only(right: 5.0),
            name: 'quote',
            color: Colors.pink,
          );
        },
      ),
    };
  }

  /// custom the text style
  EditorStyle customizeEditorStyle() {
    return EditorStyle(
      padding: PlatformExtension.isDesktopOrWeb
          ? const EdgeInsets.only(left: 100, right: 100, top: 20)
          : const EdgeInsets.symmetric(horizontal: 20),
      cursorColor: Colors.green,
      selectionColor: Colors.green.withOpacity(0.5),
      textStyleConfiguration: TextStyleConfiguration(
        text: const TextStyle(
          fontSize: 18.0,
          color: Colors.white,
        ),
        bold: const TextStyle(
          fontWeight: FontWeight.w900,
        ),
        href: TextStyle(
          color: Colors.amber,
          decoration: TextDecoration.combine(
            [
              TextDecoration.overline,
              TextDecoration.underline,
            ],
          ),
        ),
        code: const TextStyle(
          fontSize: 14.0,
          fontStyle: FontStyle.italic,
          color: Colors.blue,
          backgroundColor: Colors.black12,
        ),
      ),
      textSpanDecorator: (context, node, index, text, textSpan) {
        final attributes = text.attributes;
        final href = attributes?[AppFlowyRichTextKeys.href];
        if (href != null) {
          return TextSpan(
            text: text.text,
            style: textSpan.style,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                debugPrint('onTap: $href');
              },
          );
        }
        return textSpan;
      },
    );
  }
}
