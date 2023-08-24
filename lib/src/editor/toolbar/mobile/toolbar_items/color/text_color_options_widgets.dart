import 'package:flutter/material.dart';
import 'package:appflowy_editor/appflowy_editor.dart';

class TextColorOptionsWidgets extends StatefulWidget {
  const TextColorOptionsWidgets(
    this.editorState,
    this.selection, {
    this.textColorOptions,
    Key? key,
  }) : super(key: key);

  final Selection selection;
  final EditorState editorState;
  final List<ColorOption>? textColorOptions;

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
        (attributes) => attributes[AppFlowyRichTextKeys.textColor] != null,
      );
    });

    final colorOptions = widget.textColorOptions ?? generateTextColorOptions();

    return Scrollbar(
      child: GridView(
        shrinkWrap: true,
        gridDelegate: buildMobileToolbarMenuGridDelegate(
          mobileToolbarStyle: style,
          crossAxisCount: 3,
        ),
        padding: EdgeInsets.all(style.buttonSpacing),
        children: [
          ClearColorButton(
            onPressed: () {
              if (hasTextColor) {
                setState(() {
                  widget.editorState.formatDelta(
                    selection,
                    {AppFlowyRichTextKeys.textColor: null},
                  );
                });
              }
            },
            isSelected: !hasTextColor,
          ),
          // color option buttons
          ...colorOptions.map((e) {
            final isSelected = nodes.allSatisfyInSelection(selection, (delta) {
              return delta.everyAttributes(
                (attributes) =>
                    attributes[AppFlowyRichTextKeys.textColor] == e.colorHex,
              );
            });
            return ColorButton(
              colorOption: e,
              onPressed: () {
                if (!isSelected) {
                  setState(() {
                    formatFontColor(
                      widget.editorState,
                      widget.editorState.selection,
                      e.colorHex,
                    );
                  });
                } else {
                  // TODO(yijing): handle when no text is selected
                }
              },
              isSelected: isSelected,
            );
          }).toList(),
        ],
      ),
    );
  }
}
