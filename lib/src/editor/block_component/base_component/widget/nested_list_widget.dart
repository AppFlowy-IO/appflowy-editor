import 'package:flutter/material.dart';

class NestedListWidget extends StatelessWidget {
  const NestedListWidget({
    super.key,
    this.padding = const EdgeInsets.only(left: 30.0),
    required this.child,
    required this.children,
  });

  final EdgeInsets padding;
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
          padding: padding,
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
