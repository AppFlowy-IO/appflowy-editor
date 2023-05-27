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

    final padding = widget.configuration.padding(widget.node);
    return Padding(
      padding: padding,
      child: child,
    );
  }
}
