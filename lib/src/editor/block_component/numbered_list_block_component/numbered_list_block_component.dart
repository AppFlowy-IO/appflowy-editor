import 'dart:collection';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/base_component/widget/nested_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Node numberedListNode({
  required Attributes attributes,
  LinkedList<Node>? children,
}) {
  return Node(
    type: 'numbered_list',
    attributes: {
      ...attributes,
    },
    children: children,
  );
}

class NumberedListBlockComponentBuilder extends BlockComponentBuilder {
  NumberedListBlockComponentBuilder({
    this.padding = const EdgeInsets.all(0.0),
  });

  /// The padding of the todo list block.
  final EdgeInsets padding;

  @override
  Widget build(BlockComponentContext blockComponentContext) {
    final node = blockComponentContext.node;
    return NumberedListBlockComponentWidget(
      key: node.key,
      node: node,
      padding: padding,
    );
  }

  @override
  bool validate(Node node) => node.delta != null;
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          defaultIcon(),
          Flexible(
            child: FlowyRichText(
              key: forwardKey,
              node: widget.node,
              editorState: editorState,
            ),
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
      } else {
        break;
      }
      previous = previous.previous;
    }
    return level;
  }
}
