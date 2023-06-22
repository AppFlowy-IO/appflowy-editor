import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

const indentLTRPadding = EdgeInsets.only(left: 30.0);
const indentRTLPadding = EdgeInsets.only(right: 30.0);

Widget blockPadding(
  Widget child,
  Node node,
  EdgeInsets padding, [
  TextDirection dir = TextDirection.ltr,
]) {
  final indentPadding =
      dir == TextDirection.rtl ? indentRTLPadding : indentLTRPadding;

  var parent = node.parent;
  while (parent != null) {
    padding += indentPadding;
    parent = parent.parent;
  }

  return Padding(padding: padding, child: child);
}
