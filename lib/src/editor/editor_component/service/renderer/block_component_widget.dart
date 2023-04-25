import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/renderer/block_component_context.dart';
import 'package:flutter/material.dart';

typedef NodeValidator = bool Function(Node node);
typedef OnNodeChanged = void Function(Node node);

/// BlockComponentBuilder is used to build a BlockComponentWidget.
abstract class BlockComponentBuilder {
  /// validate the node.
  ///
  /// return true if the node is valid.
  /// return false if the node is invalid,
  ///   and the node will be displayed as a PlaceHolder widget.
  bool validate(Node node);

  Widget build(BlockComponentContext blockComponentContext);
}

class BlockComponentContainer extends StatelessWidget {
  const BlockComponentContainer({
    super.key,
    required this.node,
    required this.child,
  });

  final Node node;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Icon(Icons.add),
        // Icon(Icons),
      ],
    );
  }
}
