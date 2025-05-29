import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// BlockComponentContainer is a wrapper of block component
///
/// 1. used to update the child widget when node is changed
/// ~~2. used to show block component actions~~
/// 3. used to add the layer link to the child widget
class BlockComponentContainer extends StatelessWidget {
  const BlockComponentContainer({
    super.key,
    required this.configuration,
    required this.node,
    required this.builder,
  });

  final Node node;
  final BlockComponentConfiguration configuration;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final child = ChangeNotifierProvider<Node>.value(
      value: node,
      child: Consumer<Node>(
        builder: (_, _, _) {
          AppFlowyEditorLog.editor.debug(
            'node is rebuilding...: type: ${node.type} ',
          );
          return CompositedTransformTarget(
            link: node.layerLink,
            child: builder(context),
          );
        },
      ),
    );

    return child;
  }
}
