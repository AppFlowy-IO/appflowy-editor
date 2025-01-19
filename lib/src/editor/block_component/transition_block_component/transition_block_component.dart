import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/base_component/block_icon_builder.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

/// Keys and constants for the TransitionBlock.
class TransitionBlockKeys {
  const TransitionBlockKeys._();

  /// The type identifier for the TransitionBlock.
  static const String type = 'transition_block';

  /// The delta attribute key used to store the user-entered text (optional note).
  static const String delta = blockComponentDelta;

  /// The text direction attribute key (LTR, RTL, etc).
  static const String textDirection = blockComponentTextDirection;

  /// An optional background color attribute key, if needed.
  static const String backgroundColor = blockComponentBackgroundColor;
}

/// A helper method to create a new `Node` of type TransitionBlock.
///
/// Example usage:
/// ```dart
/// final newNode = transitionNode(
///   delta: Delta()..insert('Suddenly, I am in a different place...'),
/// );
/// ```
Node transitionNode({
  Delta? delta,
  String? textDirection,
  Attributes? attributes,
  Iterable<Node>? children,
}) {
  attributes ??= {'delta': (delta ?? Delta()).toJson()};
  return Node(
    type: TransitionBlockKeys.type,
    attributes: {
      ...attributes,
      if (textDirection != null)
        TransitionBlockKeys.textDirection: textDirection,
    },
    children: children ?? [],
  );
}

/// A [BlockComponentBuilder] that constructs and validates the TransitionBlock widget.
class TransitionBlockComponentBuilder extends BlockComponentBuilder {
  TransitionBlockComponentBuilder({
    super.configuration,
    this.iconBuilder,
  });

  /// A custom icon builder if you want to override the default icon for this block.
  final BlockIconBuilder? iconBuilder;

  @override
  BlockComponentWidget build(BlockComponentContext blockComponentContext) {
    final node = blockComponentContext.node;
    return TransitionBlockComponentWidget(
      key: node.key,
      node: node,
      configuration: configuration,
      iconBuilder: iconBuilder,
      showActions: showActions(node),
      actionBuilder: (context, state) =>
          actionBuilder(blockComponentContext, state),
    );
  }

  @override
  BlockComponentValidate get validate => (node) => node.delta != null;
}

/// A widget that represents the TransitionBlock in the editor.
class TransitionBlockComponentWidget extends BlockComponentStatefulWidget {
  const TransitionBlockComponentWidget({
    super.key,
    required super.node,
    super.showActions,
    super.actionBuilder,
    super.configuration = const BlockComponentConfiguration(),
    this.iconBuilder,
  });

  final BlockIconBuilder? iconBuilder;

  @override
  State<TransitionBlockComponentWidget> createState() =>
      _TransitionBlockComponentWidgetState();
}

class _TransitionBlockComponentWidgetState
    extends State<TransitionBlockComponentWidget>
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
    debugLabel: TransitionBlockKeys.type,
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
    final textTheme = theme.textTheme;

    final textDirection = calculateTextDirection(
      layoutDirection: Directionality.maybeOf(context),
    );

    final textScaleFactor = editorState.editorStyle.textScaleFactor;

    // A subtle surface that aligns with Material 3 design principles, but compact.
    final blockSurfaceColor = colorScheme.surfaceContainerHighest;
    final dividerColor = colorScheme.outlineVariant;
    final transitionLabelColor = colorScheme.onSurfaceVariant;
    final noteTextColor = colorScheme.onSurface;
    final highlightColor = editorState.editorStyle.selectionColor;

    // The optional icon for the block, or the default "compare_arrows_rounded".
    final iconWidget = widget.iconBuilder != null
        ? widget.iconBuilder!(context, node)
        : const _TransitionIcon();

    // Top portion: a slim divider with "Transition" and an icon in the center.
    final dividerLabelSection = Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Row(
        textDirection: textDirection,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              height: 1.0,
              color: dividerColor,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                iconWidget,
                Text(
                  'Transition',
                  style: textTheme.bodyMedium?.copyWith(
                    color: transitionLabelColor,
                    fontSize: (textTheme.labelMedium?.fontSize ?? 13.0) *
                        textScaleFactor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              height: 1.0,
              color: dividerColor,
            ),
          ),
        ],
      ),
    );

    // The editable text portion (small, centered).
    final explanationSection = Container(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      alignment: Alignment.center,
      child: AppFlowyRichText(
        key: forwardKey,
        delegate: this,
        node: widget.node,
        editorState: editorState,
        placeholderText: 'Add a short note...',
        textAlign: TextAlign.center,
        textSpanDecorator: (textSpan) => textSpan.updateTextStyle(
          textTheme.bodyMedium?.copyWith(
            color: noteTextColor,
            fontSize:
                (textTheme.labelSmall?.fontSize ?? 13.0) * textScaleFactor,
          ),
        ),
        placeholderTextSpanDecorator: (textSpan) => textSpan.updateTextStyle(
          placeholderTextStyle.copyWith(
            color: noteTextColor.withValues(alpha: 0.6),
            fontSize: 12.0 * textScaleFactor,
          ),
        ),
        textDirection: textDirection,
        cursorColor: editorState.editorStyle.cursorColor,
        selectionColor: highlightColor,
        cursorWidth: editorState.editorStyle.cursorWidth,
      ),
    );

    // Combine the divider/label and the optional note into a single container.
    // Make it smaller overall: minimal border, smaller radius, and less padding.
    final blockBody = Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: blockSurfaceColor,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          dividerLabelSection,
          explanationSection,
        ],
      ),
    );

    // Wrap in a BlockSelectionContainer for selection/interaction within AppFlowy.
    final selectableContainer = BlockSelectionContainer(
      node: node,
      delegate: this,
      listenable: editorState.selectionNotifier,
      remoteSelection: editorState.remoteSelections,
      blockColor: highlightColor,
      supportTypes: const [BlockSelectionType.block],
      child: Padding(
        key: blockComponentKey,
        padding: padding,
        child: blockBody,
      ),
    );

    // Optionally wrap in an action wrapper if showActions is true
    // (e.g., to show a popover menu or context actions on the block).
    if (widget.showActions && widget.actionBuilder != null) {
      return BlockComponentActionWrapper(
        node: node,
        actionBuilder: widget.actionBuilder!,
        child: selectableContainer,
      );
    }

    return selectableContainer;
  }
}

/// A small icon for the transition block (two-way or split arrow).
class _TransitionIcon extends StatelessWidget {
  const _TransitionIcon();

  @override
  Widget build(BuildContext context) {
    final textScaleFactor =
        context.read<EditorState>().editorStyle.textScaleFactor;

    return Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: Icon(
        Symbols.compare_arrows_rounded,
        size: 16 * textScaleFactor,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
