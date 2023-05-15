import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/base_component/widget/nested_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ParagraphBlockKeys {
  ParagraphBlockKeys._();

  static const String type = 'paragraph';

  static const String delta = 'delta';

  static const String backgroundColor = blockComponentBackgroundColor;
}

Node paragraphNode({
  String? text,
  Attributes? attributes,
  Iterable<Node> children = const [],
}) {
  attributes ??= {
    ParagraphBlockKeys.delta: (Delta()..insert(text ?? '')).toJson(),
  };
  return Node(
    type: ParagraphBlockKeys.type,
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

  @override
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
    with
        SelectableMixin,
        DefaultSelectable,
        BlockComponentConfigurable,
        BackgroundColorMixin {
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
    return node.children.isEmpty
        ? buildBulletListBlockComponent(context)
        : buildBulletListBlockComponentWithChildren(context);
  }

  Widget buildBulletListBlockComponentWithChildren(BuildContext context) {
    return Container(
      color: backgroundColor.withOpacity(0.5),
      child: NestedListWidget(
        children: editorState.renderer.buildList(
          context,
          widget.node.children,
        ),
        child: buildBulletListBlockComponent(context),
      ),
    );
  }

  Widget buildBulletListBlockComponent(BuildContext context) {
    return Container(
      color: node.children.isEmpty ? backgroundColor : null,
      // padding: padding,
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
