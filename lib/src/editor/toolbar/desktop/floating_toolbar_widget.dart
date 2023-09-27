import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

const floatingToolbarHeight = 32.0;

class FloatingToolbarWidget extends StatefulWidget {
  const FloatingToolbarWidget({
    super.key,
    this.backgroundColor = Colors.black,
    required this.toolbarActiveColor,
    required this.items,
    required this.editorState,
    required this.layoutDirection,
  });

  final List<ToolbarItem> items;
  final Color backgroundColor;
  final Color toolbarActiveColor;
  final EditorState editorState;
  final TextDirection layoutDirection;

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
          height: floatingToolbarHeight,
          child: Row(
            key: const Key('toolbar-container'),
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: activeItems.mapIndexed((index, item) {
              final builder = item.builder;
              return Center(
                key: Key('${item.id}-$index'),
                child: builder!(
                  context,
                  widget.editorState,
                  widget.toolbarActiveColor,
                ),
              );
            }).toList(growable: false),
          ),
        ),
      ),
    );
  }

  List<ToolbarItem> _computeActiveItems() {
    List<ToolbarItem> activeItems = widget.items
        .where((e) => e.isActive?.call(widget.editorState) ?? false)
        .toList();
    if (activeItems.isEmpty) {
      return [];
    }
    if (widget.layoutDirection == TextDirection.rtl) {
      activeItems = activeItems.reversed.toList();
    }
    // sort by group.
    activeItems.sort(
      (a, b) => widget.layoutDirection == TextDirection.ltr
          ? a.group.compareTo(b.group)
          : b.group.compareTo(a.group),
    );
    // insert the divider.
    return activeItems
        .splitBetween((first, second) => first.group != second.group)
        .expand((element) => [...element, placeholderItem])
        .toList()
      ..removeLast();
  }
}
