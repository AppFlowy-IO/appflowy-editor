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
    this.toolbarHeight = 50.0,
    this.borderRadius = 6.0,
    this.buttonHeight = 40.0,
    this.buttonSpacing = 8.0,
    this.buttonBorderWidth = 1.0,
    this.buttonSelectedBorderWidth = 2.0,
    this.textColorOptions = const [
      ColorOption(
        colorHex: '#808080',
        name: 'Gray',
      ),
      ColorOption(
        colorHex: '#A52A2A',
        name: 'Brown',
      ),
      ColorOption(
        colorHex: '#FFFF00',
        name: 'Yellow',
      ),
      ColorOption(
        colorHex: '#008000',
        name: 'Green',
      ),
      ColorOption(
        colorHex: '#0000FF',
        name: 'Blue',
      ),
      ColorOption(
        colorHex: '#800080',
        name: 'Purple',
      ),
      ColorOption(
        colorHex: '#FFC0CB',
        name: 'Pink',
      ),
      ColorOption(
        colorHex: '#FF0000',
        name: 'Red',
      ),
    ],
    this.backgroundColorOptions = const [
      ColorOption(
        colorHex: '#4d4d4d',
        name: 'Gray',
      ),
      ColorOption(
        colorHex: '#a52a2a',
        name: 'Brown',
      ),
      ColorOption(
        colorHex: '#ffff00',
        name: 'Yellow',
      ),
      ColorOption(
        colorHex: '#008000',
        name: 'Green',
      ),
      ColorOption(
        colorHex: '#0000ff',
        name: 'Blue',
      ),
      ColorOption(
        colorHex: '#800080',
        name: 'Purple',
      ),
      ColorOption(
        colorHex: '#ffc0cb',
        name: 'Pink',
      ),
      ColorOption(
        colorHex: '#ff0000',
        name: 'Red',
      ),
    ],
  }) : assert(
          textColorOptions.length > 0 && backgroundColorOptions.length > 0,
        );

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
  final double toolbarHeight;
  final double borderRadius;
  final double buttonHeight;
  final double buttonSpacing;
  final double buttonBorderWidth;
  final double buttonSelectedBorderWidth;
  final List<ColorOption> textColorOptions;
  final List<ColorOption> backgroundColorOptions;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Selection?>(
      valueListenable: editorState.selectionNotifier,
      builder: (_, Selection? selection, __) {
        if (selection == null) {
          return const SizedBox.shrink();
        }
        return MobileToolbarStyle(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          clearDiagonalLineColor: clearDiagonalLineColor,
          itemHighlightColor: itemHighlightColor,
          itemOutlineColor: itemOutlineColor,
          tabbarSelectedBackgroundColor: tabbarSelectedBackgroundColor,
          tabbarSelectedForegroundColor: tabbarSelectedForegroundColor,
          toolbarHeight: toolbarHeight,
          borderRadius: borderRadius,
          buttonHeight: buttonHeight,
          buttonSpacing: buttonSpacing,
          buttonBorderWidth: buttonBorderWidth,
          buttonSelectedBorderWidth: buttonSelectedBorderWidth,
          textColorOptions: textColorOptions,
          backgroundColorOptions: backgroundColorOptions,
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
  bool _showItemMenu = false;
  int? _selectedToolbarItemIndex;

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
                        _showItemMenu = !_showItemMenu;
                      } else {
                        // If not, show item menu
                        _showItemMenu = true;
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
        if (_showItemMenu && _selectedToolbarItemIndex != null)
          // MobileToolbarItemMenuState implements MobileToolbarItemMenuService
          MobileToolbarItemMenu(
            editorState: widget.editorState,
            itemMenuBuilder: (mobileToolbarItemMenuState) => widget
                .toolbarItems[_selectedToolbarItemIndex!].itemMenuBuilder!(
              widget.editorState,
              widget.selection,
              mobileToolbarItemMenuState,
            ),
          )
      ],
    );
  }
}

class _CloseKeyboardBtn extends StatelessWidget {
  const _CloseKeyboardBtn(this.editorState);

  final EditorState editorState;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        // clear selection to close keyboard and toolbar
        editorState.selectionService.updateSelection(null);
      },
      icon: const Icon(Icons.keyboard_hide),
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
        return IconButton(
          icon: toobarItem.itemIcon,
          onPressed: () {
            if (toobarItem.hasMenu) {
              // open /close current item menu through its parent widget(MobileToolbarWidget)
              itemOnPressed.call(index);
            } else {
              toolbarItems[index].actionHandler?.call(
                    editorState,
                    selection,
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
