import 'package:appflowy_editor/src/editor_state.dart';
import 'package:flutter/material.dart';

class ContextMenuItem {
  ContextMenuItem({
    required String Function() getName,
    required this.onPressed,
    this.isApplicable,
  }) : _getName = getName;

  final String Function() _getName;
  final void Function(EditorState editorState) onPressed;
  final bool Function(EditorState editorState)? isApplicable;

  String get name => _getName();
}

class ContextMenu extends StatelessWidget {
  const ContextMenu({
    super.key,
    required this.position,
    required this.editorState,
    required this.items,
    required this.onPressed,
  });

  final Offset position;
  final EditorState editorState;
  final List<List<ContextMenuItem>> items;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      for (var j = 0; j < items[i].length; j++) {
        if (items[i][j].isApplicable != null &&
            !items[i][j].isApplicable!(editorState)) {
          continue;
        }

        if (j == 0 && i != 0) {
          children.add(const Divider());
        }

        children.add(
          StatefulBuilder(
            builder: (BuildContext context, setState) {
              return Material(
                child: InkWell(
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  onTap: () {
                    items[i][j].onPressed(editorState);
                    onPressed();
                  },
                  onHover: (value) => setState(() {}),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      items[i][j].name,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }
    }

    return Positioned(
      top: position.dy,
      left: position.dx,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        constraints: const BoxConstraints(
          minWidth: 140,
        ),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              blurRadius: 5,
              spreadRadius: 1,
              color: Colors.black.withOpacity(0.1),
            ),
          ],
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }
}
