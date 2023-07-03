import 'package:flutter/material.dart';

ButtonStyle buildOverlayButtonStyle(BuildContext context) {
  return ButtonStyle(
    backgroundColor: MaterialStateProperty.resolveWith<Color>(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.hovered)) {
          return Theme.of(context).hoverColor;
        }
        return Colors.transparent;
      },
    ),
  );
}

BoxDecoration buildOverlayDecoration(BuildContext context) {
  return BoxDecoration(
    color: Theme.of(context).cardColor,
    borderRadius: BorderRadius.circular(6),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  );
}

class EditorOverlayTitle extends StatelessWidget {
  const EditorOverlayTitle({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
