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
    this.itemHighlightColor = const Color(0xff1F71AC),
    this.itemOutlineColor = const Color(0xFFE3E3E3),
    this.toolbarHeight = 50.0,
    this.borderRadius = 6.0,
  });

  final EditorState editorState;
  final List<MobileToolbarItem> toolbarItems;
  // MobileToolbarStyle parameters
  final Color backgroundColor;
  final Color foregroundColor;
  final Color itemHighlightColor;
  final Color itemOutlineColor;
  final double toolbarHeight;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Selection?>(
      valueListenable: editorState.service.selectionService.currentSelection,
      builder: (_, Selection? selection, __) {
        if (selection == null) {
          return const SizedBox.shrink();
        }
        return MobileToolbarStyle(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          itemHighlightColor: itemHighlightColor,
          itemOutlineColor: itemOutlineColor,
          toolbarHeight: toolbarHeight,
          borderRadius: borderRadius,
          child: MobileToolbarWidget(
            // Use selection as key to force rebuild toolbar widget when selection changed.
            key: ValueKey(selection),
            editorState: editorState,
            selection: selection,
            toolbarItems: toolbarItems,
          ),
        );
      },
    );
  }
}

class MobileToolbarWidget extends StatefulWidget {
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
  State<MobileToolbarWidget> createState() => _MobileToolbarWidgetState();
}

class _MobileToolbarWidgetState extends State<MobileToolbarWidget> {
  late bool _showItmeMenu;
  int? _selectedToolbarItemIndex;

  @override
  void initState() {
    super.initState();
    _showItmeMenu = false;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final style = MobileToolbarStyle.of(context);
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
                  itemOnPressed: (selectedItemIndex) {
                    setState(() {
                      // If last selected item is selected again, toggle item menu
                      if (_selectedToolbarItemIndex == selectedItemIndex) {
                        _showItmeMenu = !_showItmeMenu;
                      } else {
                        // If not, show item menu
                        _showItmeMenu = true;
                      }
                      _selectedToolbarItemIndex = selectedItemIndex;
                    });
                  },
                ),
              ),
              _CloseKeyboardBtn(widget.editorState),
            ],
          ),
        ),
        // only for MobileToolbarItem.withMenu
        _showItmeMenu
            ? MobileToolbarItemMenu(
                key: mobileToolbarItemMenuStateKey,
                editorState: widget.editorState,
                itemMenu: widget.toolbarItems[_selectedToolbarItemIndex!]
                    .itemMenuBuilder!(widget.editorState, widget.selection),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}

class _CloseKeyboardBtn extends StatelessWidget {
  const _CloseKeyboardBtn(this.editorState);

  final EditorState editorState;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: IconButton(
        onPressed: () {
          // clear selection to close keyboard and toolbar
          editorState.selectionService.updateSelection(null);
        },
        icon: const Icon(Icons.keyboard_hide),
      ),
    );
  }
}

class _ToolbarItemListView extends StatelessWidget {
  const _ToolbarItemListView({
    Key? key,
    required this.itemOnPressed,
    required this.toolbarItems,
    required this.editorState,
    required this.selection,
  }) : super(key: key);

  final Function(int index) itemOnPressed;
  final List<MobileToolbarItem> toolbarItems;
  final EditorState editorState;
  final Selection selection;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        final toobarItem = toolbarItems[index];
        return Material(
          color: Colors.transparent,
          child: IconButton(
            icon: toobarItem.itemIcon,
            onPressed: () {
              if (toobarItem.hasMenu) {
                // open /close current item menu through its parent widget(MobileToolbarWidget)
                itemOnPressed.call(index);
              } else {
                toolbarItems[index].actionHandler!(
                  editorState,
                  selection,
                );
              }
            },
          ),
        );
      },
      itemCount: toolbarItems.length,
      scrollDirection: Axis.horizontal,
    );
  }
}
