import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BulletedListBlockComponentBuilder extends NodeWidgetBuilder<Node> {
  BulletedListBlockComponentBuilder({
    this.padding = const EdgeInsets.all(0.0),
  });

  /// The padding of the todo list block.
  final EdgeInsets padding;

  @override
  Widget build(NodeWidgetContext<Node> context) {
    return BulletedListBlockComponentWidget(
      key: context.node.key,
      node: context.node,
      padding: padding,
    );
  }

  @override
  NodeValidator<Node> get nodeValidator => (node) => node.delta != null;
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
    final icon = _BulletedListIconBuilder(node: widget.node).icon;
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

class _BulletedListIconBuilder {
  _BulletedListIconBuilder({
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
}
