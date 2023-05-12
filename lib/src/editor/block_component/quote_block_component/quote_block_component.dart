import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Node quoteNode({
  Attributes? attributes,
  Iterable<Node>? children,
}) {
  attributes ??= {'delta': Delta().toJson()};
  return Node(
    type: 'quote',
    attributes: {
      ...attributes,
    },
    children: children ?? [],
  );
}

class QuoteBlockComponentBuilder extends BlockComponentBuilder {
  QuoteBlockComponentBuilder({
    this.configuration = const BlockComponentConfiguration(),
  });

  final BlockComponentConfiguration configuration;

  @override
  Widget build(BlockComponentContext blockComponentContext) {
    final node = blockComponentContext.node;
    return QuoteBlockComponentWidget(
      key: node.key,
      node: node,
      configuration: configuration,
    );
  }

  @override
  bool validate(Node node) => node.delta != null;
}

class QuoteBlockComponentWidget extends StatefulWidget {
  const QuoteBlockComponentWidget({
    super.key,
    required this.node,
    this.configuration = const BlockComponentConfiguration(),
  });

  final Node node;
  final BlockComponentConfiguration configuration;

  @override
  State<QuoteBlockComponentWidget> createState() =>
      _QuoteBlockComponentWidgetState();
}

class _QuoteBlockComponentWidgetState extends State<QuoteBlockComponentWidget>
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
    return Padding(
      padding: padding,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            defaultIcon(),
            Flexible(
              child: FlowyRichText(
                key: forwardKey,
                node: widget.node,
                editorState: editorState,
                placeholderText: placeholderText,
                textSpanDecorator: (textSpan) => textSpan.updateTextStyle(
                  textStyle,
                ),
                placeholderTextSpanDecorator: (textSpan) =>
                    textSpan.updateTextStyle(
                  placeholderTextStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TODO: support custom icon.
  Widget defaultIcon() {
    return const FlowySvg(
      width: 20,
      height: 20,
      padding: EdgeInsets.only(right: 5.0),
      name: 'quote',
    );
  }
}
