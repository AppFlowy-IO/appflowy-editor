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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      children: [
        Positioned(
          top: position.dy,
          left: position.dx,
          child: Material(
            clipBehavior: Clip.antiAlias,
            elevation: 3,
            color: colorScheme.surfaceContainer,
            surfaceTintColor: colorScheme.surfaceTint,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _buildMenuItems(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildMenuItems(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final menuWidgets = <Widget>[];

    for (var i = 0; i < items.length; i++) {
      for (var j = 0; j < items[i].length; j++) {
        final menuItem = items[i][j];

        if (menuItem.isApplicable != null &&
            !menuItem.isApplicable!(editorState)) {
          continue;
        }

        if (j == 0 && i != 0) {
          menuWidgets.add(const Divider());
        }

        menuWidgets.add(
          InkWell(
            onTap: () {
              menuItem.onPressed(editorState);
              onPressed();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 16.0,
              ),
              child: Text(
                menuItem.name,
                style: textTheme.bodyLarge,
              ),
            ),
          ),
        );
      }
    }

    return menuWidgets;
  }
}
