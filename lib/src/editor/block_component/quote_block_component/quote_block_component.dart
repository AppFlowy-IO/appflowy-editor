import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QuoteBlockComponentBuilder extends NodeWidgetBuilder<Node> {
  QuoteBlockComponentBuilder({
    this.padding = const EdgeInsets.all(0.0),
  });

  /// The padding of the todo list block.
  final EdgeInsets padding;

  @override
  Widget build(NodeWidgetContext<Node> context) {
    return QuoteBlockComponentWidget(
      key: context.node.key,
      node: context.node,
      padding: padding,
    );
  }

  @override
  NodeValidator<Node> get nodeValidator => (node) => node.delta != null;
}

class QuoteBlockComponentWidget extends StatefulWidget {
  const QuoteBlockComponentWidget({
    super.key,
    required this.node,
    this.padding = const EdgeInsets.all(0.0),
  });

  final Node node;
  final EdgeInsets padding;

  @override
  State<QuoteBlockComponentWidget> createState() =>
      _QuoteBlockComponentWidgetState();
}

class _QuoteBlockComponentWidgetState extends State<QuoteBlockComponentWidget>
    with SelectableMixin, DefaultSelectable {
  @override
  final forwardKey = GlobalKey(debugLabel: 'flowy_rich_text');

  late final editorState = Provider.of<EditorState>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            defaultIcon(),
            FlowyRichText(
              key: forwardKey,
              node: widget.node,
              editorState: editorState,
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
