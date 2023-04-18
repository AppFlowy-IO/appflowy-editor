import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NumberedListBlockComponentBuilder extends NodeWidgetBuilder<Node> {
  NumberedListBlockComponentBuilder({
    this.padding = const EdgeInsets.all(0.0),
  });

  /// The padding of the todo list block.
  final EdgeInsets padding;

  @override
  Widget build(NodeWidgetContext<Node> context) {
    return NumberedListBlockComponentWidget(
      key: context.node.key,
      node: context.node,
      padding: padding,
    );
  }

  @override
  NodeValidator<Node> get nodeValidator => (node) => node.delta != null;
}

class NumberedListBlockComponentWidget extends StatefulWidget {
  const NumberedListBlockComponentWidget({
    super.key,
    required this.node,
    this.padding = const EdgeInsets.all(0.0),
  });

  final Node node;
  final EdgeInsets padding;

  @override
  State<NumberedListBlockComponentWidget> createState() =>
      _NumberedListBlockComponentWidgetState();
}

class _NumberedListBlockComponentWidgetState
    extends State<NumberedListBlockComponentWidget>
    with SelectableMixin, DefaultSelectable {
  @override
  final forwardKey = GlobalKey(debugLabel: 'flowy_rich_text');

  late final editorState = Provider.of<EditorState>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
    );
  }

  // TODO: support custom icon.
  Widget defaultIcon() {
    final level = _NumberedListIconBuilder(node: widget.node).level;
    return FlowySvg(
      width: 20,
      height: 20,
      padding: const EdgeInsets.only(right: 5.0),
      number: level,
    );
  }
}

class _NumberedListIconBuilder {
  _NumberedListIconBuilder({
    required this.node,
  });

  final Node node;

  int get level {
    var level = 1;
    var previous = node.previous;
    while (previous != null) {
      if (previous.type == 'numbered_list') {
        level++;
      }
      previous = previous.previous;
    }
    return level;
  }
}
