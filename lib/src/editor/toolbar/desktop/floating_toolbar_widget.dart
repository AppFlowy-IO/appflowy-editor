import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

const floatingToolbarHeight = 32.0;

class FloatingToolbarWidget extends StatefulWidget {
  const FloatingToolbarWidget({
    super.key,
    this.backgroundColor = Colors.black,
    required this.toolbarActiveColor,
    required this.activeItems,
    required this.editorState,
    required this.layoutDirection,
  });

  final List<ToolbarItem> activeItems;
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
    if (widget.activeItems.isEmpty) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: widget.activeItems.map((item) {
              final builder = item.builder;
              return Center(
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
}
