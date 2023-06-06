import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

final headingMobileToolbarItem = MobileToolbarItem.withMenu(
  itemIcon: const AFMobileIcon(afMobileIcons: AFMobileIcons.h1),
  itemMenuBuilder: (editorState, selection) {
    return _HeadingMenu(
      selection,
      editorState,
    );
  },
);

class _HeadingMenu extends StatefulWidget {
  const _HeadingMenu(
    this.selection,
    this.editorState, {
    Key? key,
  }) : super(key: key);

  final Selection selection;
  final EditorState editorState;

  @override
  State<_HeadingMenu> createState() => _HeadingMenuState();
}

class _HeadingMenuState extends State<_HeadingMenu> {
  final headings = [
    {
      'icon': AFMobileIcons.h1,
      'label': 'Heading 1',
      'level': 1,
    },
    {
      'icon': AFMobileIcons.h2,
      'label': 'Heading 2',
      'level': 2,
    },
    {
      'icon': AFMobileIcons.h3,
      'label': 'Heading 3',
      'level': 3,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final btnList = headings.map((e) {
      final icon = e['icon'] as AFMobileIcons;
      final label = e['label'] as String;
      final level = e['level'] as int;

      // Check if current node is heading and its level
      final node =
          widget.editorState.getNodeAtPath(widget.selection.start.path)!;
      final isSelected =
          node.type == 'heading' && node.attributes['level'] == level;

      return MobileToolbarItemMenuBtn(
        icon: AFMobileIcon(afMobileIcons: icon),
        label: label,
        isSelected: isSelected,
        onPressed: () {
          setState(() {
            widget.editorState.formatNode(
              widget.selection,
              (node) => node.copyWith(
                type: isSelected
                    ? ParagraphBlockKeys.type
                    : HeadingBlockKeys.type,
                attributes: {
                  HeadingBlockKeys.level: level,
                  HeadingBlockKeys.backgroundColor:
                      node.attributes[blockComponentBackgroundColor],
                  'delta': (node.delta ?? Delta()).toJson(),
                },
              ),
            );
          });
        },
      );
    }).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ...btnList,
      ],
    );
  }
}
