import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// BlockComponentContainer is a wrapper of block component
///
/// 1. used to update the child widget when node is changed
/// ~~2. used to show block component actions~~
/// 3. used to add the layer link to the child widget
class BlockComponentContainer extends StatefulWidget {
  const BlockComponentContainer({
    super.key,
    this.showBlockComponentActions = false,
    required this.configuration,
    required this.node,
    required this.builder,
    required this.actionBuilder,
  });

  final Node node;
  final BlockComponentConfiguration configuration;

  /// show block component actions or not
  ///
  /// + and option button
  final bool showBlockComponentActions;

  final WidgetBuilder builder;
  final Widget Function(
    BuildContext context,
    BlockComponentActionState state,
  ) actionBuilder;

  @override
  State<BlockComponentContainer> createState() =>
      BlockComponentContainerState();
}

class BlockComponentContainerState extends State<BlockComponentContainer>
    implements BlockComponentActionState {
  final showActionsNotifier = ValueNotifier<bool>(false);

  bool _alwaysShowActions = false;
  bool get alwaysShowActions => _alwaysShowActions;
  @override
  set alwaysShowActions(bool alwaysShowActions) {
    _alwaysShowActions = alwaysShowActions;
    if (_alwaysShowActions == false && showActionsNotifier.value == true) {
      showActionsNotifier.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child = ChangeNotifierProvider<Node>.value(
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

    // if (widget.showBlockComponentActions) {
    //   child = MouseRegion(
    //     onEnter: (_) => showActionsNotifier.value = true,
    //     onExit: (_) => showActionsNotifier.value = alwaysShowActions || false,
    //     hitTestBehavior: HitTestBehavior.deferToChild,
    //     opaque: false,
    //     child: Row(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       mainAxisAlignment: MainAxisAlignment.start,
    //       mainAxisSize: MainAxisSize.min,
    //       children: [
    //         ValueListenableBuilder<bool>(
    //           valueListenable: showActionsNotifier,
    //           builder: (context, value, child) => BlockComponentActionContainer(
    //             node: widget.node,
    //             showActions: value,
    //             actionBuilder: (context) => widget.actionBuilder(context, this),
    //           ),
    //         ),
    //         Expanded(child: child),
    //       ],
    //     ),
    //   );
    // }

    final padding = widget.configuration.padding(widget.node);
    return Padding(
      padding: padding,
      child: child,
    );
  }
}
