import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/base_component/block_icon_builder.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

/// Keys and constants for the ContextBlock.
class ContextBlockKeys {
  const ContextBlockKeys._();

  /// The type identifier for the ContextBlock.
  static const String type = 'context_block';

  /// The delta attribute key used to store content.
  static const String delta = blockComponentDelta;

  /// The text direction attribute key (LTR, RTL, etc).
  static const String textDirection = blockComponentTextDirection;

  /// An optional background color attribute key, if needed.
  static const String backgroundColor = blockComponentBackgroundColor;
}

/// A helper method to create a new `Node` of type ContextBlock.
Node contextNode({
  Delta? delta,
  String? textDirection,
  Attributes? attributes,
  Iterable<Node>? children,
}) {
  attributes ??= {'delta': (delta ?? Delta()).toJson()};
  return Node(
    type: ContextBlockKeys.type,
    attributes: {
      ...attributes,
      if (textDirection != null) ContextBlockKeys.textDirection: textDirection,
    },
    children: children ?? [],
  );
}

/// A [BlockComponentBuilder] that knows how to construct and validate the ContextBlock widget.
class ContextBlockComponentBuilder extends BlockComponentBuilder {
  ContextBlockComponentBuilder({
    super.configuration,
    this.iconBuilder,
  });

  /// A custom icon builder if you want to override the default icon.
  final BlockIconBuilder? iconBuilder;

  @override
  BlockComponentWidget build(BlockComponentContext blockComponentContext) {
    final node = blockComponentContext.node;
    return ContextBlockComponentWidget(
      key: node.key,
      node: node,
      configuration: configuration,
      iconBuilder: iconBuilder,
      showActions: showActions(node),
      actionBuilder: (context, state) => actionBuilder(
        blockComponentContext,
        state,
      ),
    );
  }

  /// Validates that the node has a valid delta so the editor can render it.
  @override
  BlockComponentValidate get validate => (node) => node.delta != null;
}

/// A widget that represents the ContextBlock in the editor.
class ContextBlockComponentWidget extends BlockComponentStatefulWidget {
  const ContextBlockComponentWidget({
    super.key,
    required super.node,
    super.showActions,
    super.actionBuilder,
    super.configuration = const BlockComponentConfiguration(),
    this.iconBuilder,
  });

  final BlockIconBuilder? iconBuilder;

  @override
  State<ContextBlockComponentWidget> createState() =>
      _ContextBlockComponentWidgetState();
}

class _ContextBlockComponentWidgetState
    extends State<ContextBlockComponentWidget>
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
    debugLabel: ContextBlockKeys.type,
  );

  @override
  BlockComponentConfiguration get configuration => widget.configuration;

  @override
  Node get node => widget.node;

  @override
  late final editorState = Provider.of<EditorState>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textDirection = calculateTextDirection(
      layoutDirection: Directionality.maybeOf(context),
    );

    // Use Material 3 color guidelines for a subtle but distinct look.
    final contextBackgroundColor = colorScheme.primaryContainer;

    // The main body of the ContextBlock, including the icon and editable rich text.
    Widget child = Container(
      width: double.infinity,
      alignment: alignment,
      decoration: BoxDecoration(
        color: contextBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        // Subtle shadow to make it stand out just a bit
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          textDirection: textDirection,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Optional icon on the left side.
            widget.iconBuilder != null
                ? widget.iconBuilder!(context, node)
                : const _ContextIcon(),
            // The editable text portion.
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: AppFlowyRichText(
                  key: forwardKey,
                  delegate: this,
                  node: widget.node,
                  editorState: editorState,
                  textAlign: alignment?.toTextAlign ?? textAlign,
                  placeholderText: 'Add contextual note...',
                  textSpanDecorator: (textSpan) => textSpan.updateTextStyle(
                    textStyle.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  placeholderTextSpanDecorator: (textSpan) =>
                      textSpan.updateTextStyle(
                    placeholderTextStyle.copyWith(
                      color: colorScheme.onPrimaryContainer.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
                  textDirection: textDirection,
                  cursorColor: editorState.editorStyle.cursorColor,
                  selectionColor: editorState.editorStyle.selectionColor,
                  cursorWidth: editorState.editorStyle.cursorWidth,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // This container wraps the block and provides selection behavior for the editor.
    child = BlockSelectionContainer(
      node: node,
      delegate: this,
      listenable: editorState.selectionNotifier,
      remoteSelection: editorState.remoteSelections,
      blockColor: editorState.editorStyle.selectionColor,
      supportTypes: const [BlockSelectionType.block],
      child: Padding(
        key: blockComponentKey,
        padding: padding,
        child: child,
      ),
    );

    // If block actions (like a popover menu) should be shown, wrap the child in an action wrapper.
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

/// A simple icon widget for the context block.
class _ContextIcon extends StatelessWidget {
  const _ContextIcon();

  @override
  Widget build(BuildContext context) {
    final textScaleFactor =
        context.read<EditorState>().editorStyle.textScaleFactor;

    return Container(
      alignment: Alignment.center,
      constraints: const BoxConstraints(
            minWidth: 34,
            minHeight: 22,
          ) *
          textScaleFactor,
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Icon(
        Symbols.auto_stories_rounded,
        size: 20 * textScaleFactor,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }
}
