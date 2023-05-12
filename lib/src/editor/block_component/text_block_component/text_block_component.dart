import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/base_component/widget/nested_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Node paragraphNode({
  String? text,
  Attributes? attributes,
  Iterable<Node> children = const [],
}) {
  attributes ??= {'delta': (Delta()..insert(text ?? '')).toJson()};
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
    this.configuration = const BlockComponentConfiguration(),
  });

  final BlockComponentConfiguration configuration;

  @override
  Widget build(BlockComponentContext blockComponentContext) {
    final node = blockComponentContext.node;
    return TextBlockComponentWidget(
      node: node,
      key: node.key,
      configuration: configuration,
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
    this.configuration = const BlockComponentConfiguration(),
  });

  final Node node;
  final BlockComponentConfiguration configuration;

  @override
  State<TextBlockComponentWidget> createState() =>
      _TextBlockComponentWidgetState();
}

class _TextBlockComponentWidgetState extends State<TextBlockComponentWidget>
    with SelectableMixin, DefaultSelectable, BlockComponentConfigurable {
  @override
  final forwardKey = GlobalKey(debugLabel: 'flowy_rich_text');

  @override
  GlobalKey<State<StatefulWidget>> get containerKey => widget.node.key;

  @override
  BlockComponentConfiguration get configuration => widget.configuration;

  @override
  Node get node => widget.node;

  late final editorState = Provider.of<EditorState>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    return widget.node.children.isEmpty
        ? buildBulletListBlockComponent(context)
        : buildBulletListBlockComponentWithChildren(context);
  }

  Widget buildBulletListBlockComponentWithChildren(BuildContext context) {
    return NestedListWidget(
      children: editorState.renderer.buildList(
        context,
        widget.node.children,
      ),
      child: buildBulletListBlockComponent(context),
    );
  }

  Widget buildBulletListBlockComponent(BuildContext context) {
    return Padding(
      padding: padding,
      child: FlowyRichText(
        key: forwardKey,
        node: widget.node,
        editorState: editorState,
        placeholderText: placeholderText,
        textSpanDecorator: (textSpan) => textSpan.updateTextStyle(
          textStyle,
        ),
        placeholderTextSpanDecorator: (textSpan) => textSpan.updateTextStyle(
          placeholderTextStyle,
        ),
      ),
    );
  }
}
