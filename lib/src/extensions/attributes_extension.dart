import 'package:appflowy_editor/appflowy_editor.dart';

extension NodeAttributesExtensions on Attributes {
  String? get heading {
    if (containsKey(BuiltInAttributeKey.subtype) &&
        containsKey(BuiltInAttributeKey.heading) &&
        this[BuiltInAttributeKey.subtype] == BuiltInAttributeKey.heading &&
        this[BuiltInAttributeKey.heading] is String) {
      return this[BuiltInAttributeKey.heading];
    }
    return null;
  }

  bool get quote {
    return containsKey(BuiltInAttributeKey.quote);
  }

  num? get number {
    if (containsKey(BuiltInAttributeKey.number) &&
        this[BuiltInAttributeKey.number] is num) {
      return this[BuiltInAttributeKey.number];
    }
    return null;
  }

  bool get check {
    if (containsKey(BuiltInAttributeKey.checkbox) &&
        this[BuiltInAttributeKey.checkbox] is bool) {
      return this[BuiltInAttributeKey.checkbox];
    }
    return false;
  }
}
