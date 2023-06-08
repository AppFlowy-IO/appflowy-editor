import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

final listMobileToolbarItem = MobileToolbarItem.withMenu(
  itemIcon: const AFMobileIcon(afMobileIcons: AFMobileIcons.list),
  itemMenuBuilder: (editorState, selection) {
    return _ListMenu(editorState, selection);
  },
);

class _ListMenu extends StatefulWidget {
  const _ListMenu(
    this.editorState,
    this.selection, {
    Key? key,
  }) : super(key: key);

  final Selection selection;
  final EditorState editorState;

  @override
  State<_ListMenu> createState() => _ListMenuState();
}

class _ListMenuState extends State<_ListMenu> {
  final lists = [
    {
      'icon': AFMobileIcons.bulletedList,
      'label': 'Bulleted List',
      'name': 'bulleted_list',
    },
    {
      'icon': AFMobileIcons.numberedList,
      'label': 'Numbered List',
      'name': 'numbered_list',
    },
  ];
  @override
  Widget build(BuildContext context) {
    final btnList = lists.map((e) {
      final icon = e['icon'] as AFMobileIcons;
      final label = e['label'] as String;
      final name = e['name'] as String;

      // Check if current node is list and its type
      final node =
          widget.editorState.getNodeAtPath(widget.selection.start.path)!;
      final isSelected = node.type == name;

      return MobileToolbarItemMenuBtn(
        icon: AFMobileIcon(afMobileIcons: icon),
        label: label,
        isSelected: isSelected,
        onPressed: () {
          setState(() {
            widget.editorState.formatNode(
              widget.selection,
              (node) => node.copyWith(
                type: isSelected ? 'paragraph' : name,
                attributes: {
                  'delta': (node.delta ?? Delta()).toJson(),
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
      children: [
        ...btnList,
      ],
    );
  }
}
