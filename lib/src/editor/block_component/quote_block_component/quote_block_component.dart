import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/base_component/block_component_action_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QuoteBlockKeys {
  const QuoteBlockKeys._();

  static const String type = 'quote';
}

Node quoteNode({
  Attributes? attributes,
  Iterable<Node>? children,
}) {
  attributes ??= {'delta': Delta().toJson()};
  return Node(
    type: QuoteBlockKeys.type,
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

  @override
  final BlockComponentConfiguration configuration;

  @override
  BlockComponentWidget build(BlockComponentContext blockComponentContext) {
    final node = blockComponentContext.node;
    return QuoteBlockComponentWidget(
      key: node.key,
      node: node,
      configuration: configuration,
      showActions: showActions(node),
      actionBuilder: (context, state) => actionBuilder(
        blockComponentContext,
        state,
      ),
    );
  }

  @override
  bool validate(Node node) => node.delta != null;
}

class QuoteBlockComponentWidget extends BlockComponentStatefulWidget {
  const QuoteBlockComponentWidget({
    super.key,
    required super.node,
    super.showActions,
    super.actionBuilder,
    super.configuration = const BlockComponentConfiguration(),
  });

  @override
  State<QuoteBlockComponentWidget> createState() =>
      _QuoteBlockComponentWidgetState();
}

class _QuoteBlockComponentWidgetState extends State<QuoteBlockComponentWidget>
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
    Widget child = Container(
      color: backgroundColor,
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

    if (widget.actionBuilder != null) {
      child = BlockComponentActionWrapper(
        node: node,
        actionBuilder: widget.actionBuilder!,
        child: child,
      );
    }

    return child;
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
