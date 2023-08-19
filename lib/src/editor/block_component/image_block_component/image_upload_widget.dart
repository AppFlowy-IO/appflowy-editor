import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import '../../util/file_picker/file_picker_impl.dart';
import 'widgets/url_tab.dart';
import 'widgets/file_tab.dart';

enum ImageFromFileStatus {
  notSelected,
  selected,
}

typedef OnInsertImage = void Function(String url);

void showImageMenu(
  OverlayState container,
  EditorState editorState,
  SelectionMenuService menuService, {
  OnInsertImage? onInsertImage,
}) {
  menuService.dismiss();

  final (left, top, right, bottom) = menuService.getPosition();

  late final OverlayEntry imageMenuEntry;

  void insertImage(
    String url,
  ) {
    if (onInsertImage != null) {
      onInsertImage(url);
    } else {
      editorState.insertImageNode(url);
    }
    menuService.dismiss();
    imageMenuEntry.remove();
    keepEditorFocusNotifier.value -= 1;
  }

  keepEditorFocusNotifier.value += 1;
  imageMenuEntry = FullScreenOverlayEntry(
    left: left,
    right: right,
    top: top,
    bottom: bottom,
    dismissCallback: () => keepEditorFocusNotifier.value -= 1,
    builder: (context) => UploadImageMenu(
      backgroundColor: menuService.style.selectionMenuBackgroundColor,
      headerColor: menuService.style.selectionMenuItemTextColor,
      width: MediaQuery.of(context).size.width * 0.4,
      onSubmitted: insertImage,
      onUpload: insertImage,
    ),
  ).build();
  container.insert(imageMenuEntry);
}

class UploadImageMenu extends StatefulWidget {
  const UploadImageMenu({
    Key? key,
    this.backgroundColor = Colors.white,
    this.headerColor = Colors.black,
    this.width = 300,
    required this.onSubmitted,
    required this.onUpload,
  }) : super(key: key);

  final Color backgroundColor;
  final Color headerColor;
  final double width;
  final void Function(String text) onSubmitted;
  final void Function(String text) onUpload;

  @override
  State<UploadImageMenu> createState() => _UploadImageMenuState();
}

class _UploadImageMenuState extends State<UploadImageMenu> {
  final _textEditingController = TextEditingController();
  final _focusNode = FocusNode();
  final _filePicker = FilePicker();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: 300,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        boxShadow: [
          BoxShadow(
            blurRadius: 5,
            spreadRadius: 1,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
        // borderRadius: BorderRadius.circular(6.0),
      ),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 300,
                child: TabBar(
                  tabs: const [
                    Tab(text: 'Upload Image'),
                    Tab(text: 'URL Image'),
                  ],
                  labelColor: widget.headerColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: const Color(0xff00BCF0),
                  dividerColor: Colors.transparent,
                  onTap: (value) {
                    if (value == 1) {
                      _focusNode.requestFocus();
                    } else {
                      _focusNode.unfocus();
                    }
                  },
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  BuildFileTab(
                    filePicker: _filePicker,
                    onUpload: widget.onUpload,
                    textEditingController: _textEditingController,
                  ),
                  BuildUrlTab(
                    focusNode: _focusNode,
                    textEditingController: _textEditingController,
                    onSubmitted: widget.onSubmitted,
                    onUpload: widget.onUpload,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension InsertImage on EditorState {
  Future<void> insertImageNode(
    String src,
  ) async {
    final selection = this.selection;
    if (selection == null || !selection.isCollapsed) {
      return;
    }
    final node = getNodeAtPath(selection.end.path);
    if (node == null) {
      return;
    }
    final transaction = this.transaction;
    // if the current node is empty paragraph, replace it with image node
    if (node.type == ParagraphBlockKeys.type &&
        (node.delta?.isEmpty ?? false)) {
      transaction
        ..insertNode(
          node.path,
          imageNode(
            url: src,
          ),
        )
        ..deleteNode(node);
    } else {
      transaction.insertNode(
        node.path.next,
        imageNode(
          url: src,
        ),
      );
    }

    return apply(transaction);
  }
}
