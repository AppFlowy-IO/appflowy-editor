import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

@visibleForTesting
const floatingToolbarContainerKey =
    Key('appflowy_editor_floating_toolbar_container');
@visibleForTesting
const floatingToolbarItemPrefixKey = 'appflowy_editor_floating_toolbar_item';

typedef ToolbarTooltipBuilder = Widget Function(
  BuildContext context,
  String id,
  String message,
  Widget child,
);

typedef PlaceHolderItemBuilder = ToolbarItem Function(BuildContext context);

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
    required this.floatingToolbarHeight,
    this.tooltipBuilder,
    this.placeHolderBuilder,
    this.padding,
    this.decoration,
  });

  final List<ToolbarItem> items;
  final Color backgroundColor;
  final Color toolbarActiveColor;
  final Color? toolbarIconColor;
  final double toolbarElevation;
  final Color? toolbarShadowColor;
  final EditorState editorState;
  final TextDirection textDirection;
  final ToolbarTooltipBuilder? tooltipBuilder;
  final PlaceHolderItemBuilder? placeHolderBuilder;
  final double floatingToolbarHeight;
  final EdgeInsets? padding;
  final Decoration? decoration;

  @override
  State<FloatingToolbarWidget> createState() => _FloatingToolbarWidgetState();
}

class _FloatingToolbarWidgetState extends State<FloatingToolbarWidget> {
  EditorState get editorState => widget.editorState;
  PropertyValueNotifier<Selection?> get selectionNotifier =>
      editorState.selectionNotifier;

  @override
  void initState() {
    super.initState();
    selectionNotifier.addListener(_onSelectionChanged);
  }

  @override
  void didUpdateWidget(FloatingToolbarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.editorState != oldWidget.editorState) {
      oldWidget.editorState.selectionNotifier
          .removeListener(_onSelectionChanged);
      selectionNotifier.addListener(_onSelectionChanged);
    }
  }

  @override
  void dispose() {
    selectionNotifier.removeListener(_onSelectionChanged);
    super.dispose();
  }

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
      child: Container(
        padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: widget.decoration,
        child: SizedBox(
          height: widget.floatingToolbarHeight,
          child: Row(
            key: floatingToolbarContainerKey,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            textDirection: widget.textDirection,
            children: activeItems.mapIndexed(
              (index, item) {
                return Center(
                  key: Key(
                    '${floatingToolbarItemPrefixKey}_${item.id}_$index',
                  ),
                  child: item.builder!(
                    context,
                    widget.editorState,
                    widget.toolbarActiveColor,
                    widget.toolbarIconColor,
                    widget.tooltipBuilder,
                  ),
                );
              },
            ).toList(growable: false),
          ),
        ),
      ),
    );
  }

  void _onSelectionChanged() {
    if (mounted) setState(() {});
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
        .expand(
          (element) => [
            ...element,
            widget.placeHolderBuilder?.call(context) ?? placeholderItem,
          ],
        )
        .toList()
      ..removeLast();
  }
}
