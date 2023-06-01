import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

final textDecorationMToolbarItem = MToolbarItem.withMenu(
  itemIcon: const AFMobileIcon(afMobileIcons: AFMobileIcons.textDecoration),
  itemMenuBuilder: (editorState, selection) {
    final textDecorations = [
      {
        'icon': AFMobileIcons.bold,
        'label': AppFlowyEditorLocalizations.current.bold,
        'name': 'bold',
      },
      {
        'icon': AFMobileIcons.italic,
        'label': AppFlowyEditorLocalizations.current.italic,
        'name': 'italic',
      },
      {
        'icon': AFMobileIcons.underline,
        'label': AppFlowyEditorLocalizations.current.underline,
        'name': 'underline',
      },
      {
        'icon': AFMobileIcons.strikethrough,
        'label': AppFlowyEditorLocalizations.current.strikethrough,
        'name': 'strikethrough',
      },
    ];

    final btnList = textDecorations.map((e) {
      final icon = e['icon'] as AFMobileIcons;
      final label = e['label'] as String;
      final name = e['name'] as String;

      // Check current decoration is active or not
      final nodes = editorState.getNodesInSelection(selection);
      final isSelected = nodes.allSatisfyInSelection(selection, (delta) {
        return delta.everyAttributes(
          (attributes) => attributes[name] == true,
        );
      });

      return MToolbarItemMenuBtn(
        icon: AFMobileIcon(
          afMobileIcons: icon,
        ),
        label: label,
        isSelected: isSelected,
        onPressed: () {
          if (selection.isCollapsed) {
            // TODO(yijing): handle collapsed selection
          } else {
            editorState.toggleAttribute(name);
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
  },
);
