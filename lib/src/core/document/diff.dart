import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:collection/collection.dart';

const _equality = DeepCollectionEquality();

List<Operation> diffDocuments(Document oldDocument, Document newDocument) {
  return diffNodes(oldDocument.root, newDocument.root);
}

List<Operation> diffNodes(Node oldNode, Node newNode) {
  List<Operation> operations = [];

  if (!_equality.equals(oldNode.attributes, newNode.attributes)) {
    operations.add(
      UpdateOperation(oldNode.path, newNode.attributes, oldNode.attributes),
    );
  }

  final oldChildrenById = {
    for (final child in oldNode.children) child.id: child,
  };
  final newChildrenById = {
    for (final child in newNode.children) child.id: child,
  };

  // Identify insertions and updates
  for (final newChild in newNode.children) {
    final oldChild = oldChildrenById[newChild.id];
    if (oldChild == null) {
      // Insert operation
      operations.add(InsertOperation(newChild.path, [newChild]));
    } else {
      // Recursive diff for updates
      operations.addAll(diffNodes(oldChild, newChild));
    }
  }

  // Identify deletions
  oldChildrenById.keys
      .where((id) => !newChildrenById.containsKey(id))
      .forEach((id) {
    final oldChild = oldChildrenById[id]!;
    operations.add(DeleteOperation(oldChild.path, [oldChild]));
  });

  // Combine the operation in operations

  // 1. Insert operations can be combined if they are continuous
  final combinedOperations = <Operation>[];
  if (operations.isNotEmpty &&
      operations.every((element) => element is InsertOperation)) {
    operations.sorted((a, b) => a.path <= b.path ? -1 : 1);
    for (var i = 0; i < operations.length; i++) {
      final op = operations[i];
      if (combinedOperations.isEmpty) {
        combinedOperations.add(op);
      } else {
        if (op.path.equals(operations[i - 1].path.next)) {
          final lastOp = combinedOperations.removeLast();
          combinedOperations.add(
            InsertOperation(
              lastOp.path,
              [
                ...(lastOp as InsertOperation).nodes,
                ...(op as InsertOperation).nodes,
              ],
            ),
          );
        } else {
          combinedOperations.add(op);
        }
      }
    }
    return combinedOperations;
  }

  // 2. Delete operations can be combined if they are continuous
  if (operations.isNotEmpty &&
      operations.every((element) => element is DeleteOperation)) {
    operations.sorted((a, b) => a.path <= b.path ? -1 : 1);
    for (var i = 0; i < operations.length; i++) {
      final op = operations[i];
      if (combinedOperations.isEmpty) {
        combinedOperations.add(op);
      } else {
        if (op.path.equals(operations[i - 1].path.next)) {
          final lastOp = combinedOperations.removeLast();
          combinedOperations.add(
            DeleteOperation(
              lastOp.path,
              [
                ...(lastOp as DeleteOperation).nodes,
                ...(op as DeleteOperation).nodes,
              ],
            ),
          );
        } else {
          combinedOperations.add(op);
        }
      }
    }
    return combinedOperations;
  }

  return operations;
}
