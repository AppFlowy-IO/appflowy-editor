import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/image_block_component/base64_image.dart';
import 'package:flutter/material.dart';
import '../../util/file_picker/file_picker_impl.dart';
import 'package:file_picker/file_picker.dart' as fp;

enum ImageFromFileStatus {
  notSelected,
  selected,
}

void showImageMenu(
  OverlayState container,
  EditorState editorState,
  SelectionMenuService menuService,
) {
  menuService.dismiss();

  final (left, top, bottom) = menuService.getPosition();

  late final OverlayEntry imageMenuEntry;

  void insertImage(
    String src, {
    ImageSourceType imageSourceType = ImageSourceType.network,
  }) {
    editorState.insertImageNode(src, imageSourceType);
    menuService.dismiss();
    imageMenuEntry.remove();
    keepEditorFocusNotifier.value -= 1;
  }

  keepEditorFocusNotifier.value += 1;
  imageMenuEntry = FullScreenOverlayEntry(
    left: left,
    top: top,
    bottom: bottom,
    dismissCallback: () => keepEditorFocusNotifier.value -= 1,
    builder: (context) => UploadImageMenu(
      backgroundColor: menuService.style.selectionMenuBackgroundColor,
      headerColor: menuService.style.selectionMenuItemTextColor,
      width: MediaQuery.of(context).size.width * 0.5,
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
  final void Function(String text, {ImageSourceType imageSourceType}) onUpload;

  @override
  State<UploadImageMenu> createState() => _UploadImageMenuState();
}

class _UploadImageMenuState extends State<UploadImageMenu> {
  static const allowedExtensions = ['jpg', 'png', 'jpeg'];

  final _textEditingController = TextEditingController();
  final _focusNode = FocusNode();
  final _filePicker = FilePicker();

  String? _localImagePath;

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
      height: 350,
      padding: const EdgeInsets.all(24.0),
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
            const Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 300,
                child: TabBar(
                  tabs: [
                    Tab(text: 'Upload Image'),
                    Tab(text: 'URL Image'),
                  ],
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Color(0xff00BCF0),
                  dividerColor: Colors.transparent,
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildFileTab(context),
                  _buildUrlTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Text(
      'URL Image',
      textAlign: TextAlign.left,
      style: TextStyle(
        fontSize: 14.0,
        color: widget.headerColor,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildInput() {
    return TextField(
      focusNode: _focusNode,
      style: const TextStyle(fontSize: 14.0),
      textAlign: TextAlign.left,
      controller: _textEditingController,
      onSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        hintText: 'URL',
        hintStyle: const TextStyle(fontSize: 14.0),
        contentPadding: const EdgeInsets.all(16.0),
        isDense: true,
        suffixIcon: IconButton(
          padding: const EdgeInsets.all(4.0),
          icon: const FlowySvg(
            name: 'clear',
            width: 24,
            height: 24,
          ),
          onPressed: _textEditingController.clear,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          borderSide: BorderSide(color: Color(0xFFBDBDBD)),
        ),
      ),
    );
  }

  Widget _buildUploadButton(
    BuildContext context,
    ImageSourceType imageSourceType,
  ) {
    return SizedBox(
      width: 170,
      height: 48,
      child: TextButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(const Color(0xFF00BCF0)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
        onPressed: () async {
          if (imageSourceType == ImageSourceType.network) {
            widget.onUpload(
              _textEditingController.text,
              imageSourceType: imageSourceType,
            );
          } else if (imageSourceType == ImageSourceType.file &&
              _localImagePath != null) {
            final content = await base64StringFromImage(_localImagePath!);
            widget.onUpload(
              content,
              imageSourceType: imageSourceType,
            );
          }
        },
        child: const Text(
          'Upload',
          style: TextStyle(color: Colors.white, fontSize: 14.0),
        ),
      ),
    );
  }

  Widget _buildUrlTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 16.0),
        _buildInput(),
        const SizedBox(height: 18.0),
        _buildUploadButton(
          context,
          ImageSourceType.network,
        ),
      ],
    );
  }

  Widget _buildFileTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16.0),
        _buildFileUploadContainer(context),
        const SizedBox(height: 18.0),
        Align(
          alignment: Alignment.centerRight,
          child: _buildUploadButton(
            context,
            ImageSourceType.file,
          ),
        )
      ],
    );
  }

  Widget _buildFileUploadContainer(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          final result = await _filePicker.pickFiles(
            dialogTitle: 'Select an image',
            allowMultiple: false,
            type: fp.FileType.image,
            allowedExtensions: allowedExtensions,
          );
          if (result != null && result.files.isNotEmpty) {
            setState(() {
              _localImagePath = result.files.first.path;
            });
          }
        },
        child: Container(
          height: 80,
          margin: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: _localImagePath != null
              ? Align(
                  alignment: Alignment.center,
                  child: Image.file(
                    File(
                      _localImagePath!,
                    ),
                    fit: BoxFit.cover,
                  ),
                )
              : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image, size: 48.0, color: Colors.grey),
                      SizedBox(height: 8.0),
                      Text(
                        'Pick a file',
                        style: TextStyle(fontSize: 14.0, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

extension on EditorState {
  Future<void> insertImageNode(
    String src,
    ImageSourceType imageSourceType,
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
            url: imageSourceType == ImageSourceType.network ? src : null,
            content: imageSourceType == ImageSourceType.file ? src : null,
            imageSourceType: imageSourceType,
          ),
        )
        ..deleteNode(node);
    } else {
      transaction.insertNode(
        node.path.next,
        imageNode(url: src, imageSourceType: imageSourceType),
      );
    }

    return apply(transaction);
  }
}
