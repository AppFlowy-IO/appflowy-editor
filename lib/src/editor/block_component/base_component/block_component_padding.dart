import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class BlockComponentPadding extends StatelessWidget {
  const BlockComponentPadding({
    super.key,
    required this.node,
    required this.padding,
    this.indentPadding = EdgeInsets.zero,
    required this.child,
  });

  final Node node;
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets indentPadding;

  @override
  Widget build(BuildContext context) {
    final level = node.level.toDouble();
    return Padding(
      padding: padding,
      child: Padding(
        padding: indentPadding * level,
        child: child,
      ),
    );
  }
}
