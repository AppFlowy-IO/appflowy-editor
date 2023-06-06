import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

final textDecorationMobileToolbarItem = MobileToolbarItem.withMenu(
  itemIcon: const AFMobileIcon(afMobileIcons: AFMobileIcons.textDecoration),
  itemMenuBuilder: (editorState, selection) {
    return _TextDecorationMenu(editorState, selection);
  },
);

class _TextDecorationMenu extends StatefulWidget {
  const _TextDecorationMenu(
    this.editorState,
    this.selection, {
    Key? key,
  }) : super(key: key);

  final EditorState editorState;
  final Selection selection;

  @override
  State<_TextDecorationMenu> createState() => _TextDecorationMenuState();
}

class _TextDecorationMenuState extends State<_TextDecorationMenu> {
  final textDecorations = [
    {
      'icon': AFMobileIcons.bold,
      'label': AppFlowyEditorLocalizations.current.bold,
      'name': FlowyRichTextKeys.bold,
    },
    {
      'icon': AFMobileIcons.italic,
      'label': AppFlowyEditorLocalizations.current.italic,
      'name': FlowyRichTextKeys.italic,
    },
    {
      'icon': AFMobileIcons.underline,
      'label': AppFlowyEditorLocalizations.current.underline,
      'name': FlowyRichTextKeys.underline,
    },
    {
      'icon': AFMobileIcons.strikethrough,
      'label': AppFlowyEditorLocalizations.current.strikethrough,
      'name': FlowyRichTextKeys.strikethrough,
    },
  ];
  @override
  Widget build(BuildContext context) {
    final btnList = textDecorations.map((e) {
      final icon = e['icon'] as AFMobileIcons;
      final label = e['label'] as String;
      final name = e['name'] as String;

      // Check current decoration is active or not
      final nodes = widget.editorState.getNodesInSelection(widget.selection);
      final isSelected = nodes.allSatisfyInSelection(widget.selection, (delta) {
        return delta.everyAttributes(
          (attributes) => attributes[name] == true,
        );
      });

      return MobileToolbarItemMenuBtn(
        icon: AFMobileIcon(
          afMobileIcons: icon,
        ),
        label: label,
        isSelected: isSelected,
        onPressed: () {
          if (widget.selection.isCollapsed) {
            // TODO(yijing): handle collapsed selection
          } else {
            setState(() {
              widget.editorState.toggleAttribute(name);
            });
          }
        },
      );
    }).toList();

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 5,
          ),
          children: [...btnList],
        ),
        // TODO(yijing): Add color after showColorMenu moved into desktop
        // Text(AppFlowyEditorLocalizations.current.textColor),
        // Text(AppFlowyEditorLocalizations.current.highlightColor),
      ],
    );
  }
}
