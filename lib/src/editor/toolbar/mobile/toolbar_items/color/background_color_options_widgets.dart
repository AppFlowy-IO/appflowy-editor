import 'package:flutter/material.dart';
import 'package:appflowy_editor/appflowy_editor.dart';

class BackgroundColorOptionsWidgets extends StatefulWidget {
  const BackgroundColorOptionsWidgets(
    this.editorState,
    this.selection, {
    Key? key,
  }) : super(key: key);

  final Selection selection;
  final EditorState editorState;

  @override
  State<BackgroundColorOptionsWidgets> createState() =>
      _BackgroundColorOptionsWidgetsState();
}

class _BackgroundColorOptionsWidgetsState
    extends State<BackgroundColorOptionsWidgets> {
  @override
  Widget build(BuildContext context) {
    final style = MobileToolbarStyle.of(context);

    final selection = widget.selection;
    final nodes = widget.editorState.getNodesInSelection(selection);
    final hasTextColor = nodes.allSatisfyInSelection(selection, (delta) {
      return delta.everyAttributes(
        (attributes) => attributes[FlowyRichTextKeys.highlightColor] != null,
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView(
          shrinkWrap: true,
          gridDelegate: buildMobileToolbarMenuGridDelegate(
            mobileToolbarStyle: style,
            crossAxisCount: 3,
          ),
          children: [
            ClearColorButton(
              onPressed: () {
                if (hasTextColor) {
                  setState(() {
                    widget.editorState.formatDelta(
                      selection,
                      {FlowyRichTextKeys.highlightColor: null},
                    );
                  });
                }
              },
              isSelected: !hasTextColor,
            ),
            // color option buttons
            ...style.backgroundColorOptions.map((e) {
              final isSelected =
                  nodes.allSatisfyInSelection(selection, (delta) {
                return delta.everyAttributes(
                  (attributes) =>
                      attributes[FlowyRichTextKeys.highlightColor] ==
                      e.colorHex,
                );
              });
              return ColorButton(
                isBackgroundColor: true,
                colorOption: e,
                onPressed: () {
                  if (!isSelected) {
                    setState(() {
                      formatHighlightColor(
                        widget.editorState,
                        e.colorHex,
                      );
                    });
                  }
                },
                isSelected: isSelected,
              );
            }).toList()
          ],
        ),
      ],
    );
  }
}
