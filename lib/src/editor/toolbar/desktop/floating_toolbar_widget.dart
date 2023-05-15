import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class FloatingToolbarWidget extends StatefulWidget {
  const FloatingToolbarWidget({
    super.key,
    this.backgroundColor = Colors.black,
    required this.items,
    required this.editorState,
  });

  final List<ToolbarItem> items;
  final Color backgroundColor;
  final EditorState editorState;

  @override
  State<FloatingToolbarWidget> createState() => _FloatingToolbarWidgetState();
}

class _FloatingToolbarWidgetState extends State<FloatingToolbarWidget> {
  @override
  Widget build(BuildContext context) {
    var activeItems = _computeActiveItems();
    if (activeItems.isEmpty) {
      return const SizedBox.shrink();
    }
    return Material(
      borderRadius: BorderRadius.circular(8.0),
      color: widget.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: SizedBox(
          height: 32.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: activeItems.map((item) {
              final builder = item.builder;
              return Center(
                child: builder!(context, widget.editorState),
              );
            }).toList(growable: false),
          ),
        ),
      ),
    );
  }

  Iterable<ToolbarItem> _computeActiveItems() {
    var activeItems = widget.items
        .where(
          (element) => element.isActive?.call(widget.editorState) ?? false,
        )
        .toList();
    // remove the unused placeholder items.
    return activeItems.where(
      (item) => !(item.id == placeholderItemId &&
          (activeItems.indexOf(item) == 0 ||
              activeItems.indexOf(item) == activeItems.length - 1 ||
              activeItems[activeItems.indexOf(item) - 1].id ==
                  placeholderItemId ||
              activeItems[activeItems.indexOf(item) + 1].id ==
                  placeholderItemId)),
    );
  }
}
