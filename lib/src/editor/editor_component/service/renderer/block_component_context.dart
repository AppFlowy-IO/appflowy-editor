import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

typedef BlockComponentWrapper = Widget Function(
  BuildContext context, {
  required Node node,
  required Widget child,
});

class BlockComponentContext {
  const BlockComponentContext(
    this.buildContext,
    this.node, {
    this.header,
    this.footer,
    this.wrapper,
  });

  final BuildContext buildContext;
  final Node node;

  /// the header and the footer only work for root node.
  final Widget? header;
  final Widget? footer;

  /// Wrap the block component with a widget.
  final BlockComponentWrapper? wrapper;
}
