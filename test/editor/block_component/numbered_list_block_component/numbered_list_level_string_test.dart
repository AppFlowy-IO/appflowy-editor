import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NumberedList', () {
    test('LevelString', () async {
      void printNodeLevel(List<Node> nodes) {
        for (var element in nodes) {
          debugPrint(element.getLevelString());
          if (element.children.isNotEmpty) {
            printNodeLevel(element.children);
          }
        }
      }

      Document document = Document.fromJson(
        json.decode(
            '{"document":{"type":"page","children":[{"type":"numbered_list","data":{"delta":[{"insert":"قابل للتخصيص","attributes":{"bg_color":"0x4d2196f3"}}]},"children":[{"type":"numbered_list","data":{"delta":[{"insert":"قابل للتخصيص","attributes":{"bg_color":"0x4d2196f3"}}]},"children":[{"type":"numbered_list","data":{"delta":[{"insert":"قابل للتخصيص","attributes":{"bg_color":"0x4d2196f3"}}]}},{"type":"numbered_list","data":{"delta":[{"insert":"مُغطى بالاختبارات","attributes":{"bg_color":"0x4d2196f3"}}]}},{"type":"numbered_list","data":{"delta":[{"insert":"المزيد قادم قريبًا!","attributes":{"code":true}}]}}]},{"type":"numbered_list","data":{"delta":[{"insert":"مُغطى بالاختبارات","attributes":{"bg_color":"0x4d2196f3"}}]}},{"type":"numbered_list","data":{"delta":[{"insert":"المزيد قادم قريبًا!","attributes":{"code":true}}]}}]},{"type":"numbered_list","data":{"delta":[{"insert":"مُغطى بالاختبارات","attributes":{"bg_color":"0x4d2196f3"}}]}},{"type":"numbered_list","data":{"delta":[{"insert":"المزيد قادم قريبًا!","attributes":{"code":true}}]}}]}}'),
      );
      printNodeLevel(document.root.children);
    });
  });
}
