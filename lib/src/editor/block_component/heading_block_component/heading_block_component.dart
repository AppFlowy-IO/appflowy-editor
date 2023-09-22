import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HeadingBlockKeys {
  const HeadingBlockKeys._();

  static const String type = 'heading';

  /// The level data of a heading block.
  ///
  /// The value is a int.
  static const String level = 'level';

  static const String delta = blockComponentDelta;

  static const String backgroundColor = blockComponentBackgroundColor;

  static const String textDirection = blockComponentTextDirection;
}

Node headingNode({
  required int level,
  Delta? delta,
  String? textDirection,
  Attributes? attributes,
}) {
  assert(level >= 1 && level <= 6);
  attributes ??= {'delta': (delta ?? Delta()).toJson()};
  return Node(
    type: HeadingBlockKeys.type,
    attributes: {
      ...attributes,
      HeadingBlockKeys.level: level,
      if (textDirection != null) HeadingBlockKeys.textDirection: textDirection,
    },
  );
}

class HeadingBlockComponentBuilder extends BlockComponentBuilder {
  HeadingBlockComponentBuilder({
    super.configuration,
    this.textStyleBuilder,
  });

  /// The text style of the heading block.
  final TextStyle Function(int level)? textStyleBuilder;

  @override
  BlockComponentWidget build(BlockComponentContext blockComponentContext) {
    final node = blockComponentContext.node;
    return HeadingBlockComponentWidget(
      key: node.key,
      node: node,
      configuration: configuration,
      textStyleBuilder: textStyleBuilder,
      showActions: showActions(node),
      actionBuilder: (context, state) => actionBuilder(
        blockComponentContext,
        state,
      ),
    );
  }

  @override
  bool validate(Node node) =>
      node.delta != null &&
      node.children.isEmpty &&
      node.attributes[HeadingBlockKeys.level] is int;
}

class HeadingBlockComponentWidget extends BlockComponentStatefulWidget {
  const HeadingBlockComponentWidget({
    super.key,
    required super.node,
    super.showActions,
    super.actionBuilder,
    super.configuration = const BlockComponentConfiguration(),
    this.textStyleBuilder,
  });

  /// The text style of the heading block.
  final TextStyle Function(int level)? textStyleBuilder;

  @override
  State<HeadingBlockComponentWidget> createState() =>
      _HeadingBlockComponentWidgetState();
}

class _HeadingBlockComponentWidgetState
    extends State<HeadingBlockComponentWidget>
    with
        SelectableMixin,
        DefaultSelectableMixin,
        BlockComponentConfigurable,
        BlockComponentBackgroundColorMixin,
        BlockComponentTextDirectionMixin,
        BlockComponentAlignMixin {
  @override
  final forwardKey = GlobalKey(debugLabel: 'flowy_rich_text');

  @override
  GlobalKey<State<StatefulWidget>> get containerKey => widget.node.key;

  @override
  GlobalKey<State<StatefulWidget>> blockComponentKey = GlobalKey(
    debugLabel: HeadingBlockKeys.type,
  );

  @override
  BlockComponentConfiguration get configuration => widget.configuration;

  @override
  Node get node => widget.node;

  @override
  late final editorState = Provider.of<EditorState>(context, listen: false);

  int get level => widget.node.attributes[HeadingBlockKeys.level] as int? ?? 1;

  @override
  Widget build(BuildContext context) {
    final textDirection = calculateTextDirection(
      layoutDirection: Directionality.maybeOf(context),
    );

    Widget child = Container(
      color: backgroundColor,
      width: double.infinity,
      alignment: alignment,
      // Related issue: https://github.com/AppFlowy-IO/AppFlowy/issues/3175
      // make the width of the rich text as small as possible to avoid
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        textDirection: textDirection,
        children: [
          Flexible(
            child: AppFlowyRichText(
              key: forwardKey,
              delegate: this,
              node: widget.node,
              editorState: editorState,
              textAlign: alignment?.toTextAlign,
              textSpanDecorator: (textSpan) {
                var result = textSpan.updateTextStyle(textStyle);
                result = result.updateTextStyle(
                  widget.textStyleBuilder?.call(level) ??
                      defaultTextStyle(level),
                );
                return result;
              },
              placeholderText: placeholderText,
              placeholderTextSpanDecorator: (textSpan) => textSpan
                  .updateTextStyle(
                    placeholderTextStyle,
                  )
                  .updateTextStyle(
                    widget.textStyleBuilder?.call(level) ??
                        defaultTextStyle(level),
                  ),
              textDirection: textDirection,
              cursorColor: editorState.editorStyle.cursorColor,
              selectionColor: editorState.editorStyle.selectionColor,
            ),
          ),
        ],
      ),
    );

    child = Padding(
      key: blockComponentKey,
      padding: padding,
      child: child,
    );

    child = BlockSelectionContainer(
      node: node,
      delegate: this,
      listenable: editorState.selectionNotifier,
      blockColor: editorState.editorStyle.selectionColor,
      supportTypes: const [
        BlockSelectionType.block,
      ],
      child: child,
    );

    if (widget.showActions && widget.actionBuilder != null) {
      child = BlockComponentActionWrapper(
        node: node,
        actionBuilder: widget.actionBuilder!,
        child: child,
      );
    }

    return child;
  }

  TextStyle? defaultTextStyle(int level) {
    final fontSizes = [32.0, 28.0, 24.0, 18.0, 18.0, 18.0];
    final fontSize = fontSizes.elementAtOrNull(level) ?? 18.0;
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
    );
  }
}
