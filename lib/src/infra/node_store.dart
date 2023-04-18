import 'package:appflowy_editor/src/core/document/node.dart';

class NodeStore {

  NodeStore._();
  static final instance = NodeStore._();

  List<Node>? nodes;
  static void saveNodes(List<Node> nodes) {
    instance.nodes = nodes;
  }

  static void clearNodes() {
    instance.nodes = null;
  }

  static getNodes() {
    return instance.nodes;
  }
}