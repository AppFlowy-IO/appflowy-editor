import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

final headingMobileToolbarItem = MobileToolbarItem.withMenu(
  itemIcon: const AFMobileIcon(afMobileIcons: AFMobileIcons.h1),
  itemMenuBuilder: (editorState, selection) {
    return GridView(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 5,
      ),
      children: const [
        // TODO(yijing): Implement the heading toolbar item.
        // heading 1
        // heading 2
        // heading 3
      ],
    );
  },
);
