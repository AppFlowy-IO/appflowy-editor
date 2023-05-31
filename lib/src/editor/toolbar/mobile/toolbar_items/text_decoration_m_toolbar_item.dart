import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

final textDecorationMToolbarItem = MToolbarItem.withMenu(
  itemIcon: const AFMobileIcon(afMobileIcons: AFMobileIcons.textDecoration),
  itemMenuBuilder: (editorState, selection) {
    final nodes = editorState.getNodesInSelection(selection);
    final isBold = nodes.allSatisfyInSelection(selection, (delta) {
      return delta.everyAttributes(
        (attributes) => attributes['bold'] == true,
      );
    });
    final isItalic = nodes.allSatisfyInSelection(selection, (delta) {
      return delta.everyAttributes(
        (attributes) => attributes['italic'] == true,
      );
    });
    final isUnderline = nodes.allSatisfyInSelection(selection, (delta) {
      return delta.everyAttributes(
        (attributes) => attributes['underline'] == true,
      );
    });
    final isStrikethrough = nodes.allSatisfyInSelection(selection, (delta) {
      return delta.everyAttributes(
        (attributes) => attributes['strikethrough'] == true,
      );
    });

    return GridView(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 5,
      ),
      children: [
        MToolbarItemMenuBtn(
          icon: const AFMobileIcon(
            afMobileIcons: AFMobileIcons.bold,
          ),
          label: AppFlowyEditorLocalizations.current.bold,
          isSelected: isBold,
          onPressed: () {
            editorState.toggleAttribute('bold');
          },
        ),
        MToolbarItemMenuBtn(
          icon: const AFMobileIcon(
            afMobileIcons: AFMobileIcons.italic,
          ),
          label: AppFlowyEditorLocalizations.current.italic,
          isSelected: isItalic,
          onPressed: () {
            editorState.toggleAttribute('italic');
          },
        ),
        MToolbarItemMenuBtn(
          icon: const AFMobileIcon(
            afMobileIcons: AFMobileIcons.underline,
          ),
          label: AppFlowyEditorLocalizations.current.underline,
          isSelected: isUnderline,
          onPressed: () {
            editorState.toggleAttribute('underline');
          },
        ),
        MToolbarItemMenuBtn(
          icon: const AFMobileIcon(
            afMobileIcons: AFMobileIcons.strikethrough,
          ),
          label: AppFlowyEditorLocalizations.current.strikethrough,
          isSelected: isStrikethrough,
          onPressed: () {
            editorState.toggleAttribute('strikethrough');
          },
        ),
      ],
    );
  },
);
