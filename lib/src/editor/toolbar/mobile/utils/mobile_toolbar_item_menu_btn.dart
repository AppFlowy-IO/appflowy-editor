import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class MobileToolbarItemMenuBtn extends StatelessWidget {
  const MobileToolbarItemMenuBtn({
    super.key,
    required this.onPressed,
    this.icon,
    this.label,
    required this.isSelected,
  });

  final Function() onPressed;
  final Widget? icon;
  final Widget? label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final style = MobileToolbarTheme.of(context);
    return OutlinedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        alignment: label == null ? Alignment.center : Alignment.centerLeft,
        foregroundColor: WidgetStateProperty.all(style.foregroundColor),
        splashFactory: NoSplash.splashFactory,
        side: WidgetStateProperty.resolveWith<BorderSide>(
          (states) {
            if (isSelected == true) {
              return BorderSide(
                color: style.itemHighlightColor,
                width: style.buttonSelectedBorderWidth,
              );
            }
            return BorderSide(color: style.itemOutlineColor);
          },
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(style.borderRadius),
          ),
        ),
        padding: WidgetStateProperty.all(
          EdgeInsets.zero,
        ),
      ),
      child: Row(
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 6.0,
              ),
              child: icon!,
            ),
          label ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}
