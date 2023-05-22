import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BulletedListBlockKeys {
  BulletedListBlockKeys._();

  static const String type = 'bulleted_list';
}

Node bulletedListNode({
  String? text,
  Attributes? attributes,
  Iterable<Node>? children,
}) {
  attributes ??= {'delta': (Delta()..insert(text ?? '')).toJson()};
  return Node(
    type: BulletedListBlockKeys.type,
    attributes: {
      ...attributes,
    },
    children: children ?? [],
  );
}

class BulletedListBlockComponentBuilder extends BlockComponentBuilder {
  BulletedListBlockComponentBuilder({
    this.configuration = const BlockComponentConfiguration(),
  });

  @override
  final BlockComponentConfiguration configuration;

  @override
  Widget build(BlockComponentContext blockComponentContext) {
    final node = blockComponentContext.node;
    return BulletedListBlockComponentWidget(
      key: node.key,
      node: node,
      configuration: configuration,
    );
  }

  @override
  bool validate(Node node) => node.delta != null;
}

class BulletedListBlockComponentWidget extends StatefulWidget {
  const BulletedListBlockComponentWidget({
    super.key,
    required this.node,
    this.configuration = const BlockComponentConfiguration(),
  });

  final Node node;
  final BlockComponentConfiguration configuration;

  @override
  State<BulletedListBlockComponentWidget> createState() =>
      _BulletedListBlockComponentWidgetState();
}

class _BulletedListBlockComponentWidgetState
    extends State<BulletedListBlockComponentWidget>
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
    return widget.node.children.isEmpty
        ? buildBulletListBlockComponent(context)
        : buildBulletListBlockComponentWithChildren(context);
  }

  Widget buildBulletListBlockComponentWithChildren(BuildContext context) {
    return Container(
      color: backgroundColor,
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
      color: backgroundColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _BulletedListIcon(
            node: widget.node,
            textStyle: textStyle,
          ),
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
    );
  }
}

class _BulletedListIcon extends StatelessWidget {
  const _BulletedListIcon({
    required this.node,
    required this.textStyle,
  });

  final Node node;
  final TextStyle textStyle;

  static final bulletedListIcons = [
    '●',
    '◯',
    '□',
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
            style: textStyle,
            textScaleFactor: 0.5,
          ),
        ),
      ),
    );
  }
}
