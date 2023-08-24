import 'package:flutter/material.dart';
import 'dart:io';
import 'package:appflowy_editor/appflowy_editor.dart';
import './url_tab.dart';

class PreviewImageBox extends StatelessWidget {
  const PreviewImageBox({required this.localImagePath, super.key});
  final String localImagePath;
  @override
  Widget build(BuildContext context) {
    return (Align(
      alignment: Alignment.center,
      child: Image.file(
        File(
          localImagePath,
        ),
        fit: BoxFit.cover,
      ),
    ));
  }
}

class BuildImagePickerBox extends StatelessWidget {
  const BuildImagePickerBox({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          EditorSvg(
            name: 'upload_image',
            width: 32,
            height: 32,
          ),
          SizedBox(height: 8.0),
          Text(
            'Choose an image',
            style: TextStyle(fontSize: 14.0, color: Color(0xff00BCF0)),
          ),
        ],
      ),
    );
  }
}

class BuildInvalidText extends StatelessWidget {
  const BuildInvalidText({super.key});
  @override
  Widget build(BuildContext context) {
    return const Text(
      'Incorrect Link',
      style: TextStyle(color: Colors.red, fontSize: 12),
    );
  }
}

class BuildUploadButton extends StatefulWidget {
  const BuildUploadButton(
    BuildContext context, {
    required this.localImagePath,
    required this.onUpload,
    required this.textEditingController,
    required this.onValidateUrl,
    super.key,
  });

  final String? localImagePath;
  final void Function(String text) onUpload;
  final void Function(bool result) onValidateUrl;
  final TextEditingController textEditingController;

  @override
  State<BuildUploadButton> createState() => _BuildUploadButton();
}

class _BuildUploadButton extends State<BuildUploadButton> {
  @override
  Widget build(context) {
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
          if (widget.localImagePath != null) {
            widget.onUpload(
              widget.localImagePath!,
            );
          } else if (validateUrl(widget.textEditingController.text)) {
            widget.onUpload(
              widget.textEditingController.text,
            );
          } else {
            setState(
              () => widget.onValidateUrl(false),
            );
          }
        },
        child: Text(
          'Upload',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 14.0,
          ),
        ),
      ),
    );
  }
}
