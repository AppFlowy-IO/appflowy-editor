import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

ToolbarItem placeholderItem = ToolbarItem(
  id: 'editor.placeholder',
  isActive: (editorState) => true,
  builder: (_, __) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      child: Container(
        width: 1,
        color: Colors.grey,
      ),
    );
  },
);
