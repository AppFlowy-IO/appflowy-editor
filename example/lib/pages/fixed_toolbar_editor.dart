import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FixedToolbarExample extends StatefulWidget {
  const FixedToolbarExample({super.key});

  @override
  State<FixedToolbarExample> createState() => _FixedToolbarExampleState();
}

class _FixedToolbarExampleState extends State<FixedToolbarExample> {
  late final Future<EditorState> editorState;

  @override
  void initState() {
    super.initState();

    final jsonString = rootBundle.loadString('assets/example.json');
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
        title: const Text('Fixed Toolbar Example'),
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
              : Column(
                  children: [
                    SizedBox(
                      height: 36,
                      child: _FixedToolbar(
                        editorState: snapshot.data!,
                      ),
                    ),
                    const Divider(),
                    FutureBuilder(
                      future: editorState,
                      builder: (context, snapshot) {
                        return !snapshot.hasData
                            ? const Center(child: CircularProgressIndicator())
                            : Expanded(
                                child: AppFlowyEditor(
                                  editorState: snapshot.data!,
                                ),
                              );
                      },
                    ),
                  ],
                );
        },
      ),
    );
  }
}

class _FixedToolbar extends StatelessWidget {
  const _FixedToolbar({
    required this.editorState,
  });

  final EditorState editorState;

  @override
  Widget build(BuildContext context) {
    final items = [
      Icons.format_bold,
      Icons.format_italic,
      Icons.format_underlined,
      Icons.format_strikethrough,
      Icons.text_fields,
      Icons.format_list_bulleted,
      Icons.format_list_numbered,
      Icons.format_align_left,
      Icons.format_align_center,
      Icons.format_align_right,
      Icons.format_align_justify,
      Icons.link,
      Icons.image,
      Icons.format_quote,
      Icons.code,
      Icons.horizontal_rule,
    ];

    return ValueListenableBuilder(
      valueListenable: editorState.selectionNotifier,
      builder: (context, selection, _) {
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          itemBuilder: (_, index) {
            final isBold = _isTextDecorationActive(
              editorState,
              selection,
              AppFlowyRichTextKeys.bold,
            );
            return IconButton(
              icon: Icon(items[index]),
              color: items[index] == Icons.format_bold && isBold
                  ? Colors.blue
                  : Colors.black,
              onPressed: () {
                debugPrint(items[index].toString());
                switch (items[index]) {
                  case Icons.format_bold:
                    editorState.toggleAttribute(AppFlowyRichTextKeys.bold);
                    break;
                  case Icons.format_italic:
                    editorState.toggleAttribute(AppFlowyRichTextKeys.italic);
                    break;
                  case Icons.format_underlined:
                    editorState.toggleAttribute(AppFlowyRichTextKeys.underline);
                    break;
                  case Icons.format_strikethrough:
                    editorState
                        .toggleAttribute(AppFlowyRichTextKeys.strikethrough);
                    break;
                  case Icons.text_fields:
                    editorState.formatNode(null, (node) {
                      return node.copyWith(
                        type: ParagraphBlockKeys.type,
                      );
                    });
                    break;
                  case Icons.format_list_bulleted:
                    editorState.formatNode(null, (node) {
                      return node.copyWith(
                        type: node.type == BulletedListBlockKeys.type
                            ? ParagraphBlockKeys.type
                            : BulletedListBlockKeys.type,
                      );
                    });
                    break;
                  case Icons.format_list_numbered:
                    editorState.formatNode(null, (node) {
                      return node.copyWith(
                        type: node.type == NumberedListBlockKeys.type
                            ? ParagraphBlockKeys.type
                            : NumberedListBlockKeys.type,
                      );
                    });
                    break;
                  case Icons.format_align_left:
                    editorState.formatNode(null, (node) {
                      return node.copyWith(
                        attributes: {
                          ...node.attributes,
                          blockComponentAlign: 'left',
                        },
                      );
                    });
                    break;
                  case Icons.format_align_center:
                    editorState.formatNode(null, (node) {
                      return node.copyWith(
                        attributes: {
                          ...node.attributes,
                          blockComponentAlign: 'center',
                        },
                      );
                    });
                    break;
                  case Icons.format_align_right:
                    editorState.formatNode(null, (node) {
                      return node.copyWith(
                        attributes: {
                          ...node.attributes,
                          blockComponentAlign: 'right',
                        },
                      );
                    });
                    break;
                  case Icons.horizontal_rule:
                    final selection = editorState.selection;
                    if (selection == null) {
                      return;
                    }
                    final transaction = editorState.transaction;
                    transaction.insertNode(
                      selection.start.path.next,
                      dividerNode(),
                    );
                    editorState.apply(transaction);
                    break;
                  default:
                    break;
                }
              },
            );
          },
          separatorBuilder: (_, __) => const VerticalDivider(),
          itemCount: items.length,
        );
      },
    );
  }

  bool _isTextDecorationActive(
    EditorState editorState,
    Selection? selection,
    String name,
  ) {
    selection = selection ?? editorState.selection;
    if (selection == null) {
      return false;
    }
    final nodes = editorState.getNodesInSelection(selection);
    if (selection.isCollapsed) {
      return editorState.toggledStyle.containsKey(name);
    } else {
      return nodes.allSatisfyInSelection(selection, (delta) {
        return delta.everyAttributes(
          (attributes) => attributes[name] == true,
        );
      });
    }
  }
}
