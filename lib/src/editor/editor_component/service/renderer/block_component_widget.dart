import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/renderer/block_component_action.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// BlockComponentContainer is a wrapper of block component
///
/// 1. used to update the child widget when node is changed
/// 2. used to show block component actions
/// 3. used to add the layer link to the child widget
class BlockComponentContainer extends StatefulWidget {
  const BlockComponentContainer({
    super.key,
    this.showBlockComponentActions = false,
    required this.node,
    required this.builder,
  });

  /// show block component actions or not
  ///
  /// + and option button
  final bool showBlockComponentActions;
  final Node node;
  final WidgetBuilder builder;

  @override
  State<BlockComponentContainer> createState() =>
      _BlockComponentContainerState();
}

class _BlockComponentContainerState extends State<BlockComponentContainer> {
  bool showActions = false;

  @override
  Widget build(BuildContext context) {
    final child = ChangeNotifierProvider<Node>.value(
      value: widget.node,
      child: Consumer<Node>(
        builder: (_, __, ___) {
          Log.editor.debug('node is rebuilding...: type: ${widget.node.type} ');
          return CompositedTransformTarget(
            link: widget.node.layerLink,
            child: widget.builder(context),
          );
        },
      ),
    );

    if (!widget.showBlockComponentActions) {
      return child;
    }

    return MouseRegion(
      onEnter: (_) => setState(() {
        showActions = true;
      }),
      onExit: (_) => setState(() {
        showActions = false;
      }),
      hitTestBehavior: HitTestBehavior.deferToChild,
      opaque: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          BlockComponentActionContainer(
            node: widget.node,
            showActions: showActions,
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
