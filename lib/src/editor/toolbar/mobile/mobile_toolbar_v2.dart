import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_height_plugin/keyboard_height_plugin.dart';

class MobileToolbarV2 extends StatefulWidget {
  const MobileToolbarV2({
    super.key,
    required this.editorState,
    required this.toolbarItems,
    required this.toolbarHeight,
    required this.child,
  });

  final EditorState editorState;
  final List<MobileToolbarItem> toolbarItems;
  final double toolbarHeight;
  final Widget child;

  @override
  State<MobileToolbarV2> createState() => _MobileToolbarV2State();
}

class _MobileToolbarV2State extends State<MobileToolbarV2> {
  OverlayEntry? toolbarOverlay;

  @override
  void initState() {
    super.initState();

    _insertKeyboardToolbar();
  }

  @override
  void dispose() {
    _removeKeyboardToolbar();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: widget.child,
        ),
        // add a bottom offset to make sure the toolbar is above the keyboard
        SizedBox(
          height: widget.toolbarHeight,
        ),
      ],
    );
  }

  void _removeKeyboardToolbar() {
    toolbarOverlay?.remove();
    toolbarOverlay?.dispose();
    toolbarOverlay = null;
  }

  void _insertKeyboardToolbar() {
    _removeKeyboardToolbar();

    Widget child = ValueListenableBuilder<Selection?>(
      valueListenable: widget.editorState.selectionNotifier,
      builder: (_, Selection? selection, __) {
        // if the selection is null, hide the toolbar
        if (selection == null) {
          return const SizedBox.shrink();
        }

        Widget child = _MobileToolbar(
          editorState: widget.editorState,
          toolbarItems: widget.toolbarItems,
        );

        // if the MobileToolbarTheme is not provided, provide it
        if (MobileToolbarTheme.maybeOf(context) == null) {
          child = MobileToolbarTheme(
            child: child,
          );
        }

        return RepaintBoundary(
          child: child,
        );
      },
    );

    child = Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Material(
            child: child,
          ),
        ),
      ],
    );

    toolbarOverlay = OverlayEntry(
      builder: (context) {
        return child;
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Overlay.of(context, rootOverlay: true).insert(toolbarOverlay!);
    });
  }
}

class _MobileToolbar extends StatefulWidget {
  const _MobileToolbar({
    required this.editorState,
    required this.toolbarItems,
  });

  final EditorState editorState;
  final List<MobileToolbarItem> toolbarItems;

  @override
  State<_MobileToolbar> createState() => _MobileToolbarState();
}

