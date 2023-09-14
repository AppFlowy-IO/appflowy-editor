import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:string_validator/string_validator.dart';

import '../../util/file_picker/file_picker_impl.dart';
import 'base64_image.dart';

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
      width: MediaQuery.of(context).size.width * 0.3,
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
  static const allowedExtensions = ['jpg', 'png', 'jpeg'];

  final _textEditingController = TextEditingController();
  final _focusNode = FocusNode();
  final _filePicker = FilePicker();

  // this value is either a path or base64 content
  // if the app is running on web, it will be base64 content
  // otherwise, it will be a path
  String? _imagePathOrContent;

  bool isUrlValid = true;

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
      height: 240,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
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
                width: 260,
                height: 36,
                child: TabBar(
                  tabs: [
                    Tab(text: AppFlowyEditorLocalizations.current.uploadImage),
                    Tab(text: AppFlowyEditorLocalizations.current.urlImage),
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

  Widget _buildInput() {
    return TextField(
      focusNode: _focusNode,
      style: const TextStyle(fontSize: 14.0),
      textAlign: TextAlign.left,
      controller: _textEditingController,
      onSubmitted: (text) {
        if (_validateUrl(text)) {
          widget.onSubmitted(text);
        } else {
          setState(() {
            isUrlValid = false;
          });
        }
      },
      decoration: InputDecoration(
        hintText: 'URL',
        hintStyle: const TextStyle(fontSize: 14.0),
        contentPadding: const EdgeInsets.all(16.0),
        isDense: true,
        suffixIcon: IconButton(
          padding: const EdgeInsets.all(4.0),
          icon: const EditorSvg(
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

  Widget _buildInvalidLinkText() {
    return Text(
      AppFlowyEditorLocalizations.current.incorrectLink,
      style: const TextStyle(color: Colors.red, fontSize: 12),
    );
  }

  Widget _buildUploadButton(
    BuildContext context,
  ) {
    return SizedBox(
      width: 170,
      height: 36,
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
          if (_imagePathOrContent != null) {
            widget.onUpload(
              _imagePathOrContent!,
            );
          } else if (_validateUrl(_textEditingController.text)) {
            widget.onUpload(
              _textEditingController.text,
            );
          } else {
            setState(() {
              isUrlValid = false;
            });
          }
        },
        child: Text(
          AppFlowyEditorLocalizations.current.upload,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 14.0,
          ),
        ),
      ),
    );
  }

  Widget _buildUrlTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16.0),
        _buildInput(),
        const SizedBox(height: 18.0),
        if (!isUrlValid) _buildInvalidLinkText(),
        const SizedBox(height: 18.0),
        Align(
          alignment: Alignment.centerRight,
          child: _buildUploadButton(
            context,
          ),
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
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadContainer(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          final result = await _filePicker.pickFiles(
            dialogTitle: '',
            allowMultiple: false,
            type: kIsWeb ? fp.FileType.custom : fp.FileType.image,
            allowedExtensions: allowedExtensions,
            withData: kIsWeb,
          );
          if (result != null && result.files.isNotEmpty) {
            setState(() {
              final bytes = result.files.first.bytes;
              if (kIsWeb && bytes != null) {
                _imagePathOrContent = base64String(bytes);
              } else {
                _imagePathOrContent = result.files.first.path;
              }
            });
          }
        },
        child: Container(
          height: 60,
          margin: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xff00BCF0)),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: _imagePathOrContent != null
              ? Align(
                  alignment: Alignment.center,
                  child: kIsWeb
                      ? Image.memory(
                          dataFromBase64String(_imagePathOrContent!),
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(_imagePathOrContent!),
                          fit: BoxFit.cover,
                        ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const EditorSvg(
                        name: 'upload_image',
                        width: 32,
                        height: 32,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        AppFlowyEditorLocalizations.current.chooseImage,
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: Color(0xff00BCF0),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  bool _validateUrl(String url) {
    return url.isNotEmpty && isURL(url);
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
