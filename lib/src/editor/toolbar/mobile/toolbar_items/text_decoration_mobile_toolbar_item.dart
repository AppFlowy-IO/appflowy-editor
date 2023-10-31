import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

final textDecorationMobileToolbarItem = MobileToolbarItem.withMenu(
  itemIcon: const AFMobileIcon(afMobileIcons: AFMobileIcons.textDecoration),
  itemMenuBuilder: (editorState, selection, _) {
    return _TextDecorationMenu(editorState, selection);
  },
);

class _TextDecorationMenu extends StatefulWidget {
  const _TextDecorationMenu(
    this.editorState,
    this.selection, {
    Key? key,
  }) : super(key: key);

  final EditorState editorState;
  final Selection selection;

  @override
  State<_TextDecorationMenu> createState() => _TextDecorationMenuState();
}

class _TextDecorationMenuState extends State<_TextDecorationMenu> {
  final textDecorations = [
    TextDecorationUnit(
      icon: AFMobileIcons.bold,
      label: AppFlowyEditorL10n.current.bold,
      name: AppFlowyRichTextKeys.bold,
    ),
    TextDecorationUnit(
      icon: AFMobileIcons.italic,
      label: AppFlowyEditorL10n.current.italic,
      name: AppFlowyRichTextKeys.italic,
    ),
    TextDecorationUnit(
      icon: AFMobileIcons.underline,
      label: AppFlowyEditorL10n.current.underline,
      name: AppFlowyRichTextKeys.underline,
    ),
    TextDecorationUnit(
      icon: AFMobileIcons.strikethrough,
      label: AppFlowyEditorL10n.current.strikethrough,
      name: AppFlowyRichTextKeys.strikethrough,
    ),
  ];
  @override
  Widget build(BuildContext context) {
    final style = MobileToolbarStyle.of(context);
    final btnList = textDecorations.map((currentDecoration) {
      // Check current decoration is active or not
      final nodes = widget.editorState.getNodesInSelection(widget.selection);
      final isSelected = nodes.allSatisfyInSelection(widget.selection, (delta) {
        return delta.everyAttributes(
          (attributes) => attributes[currentDecoration.name] == true,
        );
      });

      return MobileToolbarItemMenuBtn(
        icon: AFMobileIcon(
          afMobileIcons: currentDecoration.icon,
        ),
        label: Text(currentDecoration.label),
        isSelected: isSelected,
        onPressed: () {
          if (widget.selection.isCollapsed) {
            // TODO(yijing): handle collapsed selection
          } else {
            setState(() {
              widget.editorState.toggleAttribute(currentDecoration.name);
            });
          }
        },
      );
    }).toList();

    return GridView(
      shrinkWrap: true,
      gridDelegate: buildMobileToolbarMenuGridDelegate(
        mobileToolbarStyle: style,
        crossAxisCount: 2,
      ),
      children: btnList,
    );
  }
}

class TextDecorationUnit {
  final AFMobileIcons icon;
  final String label;
  final String name;

  TextDecorationUnit({
    required this.icon,
    required this.label,
    required this.name,
  });
}
