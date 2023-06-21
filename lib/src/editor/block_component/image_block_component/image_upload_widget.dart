import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as fp;
import '../../util/file_picker/file_picker_impl.dart';

void showImageMenu(
  OverlayState container,
  EditorState editorState,
  SelectionMenuService menuService,
) {
  menuService.dismiss();

  final (left, top, bottom) = menuService.getPosition();

  late final OverlayEntry imageMenuEntry;

  void insertImage(String text,
      {ImageSourceType imageSourceType = ImageSourceType.network}) {
    editorState.insertImageNode(text, imageSourceType);
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16.0),
          _buildInput(),
          const SizedBox(height: 18.0),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: _buildUploadButton(context)),
              // const SizedBox(width: 18.0),
              const Text('or'),
              Flexible(child: _buildSelectFileButton(context)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectFileButton(BuildContext context) {
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
          final result = await _filePicker.pickFiles(
            dialogTitle: 'Select an image',
            allowMultiple: false,
            type: fp.FileType.image,
            allowedExtensions: allowedExtensions,
          );
          if (result != null) {
            final file = result.files.first;
            widget.onUpload(file.path!, imageSourceType: ImageSourceType.file);
          }
        },
        child: const Text('Pick a File',style: TextStyle(color: Colors.white, fontSize: 14.0),),
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

  Widget _buildUploadButton(BuildContext context) {
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
        onPressed: () => widget.onUpload(_textEditingController.text,
            imageSourceType: ImageSourceType.network),
        child: const Text(
          'Upload',
          style: TextStyle(color: Colors.white, fontSize: 14.0),
        ),
      ),
    );
  }
}

extension on EditorState {
  Future<void> insertImageNode(
      String src, ImageSourceType imageSourceType) async {
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
    if (node.type == 'paragraph' && (node.delta?.isEmpty ?? false)) {
      transaction
        ..insertNode(
            node.path, imageNode(url: src, imageSourceType: imageSourceType))
        ..deleteNode(node);
    } else {
      transaction
        ..insertNode(node.path.next,
            imageNode(url: src, imageSourceType: imageSourceType));
    }

    return apply(transaction);
  }
}
