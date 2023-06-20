import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'color.dart';

final textAndBackgroundColorMobileToolbarItem = MobileToolbarItem.withMenu(
  itemIcon: const AFMobileIcon(afMobileIcons: AFMobileIcons.color),
  itemMenuBuilder: (editorState, selection, _) {
    return _TextAndBackgroundColorMenu(editorState, selection);
  },
);

class _TextAndBackgroundColorMenu extends StatefulWidget {
  const _TextAndBackgroundColorMenu(
    this.editorState,
    this.selection, {
    Key? key,
  }) : super(key: key);

  final EditorState editorState;
  final Selection selection;

  @override
  State<_TextAndBackgroundColorMenu> createState() =>
      _TextAndBackgroundColorMenuState();
}

class _TextAndBackgroundColorMenuState
    extends State<_TextAndBackgroundColorMenu> {
  @override
  Widget build(BuildContext context) {
    final style = MobileToolbarStyle.of(context);
    List<Tab> myTabs = <Tab>[
      const Tab(
        text: 'Text Color',
      ),
      const Tab(text: 'Background Color'),
    ];

    return DefaultTabController(
      length: myTabs.length,
      child: Column(
        children: [
          SizedBox(
            height: style.buttonHeight,
            child: TabBar(
              tabs: myTabs,
              labelColor: style.tabbarSelectedForegroundColor,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(style.borderRadius),
                color: style.tabbarSelectedBackgroundColor,
              ),
            ),
          ),
          Container(
            // 3 lines of buttons
            height: 3 * style.buttonHeight + 4 * style.buttonSpacing,
            padding: EdgeInsets.all(style.buttonSpacing),
            child: TabBarView(
              children: [
                TextColorOptionsWidgets(
                  widget.editorState,
                  widget.selection,
                ),
                BackgroundColorOptionsWidgets(
                  widget.editorState,
                  widget.selection,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
