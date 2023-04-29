import 'package:appflowy_editor/appflowy_editor.dart';

extension AttributesDelta on Delta {
  bool everyAttributes(bool Function(Attributes element) test) =>
      whereType<TextInsert>().every((element) {
        final attributes = element.attributes;
        return attributes != null && test(attributes);
      });
}
