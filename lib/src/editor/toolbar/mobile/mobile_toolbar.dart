import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class MobileToolbar extends StatelessWidget {
  const MobileToolbar({
    super.key,
    required this.editorState,
    required this.toolbarItems,
    // default MobileToolbarStyle parameters
    this.backgroundColor = Colors.white,
    this.foregroundColor = const Color(0xff676666),
    this.clearDiagonalLineColor = const Color(0xffB3261E),
    this.itemHighlightColor = const Color(0xff1F71AC),
    this.itemOutlineColor = const Color(0xFFE3E3E3),
    this.tabbarSelectedBackgroundColor = const Color(0x23808080),
    this.tabbarSelectedForegroundColor = Colors.black,
    this.primaryColor = const Color(0xff1F71AC),
    this.onPrimaryColor = Colors.white,
    this.outlineColor = const Color(0xFFE3E3E3),
    this.toolbarHeight = 50.0,
    this.borderRadius = 6.0,
    this.buttonHeight = 40.0,
    this.buttonSpacing = 8.0,
    this.buttonBorderWidth = 1.0,
    this.buttonSelectedBorderWidth = 2.0,
  });
  final EditorState editorState;
  final List<MobileToolbarItem> toolbarItems;
  // MobileToolbarStyle parameters
  final Color backgroundColor;
  final Color foregroundColor;
  final Color clearDiagonalLineColor;
  final Color itemHighlightColor;
  final Color itemOutlineColor;
  final Color tabbarSelectedBackgroundColor;
  final Color tabbarSelectedForegroundColor;
  final Color primaryColor;
  final Color onPrimaryColor;
  final Color outlineColor;
  final double toolbarHeight;
  final double borderRadius;
  final double buttonHeight;
  final double buttonSpacing;
  final double buttonBorderWidth;
  final double buttonSelectedBorderWidth;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Selection?>(
      valueListenable: editorState.selectionNotifier,
      builder: (_, Selection? selection, __) {
        if (selection == null) {
          return const SizedBox.shrink();
        }
        return RepaintBoundary(
          child: MobileToolbarTheme(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            clearDiagonalLineColor: clearDiagonalLineColor,
            itemHighlightColor: itemHighlightColor,
            itemOutlineColor: itemOutlineColor,
            tabBarSelectedBackgroundColor: tabbarSelectedBackgroundColor,
            tabBarSelectedForegroundColor: tabbarSelectedForegroundColor,
            primaryColor: primaryColor,
            onPrimaryColor: onPrimaryColor,
            outlineColor: outlineColor,
            toolbarHeight: toolbarHeight,
            borderRadius: borderRadius,
            buttonHeight: buttonHeight,
            buttonSpacing: buttonSpacing,
            buttonBorderWidth: buttonBorderWidth,
            buttonSelectedBorderWidth: buttonSelectedBorderWidth,
            child: MobileToolbarWidget(
              // Use selection as key to force rebuild toolbar widget when selection changed.
              // key: ValueKey(selection),
              editorState: editorState,
              selection: selection,
              toolbarItems: toolbarItems,
            ),
          ),
        );
      },
    );
  }
}

/// To update the state of the [MobileToolbarWidget]
abstract class MobileToolbarWidgetService {
  /// close item menu and enable keyboard
  void closeItemMenu();
}

class MobileToolbarWidget extends StatefulWidget with WidgetsBindingObserver {
  const MobileToolbarWidget({
    super.key,
    required this.editorState,
    required this.toolbarItems,
    required this.selection,
  });

  final EditorState editorState;
  final List<MobileToolbarItem> toolbarItems;
  final Selection selection;

  @override
  State<MobileToolbarWidget> createState() => MobileToolbarWidgetState();
}

