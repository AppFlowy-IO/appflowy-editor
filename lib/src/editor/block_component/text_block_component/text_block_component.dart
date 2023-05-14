import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/base_component/widget/nested_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ParagraphBlockKeys {
  ParagraphBlockKeys._();

  static const String type = 'paragraph';

  static const String delta = 'delta';

  static const String backgroundColor = 'bgColor';
}

Node paragraphNode({
  String? text,
  Attributes? attributes,
  Iterable<Node> children = const [],
}) {
  attributes ??= {
    ParagraphBlockKeys.delta: (Delta()..insert(text ?? '')).toJson(),
    ParagraphBlockKeys.backgroundColor: Colors.transparent.toHex(),
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

  Color get backgroundColor {
    final colorString =
        node.attributes[ParagraphBlockKeys.backgroundColor] as String?;
    if (colorString == null) {
      return Colors.transparent;
    }
    return colorString.toColor();
  }

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
    return Container(
      color: backgroundColor,
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
