import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/base_component/block_component_action_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class HeadingBlockKeys {
  const HeadingBlockKeys._();

  static const String type = 'heading';

  /// The level data of a heading block.
  ///
  /// The value is a int.
  static const String level = 'level';

  static const String delta = 'delta';

  static const backgroundColor = blockComponentBackgroundColor;
}

Node headingNode({
  required int level,
  Attributes? attributes,
}) {
  attributes ??= {'delta': Delta().toJson()};
  return Node(
    type: HeadingBlockKeys.type,
    attributes: {
      HeadingBlockKeys.level: level,
      ...attributes,
    },
  );
}

class HeadingBlockComponentBuilder extends BlockComponentBuilder {
  HeadingBlockComponentBuilder({
    this.configuration = const BlockComponentConfiguration(),
    this.textStyleBuilder,
  });

  @override
  final BlockComponentConfiguration configuration;

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

  int get level => widget.node.attributes[HeadingBlockKeys.level] as int? ?? 1;

  @override
  Widget build(BuildContext context) {
    Widget child = Container(
      color: backgroundColor,
      child: FlowyRichText(
        key: forwardKey,
        node: widget.node,
        editorState: editorState,
        textSpanDecorator: (textSpan) => textSpan
            .updateTextStyle(textStyle)
            .updateTextStyle(
              widget.textStyleBuilder?.call(level) ?? defaultTextStyle(level),
            ),
        placeholderText: placeholderText,
        placeholderTextSpanDecorator: (textSpan) => textSpan
            .updateTextStyle(
              placeholderTextStyle,
            )
            .updateTextStyle(
              widget.textStyleBuilder?.call(level) ?? defaultTextStyle(level),
            ),
      ),
    );

    if (widget.actionBuilder != null) {
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
