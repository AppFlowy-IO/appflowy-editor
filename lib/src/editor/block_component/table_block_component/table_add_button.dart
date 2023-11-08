import 'package:flutter/material.dart';

class TableActionButton extends StatefulWidget {
  const TableActionButton({
    super.key,
    required this.width,
    required this.height,
    required this.padding,
    required this.onPressed,
    required this.icon,
  });

  final double width, height;
  final EdgeInsetsGeometry padding;
  final Function onPressed;
  final Widget icon;

  @override
  State<TableActionButton> createState() => _TableActionButtonState();
}

class _TableActionButtonState extends State<TableActionButton> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      width: widget.width,
      height: widget.height,
      child: MouseRegion(
        onEnter: (_) => setState(() => _visible = true),
        onExit: (_) => setState(() => _visible = false),
        child: Center(
          child: Visibility(
            visible: _visible,
            child: Card(
              elevation: 1.0,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => widget.onPressed(),
                  child: widget.icon,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
