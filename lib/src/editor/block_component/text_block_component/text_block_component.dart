import 'dart:collection';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/base_component/widget/nested_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Node paragraphNode({
  Attributes? attributes,
  LinkedList<Node>? children,
}) {
  attributes ??= {'delta': Delta().toJson()};
  return Node(
    type: 'paragraph',
    attributes: {
      ...attributes,
    },
    children: children,
  );
}

class TextBlockComponentBuilder extends BlockComponentBuilder {
  TextBlockComponentBuilder({
    this.padding = const EdgeInsets.all(0.0),
    this.textStyle = const TextStyle(),
  });

  final EdgeInsets padding;
  final TextStyle textStyle;

  @override
  Widget build(BlockComponentContext blockComponentContext) {
    final node = blockComponentContext.node;
    return TextBlockComponentWidget(
      node: node,
      key: node.key,
      padding: padding,
      textStyle: textStyle,
    );
  }

  @override
  bool validate(Node node) {
    return node.delta != null;
  }
}

class TextBlockComponentWidget extends StatefulWidget {
  const TextBlockComponentWidget({
    super.key,
    required this.node,
    this.padding = const EdgeInsets.all(0.0),
    this.textStyle = const TextStyle(),
  });

  final Node node;
  final EdgeInsets padding;
  final TextStyle textStyle;

  @override
  State<TextBlockComponentWidget> createState() =>
      _TextBlockComponentWidgetState();
}

class _TextBlockComponentWidgetState extends State<TextBlockComponentWidget>
    with SelectableMixin, DefaultSelectable {
  @override
  final forwardKey = GlobalKey(debugLabel: 'flowy_rich_text');
  late final editorState = Provider.of<EditorState>(context, listen: false);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.node.children.isEmpty) {
      return buildBulletListBlockComponent(context);
    } else {
      return buildBulletListBlockComponentWithChildren(context);
    }
  }

  Widget buildBulletListBlockComponentWithChildren(BuildContext context) {
    return NestedListWidget(
      children: editorState.renderer
          .buildList(
            context,
            widget.node.children.toList(growable: false),
          )
          .toList(),
      child: buildBulletListBlockComponent(context),
    );
  }

  Widget buildBulletListBlockComponent(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: FlowyRichText(
        key: forwardKey,
        node: widget.node,
        editorState: editorState,
      ),
    );
  }
}
