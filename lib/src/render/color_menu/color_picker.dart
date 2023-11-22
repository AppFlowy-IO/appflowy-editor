import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class ColorOption {
  const ColorOption({
    required this.colorHex,
    required this.name,
  });

  final String colorHex;
  final String name;
}

class ColorOptionList {
  ColorOptionList({
    this.selectedColorHex,
    required this.header,
    required this.colorOptions,
    required this.onSubmittedAction,
  }) {
    hexController.text = _extractColorHex(selectedColorHex) ?? 'FFFFFF';
    opacityController.text = _convertHexToOpacity(selectedColorHex) ?? '100';
  }

  final String header;
  final List<ColorOption> colorOptions;
  final void Function(String color) onSubmittedAction;
  final String? selectedColorHex;
  final TextEditingController hexController = TextEditingController();
  final TextEditingController opacityController = TextEditingController();

  String? _convertHexToOpacity(String? colorHex) {
    if (colorHex == null) return null;
    final opacityHex = colorHex.substring(2, 4);
    final opacity = int.parse(opacityHex, radix: 16) / 2.55;
    return opacity.toStringAsFixed(0);
  }

  String? _extractColorHex(String? colorHex) {
    if (colorHex == null) return null;
    return colorHex.substring(4);
  }
}

class ColorPicker extends StatefulWidget {
  const ColorPicker({
    super.key,
    required this.pickerBackgroundColor,
    required this.pickerItemHoverColor,
    required this.pickerItemTextColor,
    required this.colorOptionLists,
  });

  final Color pickerBackgroundColor;
  final Color pickerItemHoverColor;
  final Color pickerItemTextColor;

  final List<ColorOptionList> colorOptionLists;

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.pickerBackgroundColor,
        boxShadow: [
          BoxShadow(
            blurRadius: 5,
            spreadRadius: 1,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
        borderRadius: BorderRadius.circular(6.0),
      ),
      height: 250,
      width: 220,
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: _buildColorOptionLists(widget.colorOptionLists),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildColorOptionLists(List<ColorOptionList> colorOptionLists) {
    List<Widget> colorOptionMenu = [];
    for (var i = 0; i < colorOptionLists.length; i++) {
      if (i != 0) {
        colorOptionMenu.add(const SizedBox(height: 6));
      }

      colorOptionMenu.addAll([
        _buildHeader(colorOptionLists[i].header),
        const SizedBox(height: 6),
        _buildColorItems(colorOptionLists[i]),
      ]);
    }

    return colorOptionMenu;
  }

  Widget _buildHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.grey,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildColorItems(ColorOptionList colorOptionList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildCustomColorItem(colorOptionList),
        ...colorOptionList.colorOptions.map(
          (colorOption) => _buildColorItem(
            colorOptionList.onSubmittedAction,
            colorOption,
            colorOption.colorHex == colorOptionList.selectedColorHex,
          ),
        ),
      ],
    );
  }

  Widget _buildColorItem(
    void Function(String) onTap,
    ColorOption option,
    bool isChecked,
  ) {
    return SizedBox(
      height: 36,
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        hoverColor: widget.pickerItemHoverColor,
        onTap: () => onTap(option.colorHex),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // padding
            const SizedBox(width: 6),
            // icon
            SizedBox.square(
              dimension: 12,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(int.tryParse(option.colorHex) ?? 0xFFFFFFFF),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // padding
            const SizedBox(width: 10),
            // text
            Expanded(
              child: Text(
                option.name,
                style:
                    TextStyle(fontSize: 12, color: widget.pickerItemTextColor),
              ),
            ),
            // checkbox
            if (isChecked) const EditorSvg(name: 'checkmark'),
            const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomColorItem(ColorOptionList colorOptionList) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.only(left: 0),
      title: SizedBox(
        height: 36,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 6),
            SizedBox.square(
              dimension: 12,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(
                    int.tryParse(
                          _combineColorHexAndOpacity(
                            colorOptionList.hexController.text,
                            colorOptionList.opacityController.text,
                          ),
                        ) ??
                        0xFFFFFFFF,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Custom Color',
                style:
                    TextStyle(fontSize: 12, color: widget.pickerItemTextColor),
              ),
            ),
          ],
        ),
      ),
      children: [
        const SizedBox(height: 6),
        _customColorDetailsTextField(
          'Hex Color',
          colorOptionList.hexController,
          colorOptionList,
        ),
        const SizedBox(height: 6),
        _customColorDetailsTextField(
          'Opacity',
          colorOptionList.opacityController,
          colorOptionList,
        ),
      ],
    );
  }

  Widget _customColorDetailsTextField(
    String labeText,
    TextEditingController controller,
    ColorOptionList colorOptionList,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labeText,
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ),
      style: Theme.of(context).textTheme.bodyMedium,
      onSubmitted: (_) => colorOptionList.onSubmittedAction(
        _combineColorHexAndOpacity(
          colorOptionList.hexController.text,
          colorOptionList.opacityController.text,
        ),
      ),
    );
  }

  String _combineColorHexAndOpacity(String colorHex, String opacity) {
    colorHex = _fixColorHex(colorHex);
    opacity = _fixOpacity(opacity);
    final opacityHex = (int.parse(opacity) * 2.55).round().toRadixString(16);
    return '0x$opacityHex$colorHex';
  }

  String _fixColorHex(String colorHex) {
    if (colorHex.length > 6) {
      colorHex = colorHex.substring(0, 6);
    }
    if (int.tryParse(colorHex, radix: 16) == null) {
      colorHex = 'FFFFFF';
    }
    return colorHex;
  }

  String _fixOpacity(String opacity) {
    RegExp regex = RegExp('[a-zA-Z]');
    if (regex.hasMatch(opacity) ||
        int.parse(opacity) > 100 ||
        int.parse(opacity) < 0) {
      return '100';
    }
    return opacity;
  }
}

extension ConvertToHex on Color {
  String toHex() {
    return '0x${value.toRadixString(16)}';
  }
}
