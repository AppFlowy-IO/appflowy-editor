import 'package:flutter/material.dart';

class NestedListWidget extends StatelessWidget {
  const NestedListWidget({
    super.key,
    this.indentPadding = const EdgeInsets.only(left: 28),
    required this.child,
    required this.children,
  });

  /// used to indent the nested list when the children's level is greater than 1.
  ///
  /// For example,
  ///
  /// Hello AppFlowy
  ///   Hello AppFlowy
  /// ↑
  /// the indent padding is applied to the second line.
  final EdgeInsets indentPadding;

  final Widget child;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        child,
        Padding(
          padding: indentPadding,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }
}
