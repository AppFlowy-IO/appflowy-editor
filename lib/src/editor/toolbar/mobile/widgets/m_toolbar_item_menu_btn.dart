import 'package:flutter/material.dart';

import '../m_colors.dart';

class MToolbarItemMenuBtn extends StatefulWidget {
  const MToolbarItemMenuBtn({
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
  State<MToolbarItemMenuBtn> createState() => _MToolbarItemMenuBtnState();
}

class _MToolbarItemMenuBtnState extends State<MToolbarItemMenuBtn> {
  late bool _isSelected;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.isSelected ?? false;
  }

  @override
  Widget build(BuildContext context) {
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
        foregroundColor: MaterialStateProperty.all(MColors.toolbarTextColor),
        splashFactory: NoSplash.splashFactory,
        side: MaterialStateProperty.resolveWith<BorderSide>((states) {
          if (_isSelected) {
            return const BorderSide(
              color: MColors.toolbarItemHightlightColor,
              width: 2,
            );
          }
          return const BorderSide(color: MColors.toolbarItemOutlineColor);
        }),
      ),
    );
  }
}
