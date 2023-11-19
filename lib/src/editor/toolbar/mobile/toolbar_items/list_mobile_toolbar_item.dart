import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

final listMobileToolbarItem = MobileToolbarItem.withMenu(
  itemIconBuilder: (context, __, ___) => AFMobileIcon(
    afMobileIcons: AFMobileIcons.list,
    color: MobileToolbarTheme.of(context).iconColor,
  ),
  itemMenuBuilder: (_, editorState, __) {
    final selection = editorState.selection;
    if (selection == null) {
      return const SizedBox.shrink();
    }
    return _ListMenu(editorState, selection);
  },
);

class _ListMenu extends StatefulWidget {
  const _ListMenu(
    this.editorState,
    this.selection,
  );

  final Selection selection;
  final EditorState editorState;

  @override
  State<_ListMenu> createState() => _ListMenuState();
}

class _ListMenuState extends State<_ListMenu> {
  final lists = [
    ListUnit(
      icon: AFMobileIcons.bulletedList,
      label: AppFlowyEditorL10n.current.bulletedList,
      name: 'bulleted_list',
    ),
    ListUnit(
      icon: AFMobileIcons.numberedList,
      label: AppFlowyEditorL10n.current.numberedList,
      name: 'numbered_list',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    final btnList = lists.map((currentList) {
      // Check if current node is list and its type
      final node =
          widget.editorState.getNodeAtPath(widget.selection.start.path)!;
      final isSelected = node.type == currentList.name;

      return MobileToolbarItemMenuBtn(
        icon: AFMobileIcon(
          afMobileIcons: currentList.icon,
          color: MobileToolbarTheme.of(context).iconColor,
        ),
        label: Text(currentList.label),
        isSelected: isSelected,
        onPressed: () {
          setState(() {
            widget.editorState.formatNode(
              widget.selection,
              (node) => node.copyWith(
                type: isSelected ? ParagraphBlockKeys.type : currentList.name,
                attributes: {
                  ParagraphBlockKeys.delta: (node.delta ?? Delta()).toJson(),
                },
              ),
            );
          });
        },
      );
    }).toList();

    return GridView(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 5,
      ),
      children: btnList,
    );
  }
}

class ListUnit {
  final AFMobileIcons icon;
  final String label;
  final String name;

  ListUnit({
    required this.icon,
    required this.label,
    required this.name,
  });
}
