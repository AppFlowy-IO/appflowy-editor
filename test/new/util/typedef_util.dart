import 'package:appflowy_editor/appflowy_editor.dart';

/// customize the delta
typedef DeltaBuilder = Delta Function(int index);

/// customize the initial text
typedef TextBuilder = Delta Function(int index);

/// customize the node
typedef NodeDecorator = void Function(int index, Node node);