class MobileToolbarWidgetState extends State<MobileToolbarWidget>
    implements MobileToolbarWidgetService {
  bool _showItemMenu = false;
  int? _selectedToolbarItemIndex;

  double previousKeyboardHeight = 0.0;
  bool updateKeyboardHeight = true;

  @override
  void closeItemMenu() {
    if (_showItemMenu) {
      setState(() {
        _showItemMenu = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final style = MobileToolbarTheme.of(context);

    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    if (updateKeyboardHeight) {
      previousKeyboardHeight = keyboardHeight;
    }
    // print('object $keyboardHeight');

    return Column(
      children: [
        Container(
          width: width,
          height: style.toolbarHeight,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: style.itemOutlineColor,
              ),
              bottom: BorderSide(color: style.itemOutlineColor),
            ),
            color: style.backgroundColor,
          ),
          child: Row(
            children: [
              Expanded(
                child: _ToolbarItemListView(
                  editorState: widget.editorState,
                  selection: widget.selection,
                  toolbarItems: widget.toolbarItems,
                  toolbarWidgetService: this,
                  itemWithMenuOnPressed: (selectedItemIndex) {
                    updateKeyboardHeight = false;
                    setState(() {
                      // If last selected item is selected again, toggle item menu
                      if (_selectedToolbarItemIndex == selectedItemIndex) {
                        _showItemMenu = !_showItemMenu;

                        if (!_showItemMenu) {
                          // updateKeyboardHeight = true;
                          widget.editorState.service.keyboardService
                              ?.enableKeyBoard(widget.selection);
                        } else {
                          updateKeyboardHeight = false;
                          widget.editorState.service.keyboardService
                              ?.closeKeyboard();
                        }
                      } else {
                        _selectedToolbarItemIndex = selectedItemIndex;
                        // If not, show item menu
                        _showItemMenu = true;
                        // close keyboard when menu pop up

                        widget.editorState.service.keyboardService
                            ?.closeKeyboard();
                      }
                    });
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: VerticalDivider(),
              ),
              _showItemMenu
                  ? IconButton(
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                      onPressed: () {
                        setState(() {
                          _showItemMenu = false;
                          widget.editorState.service.keyboardService
                              ?.enableKeyBoard(widget.selection);
                        });
                      },
                      icon: AFMobileIcon(
                        afMobileIcons: AFMobileIcons.close,
                        color: MobileToolbarTheme.of(context).iconColor,
                      ),
                    )
                  : _QuitEditingBtn(widget.editorState),
            ],
          ),
        ),
        // only for MobileToolbarItem.withMenu
        (_showItemMenu && _selectedToolbarItemIndex != null)
            ? Container(
                constraints: BoxConstraints(
                  minHeight: previousKeyboardHeight,
                ),
                child: MobileToolbarItemMenu(
                  editorState: widget.editorState,
                  itemMenuBuilder: () =>
                      widget
                          .toolbarItems[_selectedToolbarItemIndex!]
                          // pass current [MobileToolbarWidgetState] to be used to closeItemMenu
                          .itemMenuBuilder!(context, widget.editorState, this) ??
                      const SizedBox.shrink(),
                ),
              )
            : SizedBox(
                height: previousKeyboardHeight,
              ),
      ],
    );
  }
}

class _QuitEditingBtn extends StatelessWidget {
  const _QuitEditingBtn(this.editorState);

  final EditorState editorState;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      alignment: Alignment.centerLeft,
      onPressed: () {
        // clear selection to close keyboard and toolbar
        editorState.selection = null;
      },
      icon: const Icon(Icons.keyboard_hide),
    );
  }
}

class _ToolbarItemListView extends StatelessWidget {
  const _ToolbarItemListView({
    required this.itemWithMenuOnPressed,
    required this.toolbarItems,
    required this.editorState,
    required this.selection,
    required this.toolbarWidgetService,
  });

  final Function(int index) itemWithMenuOnPressed;
  final List<MobileToolbarItem> toolbarItems;
  final EditorState editorState;
  final Selection selection;
  final MobileToolbarWidgetService toolbarWidgetService;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        final toolbarItem = toolbarItems[index];
        final icon = toolbarItem.itemIconBuilder?.call(
          context,
          editorState,
          toolbarWidgetService,
        );
        if (icon == null) {
          return const SizedBox.shrink();
        }
        return IconButton(
          icon: icon,
          onPressed: () {
            if (toolbarItem.hasMenu) {
              // open /close current item menu through its parent widget(MobileToolbarWidget)
              itemWithMenuOnPressed.call(index);
            } else {
              // close menu if other item's menu is still on the screen
              toolbarWidgetService.closeItemMenu();
              toolbarItems[index].actionHandler?.call(
                    context,
                    editorState,
                  );
            }
          },
        );
      },
      itemCount: toolbarItems.length,
      scrollDirection: Axis.horizontal,
    );
  }
}
