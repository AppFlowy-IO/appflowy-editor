import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class NumberedListBlockKeys {
  const NumberedListBlockKeys._();

  static const String type = 'numbered_list';

  static const String number = 'number';
}

Node numberedListNode({
  Delta? delta,
  Attributes? attributes,
  int? number,
  Iterable<Node>? children,
}) {
  attributes ??= {
    'delta': (delta ?? Delta()).toJson(),
    NumberedListBlockKeys.number: number,
  };
  return Node(
    type: NumberedListBlockKeys.type,
    attributes: {
      ...attributes,
    },
    children: children ?? [],
  );
}

class NumberedListBlockComponentBuilder extends BlockComponentBuilder {
  NumberedListBlockComponentBuilder({
    this.configuration = const BlockComponentConfiguration(),
  });

  @override
  final BlockComponentConfiguration configuration;

  @override
  BlockComponentWidget build(BlockComponentContext blockComponentContext) {
    final node = blockComponentContext.node;
    return NumberedListBlockComponentWidget(
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

class NumberedListBlockComponentWidget extends BlockComponentStatefulWidget {
  const NumberedListBlockComponentWidget({
    super.key,
    required super.node,
    super.showActions,
    super.actionBuilder,
    super.configuration = const BlockComponentConfiguration(),
  });

  @override
  State<NumberedListBlockComponentWidget> createState() =>
      _NumberedListBlockComponentWidgetState();
}

class _NumberedListBlockComponentWidgetState
    extends State<NumberedListBlockComponentWidget>
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
    final (textDirection, startText) = getNodeDirection(
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

  Widget defaultIcon() {
    final text = editorState.editorStyle.textStyleConfiguration.text;
    final level = _NumberedListIconBuilder(node: widget.node).level;
    return Padding(
      padding: const EdgeInsets.only(right: 5.0),
      child: Text.rich(
        textHeightBehavior: const TextHeightBehavior(
          applyHeightToFirstAscent: false,
          applyHeightToLastDescent: false,
        ),
        TextSpan(text: '$level.', style: text.combine(textStyle)),
        textDirection: lastDirection,
      ),
    );
  }
}

class _NumberedListIconBuilder {
  _NumberedListIconBuilder({
    required this.node,
  });

  final Node node;

  int get level {
    int level = 1;
    Node? previous = node.previous;

    // if the previous one is not a numbered list, then it is the first one
    if (previous == null || previous.type != NumberedListBlockKeys.type) {
      return node.attributes[NumberedListBlockKeys.number] ?? level;
    }

    int? startNumber;
    while (previous != null && previous.type == NumberedListBlockKeys.type) {
      startNumber = previous.attributes[NumberedListBlockKeys.number] as int?;
      level++;
      previous = previous.previous;
    }
    if (startNumber != null) {
      return startNumber + level - 1;
    }
    return level;
  }
}