class _MobileToolbarState extends State<_MobileToolbar>
    implements MobileToolbarWidgetService {
  // used to control the toolbar menu items
  PropertyValueNotifier<bool> showMenuNotifier = PropertyValueNotifier(false);

  // when the users click the menu item, the keyboard will be hidden,
  //  but in this case, we don't want to update the cached keyboard height.
  // This is because we want to keep the same height when the menu is shown.
  bool canUpdateCachedKeyboardHeight = true;
  ValueNotifier<double> cachedKeyboardHeight = ValueNotifier(0.0);
  final keyboardHeightPlugin = KeyboardHeightPlugin();

  // used to check if click the same item again
  int? selectedMenuIndex;

  Selection? currentSelection;

  @override
  void initState() {
    super.initState();

    currentSelection = widget.editorState.selection;
    keyboardHeightPlugin.onKeyboardHeightChanged((height) {
      if (canUpdateCachedKeyboardHeight) {
        cachedKeyboardHeight.value = height;
      }
    });
  }

  @override
  void didUpdateWidget(covariant _MobileToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (currentSelection != widget.editorState.selection) {
      currentSelection = widget.editorState.selection;
      closeItemMenu();
    }
  }

  @override
  void dispose() {
    showMenuNotifier.dispose();
    cachedKeyboardHeight.dispose();
    keyboardHeightPlugin.dispose();

    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();

    canUpdateCachedKeyboardHeight = true;
    closeItemMenu();
    _closeKeyboard();
  }

  @override
  Widget build(BuildContext context) {
    // toolbar
    //  - if the menu is shown, the toolbar will be pushed up by the height of the menu
    //  - otherwise, add a spacer to push the toolbar up when the keyboard is shown
    return Column(
      children: [
        _buildToolbar(context),
        _buildMenuOrSpacer(context),
      ],
    );
  }

  @override
  void closeItemMenu() {
    showMenuNotifier.value = false;
  }

  void showItemMenu() {
    showMenuNotifier.value = true;
  }

  // toolbar list view and close keyboard/menu button
  Widget _buildToolbar(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final style = MobileToolbarTheme.of(context);

    return Container(
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // toolbar list view
          Expanded(
            child: _ToolbarItemListView(
              toolbarItems: widget.toolbarItems,
              editorState: widget.editorState,
              toolbarWidgetService: this,
              itemWithActionOnPressed: (_) {
                if (showMenuNotifier.value) {
                  closeItemMenu();
                  _showKeyboard();
                  // update the cached keyboard height after the keyboard is shown
                  Debounce.debounce('canUpdateCachedKeyboardHeight',
                      const Duration(milliseconds: 500), () {
                    canUpdateCachedKeyboardHeight = true;
                  });
                }
              },
              itemWithMenuOnPressed: (index) {
                // click the same one
                if (selectedMenuIndex == index && showMenuNotifier.value) {
                  // if the menu is shown, close it and show the keyboard
                  closeItemMenu();
                  _showKeyboard();
                  // update the cached keyboard height after the keyboard is shown
                  Debounce.debounce('canUpdateCachedKeyboardHeight',
                      const Duration(milliseconds: 500), () {
                    canUpdateCachedKeyboardHeight = true;
                  });
                } else {
                  canUpdateCachedKeyboardHeight = false;
                  selectedMenuIndex = index;
                  showItemMenu();
                  _closeKeyboard();
                }
              },
            ),
          ),
          // divider
          const Padding(
            padding: EdgeInsets.symmetric(
              vertical: 8,
            ),
            child: VerticalDivider(
              width: 1,
            ),
          ),
          // close menu or close keyboard button
          ValueListenableBuilder(
            valueListenable: showMenuNotifier,
            builder: (_, showingMenu, __) {
              return _CloseKeyboardOrMenuButton(
                showingMenu: showingMenu,
                onPressed: () {
                  if (showingMenu) {
                    // close the menu and show the keyboard
                    closeItemMenu();
                    _showKeyboard();
                  } else {
                    // close the keyboard and clear the selection
                    // if the selection is null, the keyboard and the toolbar will be hidden automatically
                    widget.editorState.selection = null;
                  }
                },
              );
            },
          ),
          const SizedBox(
            width: 4.0,
          ),
        ],
      ),
    );
  }

  // if there's no menu, we need to add a spacer to push the toolbar up when the keyboard is shown
  Widget _buildMenuOrSpacer(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: cachedKeyboardHeight,
      builder: (_, height, ___) {
        return ValueListenableBuilder(
          valueListenable: showMenuNotifier,
          builder: (_, showingMenu, __) {
            return SizedBox(
              height: height,
              child: (showingMenu && selectedMenuIndex != null)
                  ? MobileToolbarItemMenu(
                      editorState: widget.editorState,
                      itemMenuBuilder: () =>
                          widget
                              .toolbarItems[selectedMenuIndex!].itemMenuBuilder!
                              .call(
                            context,
                            widget.editorState,
                            this,
                          ) ??
                          const SizedBox.shrink(),
                    )
                  : const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }

  void _showKeyboard() {
    final selection = widget.editorState.selection;
    if (selection != null) {
      widget.editorState.service.keyboardService?.enableKeyBoard(selection);
    }
  }

  void _closeKeyboard() {
    widget.editorState.service.keyboardService?.closeKeyboard();
  }
}

class _ToolbarItemListView extends StatelessWidget {
  const _ToolbarItemListView({
    required this.toolbarItems,
    required this.editorState,
    required this.toolbarWidgetService,
    required this.itemWithMenuOnPressed,
    required this.itemWithActionOnPressed,
  });

  final Function(int index) itemWithMenuOnPressed;
  final Function(int index) itemWithActionOnPressed;
  final List<MobileToolbarItem> toolbarItems;
  final EditorState editorState;
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
              itemWithMenuOnPressed(index);
            } else {
              itemWithActionOnPressed(index);
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

class _CloseKeyboardOrMenuButton extends StatelessWidget {
  const _CloseKeyboardOrMenuButton({
    required this.showingMenu,
    required this.onPressed,
  });

  final bool showingMenu;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      icon: showingMenu
          ? const AFMobileIcon(
              afMobileIcons: AFMobileIcons.close,
            )
          : const Icon(Icons.keyboard_hide),
    );
  }
}
