import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class BlockComponentActionContainer extends StatefulWidget {
  const BlockComponentActionContainer({
    super.key,
    required this.node,
    required this.showActions,
  });

  final Node node;
  final bool showActions;

  @override
  State<BlockComponentActionContainer> createState() =>
      _BlockComponentActionContainerState();
}

class _BlockComponentActionContainerState
    extends State<BlockComponentActionContainer> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      child: !widget.showActions
          ? const SizedBox.shrink()
          : Row(
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
            ),
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
