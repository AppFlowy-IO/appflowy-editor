import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class MobileToolbarItemMenuBtn extends StatefulWidget {
  const MobileToolbarItemMenuBtn({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.isSelected,
  });

  final Function() onPressed;
  final Widget icon;
  final String label;
  final bool? isSelected;

  @override
  State<MobileToolbarItemMenuBtn> createState() =>
      _MobileToolbarItemMenuBtnState();
}

class _MobileToolbarItemMenuBtnState extends State<MobileToolbarItemMenuBtn> {
  late bool _isSelected;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.isSelected ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final style = MobileToolbarStyle.of(context);
    return OutlinedButton.icon(
      onPressed: () {
        setState(() {
          _isSelected = !_isSelected;
          widget.onPressed();
        });
      },
      icon: widget.icon,
      label: Text(widget.label),
      style: ButtonStyle(
        alignment: Alignment.centerLeft,
        foregroundColor: MaterialStateProperty.all(style.foregroundColor),
        splashFactory: NoSplash.splashFactory,
        side: MaterialStateProperty.resolveWith<BorderSide>((states) {
          if (_isSelected) {
            return BorderSide(
              color: style.itemHighlightColor,
              width: 2,
            );
          }
          return BorderSide(color: style.itemOutlineColor);
        }),
      ),
    );
  }
}
