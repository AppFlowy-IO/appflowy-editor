import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:collection/collection.dart';

class TitleBlockKeys {
  const TitleBlockKeys._();

  static const String type = 'title';

  static const String delta = blockComponentDelta;

  static const String backgroundColor = blockComponentBackgroundColor;

  static const String textDirection = blockComponentTextDirection;
}

Node titleNode({
  Delta? delta,
  String? textDirection,
  Attributes? attributes,
}) {
  attributes ??= {'delta': (delta ?? Delta()).toJson()};
  return Node(
    type: TitleBlockKeys.type,
    attributes: {
      ...attributes,
      if (textDirection != null) HeadingBlockKeys.textDirection: textDirection,
    },
  );
}

class TitleBlockComponentBuilder extends BlockComponentBuilder {
  TitleBlockComponentBuilder({
    this.configuration = const BlockComponentConfiguration(),
  });

  @override
  final BlockComponentConfiguration configuration;

  @override
  BlockComponentWidget build(BlockComponentContext blockComponentContext) {
    final node = blockComponentContext.node;
    return TitleBlockComponentWidget(
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
  bool validate(Node node) => node.delta != null && node.children.isEmpty;
}

class TitleBlockComponentWidget extends BlockComponentStatefulWidget {
  const TitleBlockComponentWidget({
    super.key,
    required super.node,
    super.showActions,
    super.actionBuilder,
    super.configuration = const BlockComponentConfiguration(),
  });

  @override
  State<TitleBlockComponentWidget> createState() =>
      _TitleBlockComponentWidgetState();
}

class _TitleBlockComponentWidgetState extends State<TitleBlockComponentWidget>
    with
        SelectableMixin,
        DefaultSelectableMixin,
        BlockComponentConfigurable,
        BlockComponentBackgroundColorMixin,
        BlockComponentTextDirectionMixin {
  @override
  final forwardKey = GlobalKey(debugLabel: 'flowy_rich_text');

  @override
  GlobalKey<State<StatefulWidget>> get containerKey => widget.node.key;

  @override
  GlobalKey<State<StatefulWidget>> blockComponentKey = GlobalKey(
    debugLabel: TitleBlockKeys.type,
  );

  @override
  BlockComponentConfiguration get configuration => widget.configuration;

  @override
  Node get node => widget.node;

  late final editorState = Provider.of<EditorState>(context, listen: false);
  bool get _isFirstNode => node.path.length == 1 && node.path.first == 0;
  @override
  Widget build(BuildContext context) {
    if (!_isFirstNode) {
      return const SizedBox.shrink();
    }
    final textDirection = calculateTextDirection(
      defaultTextDirection: Directionality.maybeOf(context),
    );

    return Container(
      key: blockComponentKey,
      padding: padding,
      color: backgroundColor,
      width: double.infinity,
      // Related issue: https://github.com/AppFlowy-IO/AppFlowy/issues/3175
      // make the width of the rich text as small as possible to avoid
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: AppFlowyRichText(
              key: forwardKey,
              node: widget.node,
              editorState: editorState,
              textSpanDecorator: (textSpan) =>
                  textSpan.updateTextStyle(textStyle).updateTextStyle(
                        defaultTextStyle(),
                      ),
              placeholderText: 'Untitled',
              placeholderTextSpanDecorator: (textSpan) => textSpan
                  .updateTextStyle(
                    placeholderTextStyle,
                  )
                  .updateTextStyle(
                    defaultTextStyle(),
                  ),
              textDirection: textDirection,
            ),
          ),
        ],
      ),
    );

/*
    if (widget.showActions && widget.actionBuilder != null) {
      child = BlockComponentActionWrapper(
        node: node,
        actionBuilder: widget.actionBuilder!,
        child: child,
      );
    }
    */
  }

  TextStyle? defaultTextStyle() {
    const fontSize = 44.0;
    return const TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
    );
  }
}
