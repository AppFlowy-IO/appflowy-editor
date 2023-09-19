import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class ParagraphBlockKeys {
  ParagraphBlockKeys._();

  static const String type = 'paragraph';

  static const String delta = blockComponentDelta;

  static const String backgroundColor = blockComponentBackgroundColor;

  static const String textDirection = blockComponentTextDirection;
}

Node paragraphNode({
  String? text,
  Delta? delta,
  String? textDirection,
  Attributes? attributes,
  Iterable<Node> children = const [],
}) {
  return Node(
    type: ParagraphBlockKeys.type,
    attributes: {
      ParagraphBlockKeys.delta:
          (delta ?? (Delta()..insert(text ?? ''))).toJson(),
      if (attributes != null) ...attributes,
      if (textDirection != null)
        ParagraphBlockKeys.textDirection: textDirection,
    },
    children: children,
  );
}

class TextBlockComponentBuilder extends BlockComponentBuilder {
  TextBlockComponentBuilder({
    super.configuration,
  });

  @override
  BlockComponentWidget build(BlockComponentContext blockComponentContext) {
    final node = blockComponentContext.node;
    return TextBlockComponentWidget(
      node: node,
      key: node.key,
      configuration: configuration,
      showActions: showActions(node),
      actionBuilder: (context, state) => actionBuilder(
        blockComponentContext,
        state,
      ),
    );
  }

  @override
  bool validate(Node node) {
    return node.delta != null;
  }
}

class TextBlockComponentWidget extends BlockComponentStatefulWidget {
  const TextBlockComponentWidget({
    super.key,
    required super.node,
    super.showActions,
    super.actionBuilder,
    super.configuration = const BlockComponentConfiguration(),
  });

  @override
  State<TextBlockComponentWidget> createState() =>
      _TextBlockComponentWidgetState();
}

class _TextBlockComponentWidgetState extends State<TextBlockComponentWidget>
    with
        SelectableMixin,
        DefaultSelectableMixin,
        BlockComponentConfigurable,
        BlockComponentBackgroundColorMixin,
        NestedBlockComponentStatefulWidgetMixin,
        BlockComponentTextDirectionMixin,
        BlockComponentAlignMixin {
  @override
  final forwardKey = GlobalKey(debugLabel: 'flowy_rich_text');

  @override
  GlobalKey<State<StatefulWidget>> get containerKey => widget.node.key;

  @override
  GlobalKey<State<StatefulWidget>> blockComponentKey = GlobalKey(
    debugLabel: ParagraphBlockKeys.type,
  );

  @override
  BlockComponentConfiguration get configuration => widget.configuration;

  @override
  Node get node => widget.node;

  bool _showPlaceholder = false;

  @override
  void initState() {
    super.initState();
    editorState.selectionNotifier.addListener(_onSelectionChange);
    _onSelectionChange();
  }

  @override
  void dispose() {
    editorState.selectionNotifier.removeListener(_onSelectionChange);
    super.dispose();
  }

  void _onSelectionChange() {
    final selection = editorState.selection;
    final showPlaceholder = selection != null &&
        (selection.isSingle && selection.start.path.equals(node.path));
    if (showPlaceholder != _showPlaceholder) {
      setState(() => _showPlaceholder = showPlaceholder);
    }
  }

  @override
  Widget buildComponent(
    BuildContext context, {
    bool withBackgroundColor = true,
  }) {
    final textDirection = calculateTextDirection(
      layoutDirection: Directionality.maybeOf(context),
    );

    Widget child = Container(
      color: withBackgroundColor ? backgroundColor : null,
      width: double.infinity,
      alignment: alignment,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        textDirection: textDirection,
        children: [
          AppFlowyRichText(
            key: forwardKey,
            delegate: this,
            node: widget.node,
            editorState: editorState,
            textAlign: alignment?.toTextAlign,
            placeholderText: _showPlaceholder ? placeholderText : ' ',
            textSpanDecorator: (textSpan) =>
                textSpan.updateTextStyle(textStyle),
            placeholderTextSpanDecorator: (textSpan) =>
                textSpan.updateTextStyle(placeholderTextStyle),
            textDirection: textDirection,
            cursorColor: editorState.editorStyle.cursorColor,
            selectionColor: editorState.editorStyle.selectionColor,
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
}
