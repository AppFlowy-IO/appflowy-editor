import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

mixin BlockComponentWidget on Widget {
  Node get node;
  BlockComponentConfiguration get configuration;
  BlockComponentActionBuilder? get actionBuilder;
  bool get showActions;
}

class BlockComponentStatelessWidget extends StatelessWidget
    implements BlockComponentWidget {
  const BlockComponentStatelessWidget({
    super.key,
    required this.node,
    required this.configuration,
    this.showActions = false,
    this.actionBuilder,
  });

  @override
  final Node node;

  @override
  final BlockComponentActionBuilder? actionBuilder;

  @override
  final bool showActions;

  @override
  final BlockComponentConfiguration configuration;

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}

class BlockComponentStatefulWidget extends StatefulWidget
    implements BlockComponentWidget {
  const BlockComponentStatefulWidget({
    super.key,
    required this.node,
    required this.configuration,
    this.showActions = false,
    this.actionBuilder,
  });

  @override
  final Node node;

  @override
  final BlockComponentActionBuilder? actionBuilder;

  @override
  final bool showActions;

  @override
  final BlockComponentConfiguration configuration;

  @override
  State<BlockComponentStatefulWidget> createState() =>
      _BlockComponentStatefulWidgetState();
}

class _BlockComponentStatefulWidgetState
    extends State<BlockComponentStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}

mixin NestedBlockComponentStatefulWidgetMixin<
        T extends BlockComponentStatefulWidget>
    on State<T>, BlockComponentBackgroundColorMixin {
  late final editorState = Provider.of<EditorState>(context, listen: false);

  BlockComponentConfiguration get configuration;

  EdgeInsets get indentPadding {
    TextDirection direction =
        Directionality.maybeOf(context) ?? TextDirection.ltr;
    if (node.children.isNotEmpty) {
      final firstChild = node.children.first;
      final currentState =
          firstChild.key.currentState as BlockComponentTextDirectionMixin?;
      if (currentState != null) {
        final lastDirection = currentState.lastDirection;
        direction = calculateNodeDirection(
          node: firstChild,
          layoutDirection: direction,
          defaultTextDirection: editorState.editorStyle.defaultTextDirection,
          lastDirection: lastDirection,
        );
      }
    }
    return configuration.indentPadding(node, direction);
  }

  double? cachedLeft;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final left =
          node.selectable?.getBlockRect(shiftWithBaseOffset: true).left;
      if (cachedLeft != left) {
        setState(() => cachedLeft = left);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return node.children.isEmpty
        ? buildComponent(context, withBackgroundColor: true)
        : buildComponentWithChildren(context);
  }

  Widget buildComponentWithChildren(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          left: cachedLeft,
          child: Container(
            color: backgroundColor,
          ),
        ),
        NestedListWidget(
          indentPadding: indentPadding,
          child: buildComponent(context, withBackgroundColor: false),
          children: editorState.renderer.buildList(
            context,
            widget.node.children,
          ),
        ),
      ],
    );
  }

  Widget buildComponent(
    BuildContext context, {
    bool withBackgroundColor = true,
  });
}
