import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class ClearColorButton extends StatelessWidget {
  const ClearColorButton({
    super.key,
    required this.onPressed,
    required this.isSelected,
  });
  final void Function() onPressed;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final style = MobileToolbarTheme.of(context);

    return InkWell(
      onTap: onPressed,
      child: Container(
        height: style.buttonHeight,
        decoration: BoxDecoration(
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
        child: CustomPaint(
          painter: _DiagonalLinePainter(style.clearDiagonalLineColor),
        ),
      ),
    );
  }
}

class _DiagonalLinePainter extends CustomPainter {
  _DiagonalLinePainter(this.diagonalLineColor);
  final Color diagonalLineColor;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = diagonalLineColor
      ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, 0),
      paint,
    );
  }

  @override
  bool shouldRepaint(_DiagonalLinePainter oldDelegate) => false;
}
