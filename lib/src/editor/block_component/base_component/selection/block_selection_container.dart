import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BlockSelectionContainer extends StatelessWidget {
  const BlockSelectionContainer({
    super.key,
    required this.node,
    required this.delegate,
    required this.listenable,
    required this.cursorColor,
    required this.selectionColor,
    required this.child,
  });

  // get the cursor rect, selection rects or block rect from the delegate
  final SelectableMixin delegate;

  // get the selection from the listenable
  final ValueListenable<Selection?> listenable;

  // the color of the cursor
  final Color cursorColor;

  // the color of the selection
  final Color selectionColor;

  // the node of the block
  final Node node;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BlockSelectionArea(
          node: node,
          delegate: delegate,
          listenable: listenable,
          cursorColor: cursorColor,
          selectionColor: selectionColor,
        ),
        child,
      ],
    );
  }
}
