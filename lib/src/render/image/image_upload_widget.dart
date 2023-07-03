import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

// void showImageMenu(
//   OverlayState container,
//   EditorState editorState,
//   SelectionMenuService menuService,
// ) {
//   menuService.dismiss();

//   final imageMenu =
// }

OverlayEntry? _imageUploadMenu;
EditorState? _editorState;
void showImageUploadMenu(
  EditorState editorState,
  SelectionMenuService menuService,
  BuildContext context,
) {
  menuService.dismiss();

  _imageUploadMenu?.remove();
  _imageUploadMenu = OverlayEntry(
    builder: (context) => Positioned(
      top: menuService.topLeft.dy,
      left: menuService.topLeft.dx,
      child: Material(
        child: ImageUploadMenu(
          editorState: editorState,
          onSubmitted: (src) {},
          onUpload: (src) {},
        ),
      ),
    ),
  );

  Overlay.of(context).insert(_imageUploadMenu!);

  editorState.service.selectionService.currentSelection
      .addListener(_dismissImageUploadMenu);
}

void _dismissImageUploadMenu() {
  _imageUploadMenu?.remove();
  _imageUploadMenu = null;

  _editorState?.service.selectionService.currentSelection
      .removeListener(_dismissImageUploadMenu);
  _editorState = null;
}

class ImageUploadMenu extends StatefulWidget {
  const ImageUploadMenu({
    Key? key,
    required this.onSubmitted,
    required this.onUpload,
    this.editorState,
  }) : super(key: key);

  final void Function(String text) onSubmitted;
  final void Function(String text) onUpload;
  final EditorState? editorState;

  @override
  State<ImageUploadMenu> createState() => _ImageUploadMenuState();
}

class _ImageUploadMenuState extends State<ImageUploadMenu> {
  final _textEditingController = TextEditingController();
  final _focusNode = FocusNode();

  EditorStyle? get style => widget.editorState?.editorStyle;

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
      width: 300,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: style?.selectionMenuBackgroundColor ?? Colors.white,
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
          _buildInput(),
          const SizedBox(height: 18.0),
          _buildUploadButton(context),
        ],
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
        onPressed: () => widget.onUpload(_textEditingController.text),
        child: Text(
          'Upload',
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 14.0,
          ),
        ),
      ),
    );
  }
}
