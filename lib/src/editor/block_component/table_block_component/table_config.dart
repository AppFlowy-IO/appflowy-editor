import 'package:appflowy_editor/appflowy_editor.dart';

class TableConfig {
  TableConfig({
    double? colDefaultWidth,
    double? rowDefaultHeight,
    double? colMinimumWidth,
    double? borderWidth,
  }) {
    this.colDefaultWidth = colDefaultWidth ?? TableDefaults.colWidth;
    this.rowDefaultHeight = rowDefaultHeight ?? TableDefaults.rowHeight;
    this.colMinimumWidth = colMinimumWidth ?? TableDefaults.colMinimumWidth;
    this.borderWidth = borderWidth ?? TableDefaults.borderWidth;
  }

  static TableConfig fromJson(Map<String, dynamic> json) {
    double func(String key, double defaultVal) => json.containsKey(key)
        ? double.tryParse(json[key].toString())!
        : defaultVal;

    return TableConfig(
      colDefaultWidth:
          func(TableBlockKeys.colDefaultWidth, TableDefaults.colWidth),
      rowDefaultHeight:
          func(TableBlockKeys.rowDefaultHeight, TableDefaults.rowHeight),
      colMinimumWidth:
          func(TableBlockKeys.colMinimumWidth, TableDefaults.colMinimumWidth),
      borderWidth: func(TableBlockKeys.borderWidth, TableDefaults.borderWidth),
    );
  }

  Map<String, Object> toJson() {
    return {
      TableBlockKeys.colDefaultWidth: colDefaultWidth,
      TableBlockKeys.rowDefaultHeight: rowDefaultHeight,
      TableBlockKeys.colMinimumWidth: colMinimumWidth,
    };
  }

  late final double colDefaultWidth,
      rowDefaultHeight,
      colMinimumWidth,
      borderWidth;
}
