import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class MobileToolbarItemMenuBtn extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final style = MobileToolbarStyle.of(context);
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: Text(label),
      style: ButtonStyle(
        alignment: Alignment.centerLeft,
        foregroundColor: MaterialStateProperty.all(style.foregroundColor),
        splashFactory: NoSplash.splashFactory,
        side: MaterialStateProperty.resolveWith<BorderSide>((states) {
          if (isSelected == true) {
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
