import 'dart:collection';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/base_component/widget/nested_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Node bulletedListNode({
  Attributes? attributes,
  LinkedList<Node>? children,
}) {
  attributes ??= {'delta': Delta().toJson()};
  return Node(
    type: 'bulleted_list',
    attributes: {
      ...attributes,
    },
    children: children,
  );
}

class BulletedListBlockComponentBuilder extends BlockComponentBuilder {
  BulletedListBlockComponentBuilder({
    this.padding = const EdgeInsets.all(0.0),
  });

  /// The padding of the todo list block.
  final EdgeInsets padding;

  @override
  Widget build(BlockComponentContext blockComponentContext) {
    final node = blockComponentContext.node;
    return BulletedListBlockComponentWidget(
      key: node.key,
      node: node,
      padding: padding,
    );
  }

  @override
  bool validate(Node node) => node.delta != null;
}

class BulletedListBlockComponentWidget extends StatefulWidget {
  const BulletedListBlockComponentWidget({
    super.key,
    required this.node,
    this.padding = const EdgeInsets.all(0.0),
  });

  final Node node;
  final EdgeInsets padding;

  @override
  State<BulletedListBlockComponentWidget> createState() =>
      _BulletedListBlockComponentWidgetState();
}

class _BulletedListBlockComponentWidgetState
    extends State<BulletedListBlockComponentWidget>
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
          _BulletedListIcon(
            node: widget.node,
          ),
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
}

class _BulletedListIcon extends StatelessWidget {
  const _BulletedListIcon({
    required this.node,
  });

  final Node node;

  // FIXME: replace with the real icon.
  static final bulletedListIcons = [
    '◉',
    '○',
    '□',
    '*',
  ];

  int get level {
    var level = 0;
    var parent = node.parent;
    while (parent != null) {
      if (parent.type == 'bulleted_list') {
        level++;
      }
      parent = parent.parent;
    }
    return level;
  }

  String get icon => bulletedListIcons[level % bulletedListIcons.length];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: Padding(
        padding: const EdgeInsets.only(right: 5.0),
        child: Center(
          child: Text(
            icon,
            textScaleFactor: 1.2,
          ),
        ),
      ),
    );
  }
}
