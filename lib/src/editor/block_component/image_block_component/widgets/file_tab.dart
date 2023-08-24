import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as fp;
import './widget_helpers.dart';
import '../../../util/file_picker/file_picker_impl.dart';

class BuildFileTab extends StatefulWidget {
  const BuildFileTab({
    required this.filePicker,
    required this.onUpload,
    required this.textEditingController,
    super.key,
  });
  final void Function(String text) onUpload;
  final FilePicker filePicker;
  final TextEditingController textEditingController;

  @override
  State<BuildFileTab> createState() => _BuildFileTab();
}

class _BuildFileTab extends State<BuildFileTab> {
  String? _localImagePath;
  @override
  Widget build(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16.0),
        BuildFileUploadContainer(
          context,
          filePicker: widget.filePicker,
          onFilePicked: (imagePath) {
            setState(() => _localImagePath = imagePath);
          },
        ),
        const SizedBox(height: 18.0),
        Align(
          alignment: Alignment.centerRight,
          child: BuildUploadButton(
            context,
            localImagePath: _localImagePath,
            onUpload: widget.onUpload,
            textEditingController: widget.textEditingController,
            onValidateUrl: (result) {/*Do Nothing */},
          ),
        ),
      ],
    );
  }
}

class BuildFileUploadContainer extends StatefulWidget {
  const BuildFileUploadContainer(
    BuildContext context, {
    required this.filePicker,
    required this.onFilePicked,
    super.key,
  });
  final FilePicker filePicker;
  final Function(String? filePath) onFilePicked;

  @override
  State<BuildFileUploadContainer> createState() => _BuildFileUploadContainer();
}

class _BuildFileUploadContainer extends State<BuildFileUploadContainer> {
  final allowedExtensions = ['jpg', 'png', 'jpeg'];
  String? _localImagePath;
  @override
  Widget build(context) {
    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () async {
            final result = await widget.filePicker.pickFiles(
              dialogTitle: '',
              allowMultiple: false,
              type: fp.FileType.image,
              allowedExtensions: allowedExtensions,
            );
            if (result != null && result.files.isNotEmpty) {
              setState(() {
                _localImagePath = result.files.first.path;
                widget.onFilePicked(_localImagePath);
              });
            }
          },
          child: Container(
            height: 80,
            margin: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xff00BCF0)),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: _localImagePath != null
                ? PreviewImageBox(
                    localImagePath: _localImagePath!,
                  )
                : const BuildImagePickerBox(),
          ),
        ),
      ),
    );
  }
}
