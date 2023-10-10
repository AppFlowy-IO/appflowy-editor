import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

const floatingToolbarHeight = 32.0;

@visibleForTesting
const floatingToolbarContainerKey =
    Key('appflowy_editor_floating_toolbar_container');
@visibleForTesting
const floatingToolbarItemPrefixKey = 'appflowy_editor_floating_toolbar_item';

class FloatingToolbarWidget extends StatefulWidget {
  const FloatingToolbarWidget({
    super.key,
    this.backgroundColor = Colors.black,
    required this.toolbarActiveColor,
    this.toolbarIconColor,
    this.toolbarElevation = 0,
    this.toolbarShadowColor,
    required this.items,
    required this.editorState,
    required this.textDirection,
  });

  final List<ToolbarItem> items;
  final Color backgroundColor;
  final Color toolbarActiveColor;
  final Color? toolbarIconColor;
  final double toolbarElevation;
  final Color? toolbarShadowColor;
  final EditorState editorState;
  final TextDirection textDirection;

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
      shadowColor: widget.toolbarShadowColor,
      elevation: widget.toolbarElevation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: SizedBox(
          height: floatingToolbarHeight,
          child: Row(
            key: floatingToolbarContainerKey,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            textDirection: widget.textDirection,
            children: activeItems
                .mapIndexed(
                  (index, item) => Center(
                    key: Key(
                      '${floatingToolbarItemPrefixKey}_${item.id}_$index',
                    ),
                    child: item.builder!(
                      context,
                      widget.editorState,
                      widget.toolbarActiveColor,
                      widget.toolbarIconColor,
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ),
    );
  }

  Iterable<ToolbarItem> _computeActiveItems() {
    final activeItems = widget.items
        .where((e) => e.isActive?.call(widget.editorState) ?? false)
        .toList();
    if (activeItems.isEmpty) {
      return [];
    }

    // sort by group.
    activeItems.sort((a, b) => a.group.compareTo(b.group));

    // insert the divider.
    return activeItems
        .splitBetween((first, second) => first.group != second.group)
        .expand((element) => [...element, placeholderItem])
        .toList()
      ..removeLast();
  }
}
