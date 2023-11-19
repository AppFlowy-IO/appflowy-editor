import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class ColorButton extends StatelessWidget {
  const ColorButton({
    super.key,
    required this.colorOption,
    required this.isSelected,
    required this.onPressed,
    this.isBackgroundColor = false,
  });

  final ColorOption colorOption;
  final bool isBackgroundColor;
  final bool isSelected;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final style = MobileToolbarTheme.of(context);
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: style.buttonHeight,
        decoration: BoxDecoration(
          color: isBackgroundColor
              ? colorOption.colorHex.tryToColor()
              : Colors.transparent,
          borderRadius: BorderRadius.circular(style.borderRadius),
          border: isSelected
              ? Border.all(
                  color: style.itemHighlightColor,
                  width: style.buttonSelectedBorderWidth,
                )
              : Border.all(
                  color: style.itemOutlineColor,
                  width: style.buttonBorderWidth,
                ),
        ),
        child: isBackgroundColor
            ? null
            : Center(
                child: Text(
                  colorOption.name,
                  style: TextStyle(color: colorOption.colorHex.tryToColor()),
                ),
              ),
      ),
    );
  }
}
