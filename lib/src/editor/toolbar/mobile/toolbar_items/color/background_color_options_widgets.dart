import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class BackgroundColorOptionsWidgets extends StatefulWidget {
  const BackgroundColorOptionsWidgets(
    this.editorState,
    this.selection, {
    this.backgroundColorOptions,
    super.key,
  });

  final Selection selection;
  final EditorState editorState;
  final List<ColorOption>? backgroundColorOptions;

  @override
  State<BackgroundColorOptionsWidgets> createState() =>
      _BackgroundColorOptionsWidgetsState();
}

class _BackgroundColorOptionsWidgetsState
    extends State<BackgroundColorOptionsWidgets> {
  @override
  Widget build(BuildContext context) {
    final style = MobileToolbarTheme.of(context);
    final colorOptions =
        widget.backgroundColorOptions ?? generateHighlightColorOptions();
    final selection = widget.selection;
    final nodes = widget.editorState.getNodesInSelection(selection);
    final hasTextColor = nodes.allSatisfyInSelection(selection, (delta) {
      return delta.everyAttributes(
        (attributes) =>
            attributes[AppFlowyRichTextKeys.backgroundColor] != null,
      );
    });

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
                    {AppFlowyRichTextKeys.backgroundColor: null},
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
                    attributes[AppFlowyRichTextKeys.backgroundColor] ==
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
          }),
        ],
      ),
    );
  }
}
