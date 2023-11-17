import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

MobileToolbarItem buildTextAndBackgroundColorMobileToolbarItem({
  List<ColorOption>? textColorOptions,
  List<ColorOption>? backgroundColorOptions,
}) {
  return MobileToolbarItem.withMenu(
    itemIconBuilder: (context, __, ___) => AFMobileIcon(
      afMobileIcons: AFMobileIcons.color,
      color: MobileToolbarTheme.of(context).iconColor,
    ),
    itemMenuBuilder: (_, editorState, ___) {
      final selection = editorState.selection;
      if (selection == null) {
        return const SizedBox.shrink();
      }
      return _TextAndBackgroundColorMenu(
        editorState,
        selection,
        textColorOptions: textColorOptions,
        backgroundColorOptions: backgroundColorOptions,
      );
    },
  );
}

class _TextAndBackgroundColorMenu extends StatefulWidget {
  const _TextAndBackgroundColorMenu(
    this.editorState,
    this.selection, {
    this.textColorOptions,
    this.backgroundColorOptions,
  });

  final EditorState editorState;
  final Selection selection;
  final List<ColorOption>? textColorOptions;
  final List<ColorOption>? backgroundColorOptions;

  @override
  State<_TextAndBackgroundColorMenu> createState() =>
      _TextAndBackgroundColorMenuState();
}

class _TextAndBackgroundColorMenuState
    extends State<_TextAndBackgroundColorMenu> {
  @override
  Widget build(BuildContext context) {
    final style = MobileToolbarTheme.of(context);
    List<Tab> myTabs = <Tab>[
      Tab(
        text: AppFlowyEditorL10n.current.textColor,
      ),
      Tab(text: AppFlowyEditorL10n.current.backgroundColor),
    ];

    return DefaultTabController(
      length: myTabs.length,
      child: Column(
        children: [
          SizedBox(
            height: style.buttonHeight,
            child: TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: myTabs,
              labelColor: style.tabBarSelectedBackgroundColor,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(style.borderRadius),
                color: style.tabBarSelectedForegroundColor,
              ),
              // remove the bottom line of TabBar
              dividerColor: Colors.transparent,
            ),
          ),
          SizedBox(
            // 3 lines of buttons
            height: 3 * style.buttonHeight + 4 * style.buttonSpacing,
            child: TabBarView(
              children: [
                TextColorOptionsWidgets(
                  widget.editorState,
                  widget.selection,
                  textColorOptions: widget.textColorOptions,
                ),
                BackgroundColorOptionsWidgets(
                  widget.editorState,
                  widget.selection,
                  backgroundColorOptions: widget.backgroundColorOptions,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
