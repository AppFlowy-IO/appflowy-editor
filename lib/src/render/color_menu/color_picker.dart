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

enum _ColorType {
  font,
  background,
}

class ColorPicker extends StatefulWidget {
  const ColorPicker({
    super.key,
    this.selectedFontColorHex,
    this.selectedBackgroundColorHex,
    required this.pickerBackgroundColor,
    required this.fontColorOptions,
    required this.backgroundColorOptions,
    required this.pickerItemHoverColor,
    required this.pickerItemTextColor,
    required this.onSubmittedbackgroundColorHex,
    required this.onSubmittedFontColorHex,
  });

  final String? selectedFontColorHex;
  final String? selectedBackgroundColorHex;
  final Color pickerBackgroundColor;
  final Color pickerItemHoverColor;
  final Color pickerItemTextColor;
  final void Function(String color) onSubmittedbackgroundColorHex;
  final void Function(String color) onSubmittedFontColorHex;

  final List<ColorOption> fontColorOptions;
  final List<ColorOption> backgroundColorOptions;

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  final TextEditingController _fontColorHexController = TextEditingController();
  final TextEditingController _fontColorOpacityController =
      TextEditingController();
  final TextEditingController _backgroundColorHexController =
      TextEditingController();
  final TextEditingController _backgroundColorOpacityController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _fontColorHexController.text =
        _extractColorHex(widget.selectedFontColorHex) ?? 'FFFFFF';
    _fontColorOpacityController.text =
        _convertHexToOpacity(widget.selectedFontColorHex) ?? '100';
    _backgroundColorHexController.text =
        _extractColorHex(widget.selectedBackgroundColorHex) ?? 'FFFFFF';
    _backgroundColorOpacityController.text =
        _convertHexToOpacity(widget.selectedBackgroundColorHex) ?? '0';
  }

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
            children: [
              // font color
              _buildHeader('font color'),
              // padding
              const SizedBox(height: 6),
              _buildCustomColorItem(
                _ColorType.font,
                _fontColorHexController,
                _fontColorOpacityController,
              ),
              _buildColorItems(
                _ColorType.font,
                widget.fontColorOptions,
                widget.selectedFontColorHex,
              ),

              // background color
              const SizedBox(height: 6),
              _buildHeader('background color'),
              const SizedBox(height: 6),
              _buildCustomColorItem(
                _ColorType.background,
                _backgroundColorHexController,
                _backgroundColorOpacityController,
              ),
              _buildColorItems(
                _ColorType.background,
                widget.backgroundColorOptions,
                widget.selectedBackgroundColorHex,
              ),
            ],
          ),
        ),
      ),
    );
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

  Widget _buildColorItems(
      _ColorType type, List<ColorOption> options, String? selectedColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: options
          .map((e) => _buildColorItem(type, e, e.colorHex == selectedColor))
          .toList(),
    );
  }

  Widget _buildColorItem(_ColorType type, ColorOption option, bool isChecked) {
    return SizedBox(
      height: 36,
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        hoverColor: widget.pickerItemHoverColor,
        onTap: () {
          if (type == _ColorType.font) {
            widget.onSubmittedFontColorHex(option.colorHex);
          } else if (type == _ColorType.background) {
            widget.onSubmittedbackgroundColorHex(option.colorHex);
          }
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

  Widget _buildCustomColorItem(
    _ColorType type,
    TextEditingController colorController,
    TextEditingController opacityController,
  ) {
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
                  color: Color(int.tryParse(_combineColorHexAndOpacity(
                          colorController.text, opacityController.text)) ??
                      0xFFFFFFFF),
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
        _customColorDetailsTextField('Hex Color', colorController, type),
        const SizedBox(height: 6),
        _customColorDetailsTextField('Opacity', opacityController, type),
      ],
    );
  }

  Widget _customColorDetailsTextField(
      String labeText, TextEditingController controller, _ColorType? type) {
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
      onSubmitted: (value) {
        if (type == _ColorType.font) {
          final String color = _combineColorHexAndOpacity(
            _fontColorHexController.text,
            _fontColorOpacityController.text,
          );
          widget.onSubmittedFontColorHex(color);
        } else if (type == _ColorType.background) {
          final String color = _combineColorHexAndOpacity(
            _backgroundColorHexController.text,
            _backgroundColorOpacityController.text,
          );
          widget.onSubmittedbackgroundColorHex(color);
        }
      },
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
    RegExp regex = RegExp(r'[a-zA-Z]');
    if (regex.hasMatch(opacity) ||
        int.parse(opacity) > 100 ||
        int.parse(opacity) < 0) {
      return '100';
    }
    return opacity;
  }

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
