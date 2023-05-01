import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class HeadingBlockKeys {
  HeadingBlockKeys._();

  /// The level data of a heading block.
  ///
  /// The value is a int.
  static const String level = 'level';
}

Node headingNode({
  required int level,
  required Attributes attributes,
}) {
  return Node(
    type: 'heading',
    attributes: {
      HeadingBlockKeys.level: level,
      ...attributes,
    },
  );
}

class HeadingBlockComponentBuilder extends BlockComponentBuilder {
  HeadingBlockComponentBuilder({
    this.padding = const EdgeInsets.symmetric(vertical: 8.0),
  });

  /// The padding of the todo list block.
  final EdgeInsets padding;

  @override
  Widget build(BlockComponentContext blockComponentContext) {
    final node = blockComponentContext.node;
    return HeadingBlockComponentWidget(
      key: node.key,
      node: node,
      padding: padding,
    );
  }

  @override
  bool validate(Node node) =>
      node.delta != null &&
      node.children.isEmpty &&
      node.attributes[HeadingBlockKeys.level] is int;
}

class HeadingBlockComponentWidget extends StatefulWidget {
  const HeadingBlockComponentWidget({
    super.key,
    required this.node,
    this.padding = const EdgeInsets.all(0.0),
    this.textStyleBuilder,
  });

  final Node node;
  final EdgeInsets padding;

  /// The text style of the todo list block.
  final TextStyle Function(int level)? textStyleBuilder;

  @override
  State<HeadingBlockComponentWidget> createState() =>
      _HeadingBlockComponentWidgetState();
}

class _HeadingBlockComponentWidgetState
    extends State<HeadingBlockComponentWidget>
    with SelectableMixin, DefaultSelectable {
  @override
  final forwardKey = GlobalKey(debugLabel: 'flowy_rich_text');

  late final editorState = Provider.of<EditorState>(context, listen: false);

  int get level => widget.node.attributes[HeadingBlockKeys.level] as int? ?? 1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: FlowyRichText(
        key: forwardKey,
        node: widget.node,
        editorState: editorState,
        textSpanDecorator: (textSpan) => textSpan.updateTextStyle(
          widget.textStyleBuilder?.call(level) ?? defaultTextStyle(level),
        ),
      ),
    );
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
