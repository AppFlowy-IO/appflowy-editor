import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

typedef BlockActionBuilder = Widget Function(
  BlockComponentContext blockComponentContext,
  BlockComponentActionState state,
);

abstract class BlockComponentActionState {
  set alwaysShowActions(bool alwaysShowActions);
}

/// BlockComponentBuilder is used to build a BlockComponentWidget.
abstract class BlockComponentBuilder with BlockComponentSelectable {
  BlockComponentBuilder({
    this.configuration = const BlockComponentConfiguration(),
  });

  /// validate the node.
  ///
  /// return true if the node is valid.
  /// return false if the node is invalid,
  ///   and the node will be displayed as a PlaceHolder widget.
  bool validate(Node node) => true;

  BlockComponentWidget build(BlockComponentContext blockComponentContext);

  bool Function(Node) showActions = (_) => false;

  BlockActionBuilder actionBuilder = (_, __) => const SizedBox.shrink();

  BlockComponentConfiguration configuration =
      const BlockComponentConfiguration();
}

mixin BlockComponentSelectable<T extends BlockComponentBuilder> {
  /// the start position of the block component.
  ///
  /// For the text block component, the start position is always 0.
  Position start(Node node) => Position(path: node.path, offset: 0);

  /// the end position of the block component.
  ///
  /// For the text block component, the end position is always the length of the text.
  Position end(Node node) => Position(
        path: node.path,
        offset: node.delta?.length ?? 0,
      );
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

  BlockComponentSelectable? blockComponentSelectable(String type) {
    final builder = blockComponentBuilder(type);
    if (builder is BlockComponentSelectable) {
      return builder as BlockComponentSelectable;
    }
    return null;
  }

  /// Build a widget for the specified [node].
  ///
  /// the widget is embedded in a [BlockComponentContainer] widget.
  ///
  /// the header and the footer only works for the root node.
  Widget build(
    BuildContext buildContext,
    Node node, {
    Widget? header,
    Widget? footer,
  });

  List<Widget> buildList(
    BuildContext buildContext,
    Iterable<Node> nodes,
  ) {
    return nodes
        .map((node) => build(buildContext, node))
        .toList(growable: false);
  }
}

class BlockComponentRenderer extends BlockComponentRendererService {
  BlockComponentRenderer({
    required Map<String, BlockComponentBuilder> builders,
  }) {
    registerAll(builders);
  }

  final Map<String, BlockComponentBuilder> _builders = {};

  @override
  Widget build(
    BuildContext buildContext,
    Node node, {
    Widget? header,
    Widget? footer,
  }) {
    final blockComponentContext = BlockComponentContext(
      buildContext,
      node,
      header: header,
      footer: footer,
    );
    final builder = blockComponentBuilder(node.type);
    if (builder == null) {
      assert(false, 'no builder for node type(${node.type})');
      return _buildPlaceHolderWidget(blockComponentContext);
    }
    if (!builder.validate(node)) {
      assert(
        false,
        'node(${node.type}) is invalid, attributes: ${node.attributes}, children: ${node.children}',
      );
      return _buildPlaceHolderWidget(blockComponentContext);
    }

    return BlockComponentContainer(
      node: node,
      configuration: builder.configuration,
      builder: (_) => builder.build(blockComponentContext),
    );
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
