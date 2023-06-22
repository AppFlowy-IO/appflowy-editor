import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class BulletedListBlockKeys {
  BulletedListBlockKeys._();

  static const String type = 'bulleted_list';
}

Node bulletedListNode({
  Delta? delta,
  Attributes? attributes,
  Iterable<Node>? children,
}) {
  attributes ??= {'delta': (delta ?? Delta()).toJson()};
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
  BlockComponentWidget build(BlockComponentContext blockComponentContext) {
    final node = blockComponentContext.node;
    return BulletedListBlockComponentWidget(
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

class BulletedListBlockComponentWidget extends BlockComponentStatefulWidget {
  const BulletedListBlockComponentWidget({
    super.key,
    required super.node,
    super.showActions,
    super.actionBuilder,
    super.configuration = const BlockComponentConfiguration(),
  });

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

  String? lastStartText;
  TextDirection? lastDirection;

  @override
  Widget buildComponent(BuildContext context) {
    final (textDirection, startText) = getTextDirection(
      node,
      lastStartText,
      lastDirection,
    );
    lastStartText = startText;
    lastDirection = textDirection;

    Widget child = Container(
      color: backgroundColor,
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        textDirection: textDirection,
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
              textDirection: textDirection,
            ),
          ),
        ],
      ),
    );

    if (widget.showActions && widget.actionBuilder != null) {
      child = BlockComponentActionWrapper(
        node: node,
        actionBuilder: widget.actionBuilder!,
        child: child,
      );
    }

    return blockPadding(
      child,
      widget.node,
      widget.configuration.padding(node),
      textDirection,
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
