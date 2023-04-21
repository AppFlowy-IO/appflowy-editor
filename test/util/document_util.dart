import 'package:appflowy_editor/appflowy_editor.dart';

typedef DeltaBuilder = Delta Function(int index);

extension DocumentExtension on Document {
  Document combineParagraphs(
    int count, {
    DeltaBuilder? builder,
  }) {
    final builder0 = builder ??
        (index) => Delta()
          ..insert(
            '🔥 $index. Welcome to AppFlowy Editor!',
          );
    return this
      ..insert(
        [root.children.length],
        List.generate(
          count,
          (index) => Node(type: 'paragraph')
            ..updateAttributes({
              'delta': builder0(index).toJson(),
            }),
        ),
      );
  }
}
