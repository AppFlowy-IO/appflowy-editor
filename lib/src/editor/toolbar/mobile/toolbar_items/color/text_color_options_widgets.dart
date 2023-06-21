import 'package:appflowy_editor/src/editor/toolbar/mobile/toolbar_items/color/utils/utils.dart';
import 'package:appflowy_editor/src/editor/toolbar/util/format_color.dart';
import 'package:flutter/material.dart';
import 'package:appflowy_editor/appflowy_editor.dart' hide formatFontColor;

class TextColorOptionsWidgets extends StatefulWidget {
  const TextColorOptionsWidgets(
    this.editorState,
    this.selection, {
    Key? key,
  }) : super(key: key);

  final Selection selection;
  final EditorState editorState;

  @override
  State<TextColorOptionsWidgets> createState() =>
      _TextColorOptionsWidgetsState();
}

class _TextColorOptionsWidgetsState extends State<TextColorOptionsWidgets> {
  @override
  Widget build(BuildContext context) {
    final style = MobileToolbarStyle.of(context);

    final selection = widget.selection;
    final nodes = widget.editorState.getNodesInSelection(selection);
    final hasTextColor = nodes.allSatisfyInSelection(selection, (delta) {
      return delta.everyAttributes(
        (attributes) => attributes[FlowyRichTextKeys.textColor] != null,
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
                      {FlowyRichTextKeys.textColor: null},
                    );
                  });
                }
              },
              isSelected: !hasTextColor,
            ),
            ...generateTextColorOptions().map((e) {
              final isSelected =
                  nodes.allSatisfyInSelection(selection, (delta) {
                return delta.everyAttributes(
                  (attributes) =>
                      attributes[FlowyRichTextKeys.textColor] == e.colorHex,
                );
              });
              return ColorButton(
                colorOption: e,
                onPressed: () {
                  if (!isSelected) {
                    setState(() {
                      formatFontColor(
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
