import 'package:appflowy_editor/src/infra/flowy_svg.dart';
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
  const ColorOptionList({
    this.selectedColorHex,
    required this.header,
    required this.colorOptions,
    required this.onSubmittedAction,
  });

  final String header;
  final List<ColorOption> colorOptions;
  final void Function(String color) onSubmittedAction;
  final String? selectedColorHex;
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
              children: _buildColorOptionLists(widget.colorOptionLists)),
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
      children: colorOptionList.colorOptions
          .map((e) => _buildColorItem(colorOptionList.onSubmittedAction, e,
              e.colorHex == colorOptionList.selectedColorHex))
          .toList(),
    );
  }

  Widget _buildColorItem(
      void Function(String color) onTap, ColorOption option, bool isChecked) {
    return SizedBox(
      height: 36,
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        hoverColor: widget.pickerItemHoverColor,
        onTap: () {
          onTap(option.colorHex);
        },
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
            if (isChecked) const FlowySvg(name: 'checkmark'),
            const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }
}
