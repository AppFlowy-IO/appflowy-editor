import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/renderer/block_component_context.dart';
import 'package:flutter/material.dart';

typedef NodeValidator = bool Function(Node node);

/// BlockComponentBuilder is used to build a BlockComponentWidget.
abstract class BlockComponentBuilder {
  /// validate the node.
  ///
  /// return true if the node is valid.
  /// return false if the node is invalid,
  ///   and the node will be displayed as a PlaceHolder widget.
  bool validate(Node node) => true;

  BlockComponentWidget build(BlockComponentContext blockComponentContext);
}

abstract class BlockComponentRendererService {
  /// Register render plugin with specified [type].
  ///
  /// [type] should be [Node].type and should not be empty.
  ///
  /// e.g. 'paragraph', 'image', or 'bulleted_list'
  ///
  void register(String type, BlockComponentBuilder builder);

  /// Register render plugins with specified [type]s.
  void registerAll(Map<String, BlockComponentBuilder> builders) =>
      builders.forEach(register);

  /// UnRegister plugin with specified [type].
  void unRegister(String type);

  /// Returns a [BlockComponentBuilder], if one has been registered for [type]
  /// or null otherwise.
  ///
  BlockComponentBuilder? blockComponentBuilder(String type);

  Widget build(
    BlockComponentContext blockComponentContext,
  );
}

class BlockComponentRenderer extends BlockComponentRendererService {
  final Map<String, BlockComponentBuilder> _builders = {};

  @override
  Widget build(BlockComponentContext blockComponentContext) {
    final node = blockComponentContext.node;
    final builder = blockComponentBuilder(node.type);
    if (builder == null) {
      assert(false, 'no builder for node type(${node.type})');
      return _buildPlaceHolderWidget(blockComponentContext);
    }
    if (!builder.validate(node)) {
      assert(false,
          'node(${node.type}) is invalid, attributes: ${node.attributes}, children: ${node.children}');
      return _buildPlaceHolderWidget(blockComponentContext);
    }
    final child = builder.build(blockComponentContext);
  }

  @override
  BlockComponentBuilder? blockComponentBuilder(String type) {
    return _builders[type];
  }

  @override
  void register(String type, BlockComponentBuilder builder) {
    Log.editor.info('register block component builder for type($type)');
    if (type.isEmpty) {
      throw ArgumentError('type should not be empty');
    }
    if (_builders.containsKey(type)) {
      throw ArgumentError('type($type) has been registered');
    }
    _builders[type] = builder;
  }

  @override
  void unRegister(String type) {
    _builders.remove(type);
  }

  Widget _buildPlaceHolderWidget(BlockComponentContext blockComponentContext) {
    return SizedBox(
      key: blockComponentContext.node.key,
      height: 30,
      child: const Center(child: Text('placeholder')),
    );
  }
}
