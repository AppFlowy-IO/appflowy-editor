import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

// TODO(yijing): Implement the list toolbar item.
final listMobileToolbarItem = MobileToolbarItem.withMenu(
  itemIcon: const AFMobileIcon(afMobileIcons: AFMobileIcons.list),
  itemMenuBuilder: (editorState, selection) {
    return GridView(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 5,
      ),
      children: const [
        // bullet list
        // numbered list
        // todo list
      ],
    );
  },
);
