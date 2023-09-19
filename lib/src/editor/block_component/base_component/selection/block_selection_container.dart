import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BlockSelectionContainer extends StatelessWidget {
  const BlockSelectionContainer({
    super.key,
    required this.node,
    required this.delegate,
    required this.listenable,
    this.cursorColor = Colors.black,
    this.selectionColor = Colors.blue,
    this.blockColor = Colors.blue,
    this.supportTypes = const [
      BlockSelectionType.cursor,
      BlockSelectionType.selection,
    ],
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

  // the color of the background of the block
  final Color blockColor;

  // the node of the block
  final Node node;

  final List<BlockSelectionType> supportTypes;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      // In RTL mode, if the alignment is topStart,
      //  the selection will be on the opposite side of the block component.
      alignment: Directionality.of(context) == TextDirection.ltr
          ? AlignmentDirectional.topStart
          : AlignmentDirectional.topEnd,
      children: [
        BlockSelectionArea(
          node: node,
          delegate: delegate,
          listenable: listenable,
          cursorColor: cursorColor,
          selectionColor: selectionColor,
          blockColor: blockColor,
          supportTypes: supportTypes,
        ),
        child,
      ],
    );
  }
}
