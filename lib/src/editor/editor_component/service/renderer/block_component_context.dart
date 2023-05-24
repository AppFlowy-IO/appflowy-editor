import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class BlockComponentContext {
  const BlockComponentContext(
    this.buildContext,
    this.node,
  );

  final BuildContext buildContext;
  final Node node;
}
