import 'package:flutter/material.dart';

enum NestedListMode {
  stack,
  column,
}

class NestedListWidget extends StatelessWidget {
  const NestedListWidget({
    super.key,
    this.indentPadding = const EdgeInsets.only(left: 28),
    this.mode = NestedListMode.column,
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

  /// The mode of the nested list.
  final NestedListMode mode;

  final Widget child;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return switch (mode) {
      NestedListMode.stack => Stack(
          children: [
            child,
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ],
        ),
      NestedListMode.column => Column(
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
        ),
    };
  }
}
