import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class RemoteSelection {
  const RemoteSelection({
    required this.selection,
    required this.selectionColor,
    required this.cursorColor,
  });

  final Selection selection;
  final Color selectionColor;
  final Color cursorColor;
}
