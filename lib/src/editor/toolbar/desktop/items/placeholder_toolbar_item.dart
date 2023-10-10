import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

const placeholderItemId = 'editor.placeholder';

final ToolbarItem placeholderItem = ToolbarItem(
  id: placeholderItemId,
  group: -1,
  isActive: (editorState) => true,
  builder: (_, __, ___, ____) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      child: Container(
        width: 1,
        color: Colors.grey,
      ),
    );
  },
);
