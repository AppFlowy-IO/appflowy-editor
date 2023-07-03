import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class ParagraphBlockKeys {
  ParagraphBlockKeys._();

  static const String type = 'paragraph';

  static const String delta = 'delta';

  static const String backgroundColor = blockComponentBackgroundColor;
}

Node paragraphNode({
  String? text,
  Delta? delta,
  Attributes? attributes,
  Iterable<Node> children = const [],
}) {
  attributes ??= {
    ParagraphBlockKeys.delta: (delta ?? (Delta()..insert(text ?? ''))).toJson(),
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
  BlockComponentWidget build(BlockComponentContext blockComponentContext) {
    final node = blockComponentContext.node;
    return TextBlockComponentWidget(
      node: node,
      key: node.key,
      configuration: configuration,
      showActions: showActions(node),
      actionBuilder: (context, state) => actionBuilder(
        blockComponentContext,
        state,
      ),
    );
  }

  @override
  bool validate(Node node) {
    return node.delta != null;
  }
}

class TextBlockComponentWidget extends BlockComponentStatefulWidget {
  const TextBlockComponentWidget({
    super.key,
    required super.node,
    super.showActions,
    super.actionBuilder,
    super.configuration = const BlockComponentConfiguration(),
  });

  @override
  State<TextBlockComponentWidget> createState() =>
      _TextBlockComponentWidgetState();
}

class _TextBlockComponentWidgetState extends State<TextBlockComponentWidget>
    with
        SelectableMixin,
        DefaultSelectable,
        BlockComponentConfigurable,
        BackgroundColorMixin,
        NestedBlockComponentStatefulWidgetMixin {
  @override
  final forwardKey = GlobalKey(debugLabel: 'flowy_rich_text');

  @override
  GlobalKey<State<StatefulWidget>> get containerKey => widget.node.key;

  @override
  BlockComponentConfiguration get configuration => widget.configuration;

  @override
  Node get node => widget.node;

  @override
  Widget buildComponent(BuildContext context) {
    Widget child = Container(
      color: backgroundColor,
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
    if (showActions) {
      child = BlockComponentActionWrapper(
        node: node,
        actionBuilder: widget.actionBuilder!,
        child: child,
      );
    }
    return child;
  }
}
