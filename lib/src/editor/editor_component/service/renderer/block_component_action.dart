import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class BlockComponentActionContainer extends StatelessWidget {
  const BlockComponentActionContainer({
    super.key,
    required this.node,
    required this.showActions,
    required this.actionBuilder,
  });

  final Node node;
  final bool showActions;
  final WidgetBuilder actionBuilder;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      width: 50,
      height: 25, // TODO: magic number, change it to the height of the block
      color: Colors
          .transparent, // have to set the color to transparent to make the MouseRegion work
      child: !showActions ? const SizedBox.shrink() : actionBuilder(context),
    );
  }
}

class BlockComponentActionList extends StatelessWidget {
  const BlockComponentActionList({
    super.key,
    required this.onTapAdd,
    required this.onTapOption,
  });

  final VoidCallback onTapAdd;
  final VoidCallback onTapOption;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        BlockComponentActionButton(
          icon: const Icon(
            Icons.add,
            size: 18,
          ),
          onTap: () {},
        ),
        const SizedBox(
          width: 5,
        ),
        BlockComponentActionButton(
          icon: const Icon(
            Icons.apps,
            size: 18,
          ),
          onTap: () {},
        ),
      ],
    );
  }
}

class BlockComponentActionButton extends StatelessWidget {
  const BlockComponentActionButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  final bool isHovering = false;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.grab,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        onTapDown: (details) {},
        onTapUp: (details) {},
        child: icon,
      ),
    );
  }
}
