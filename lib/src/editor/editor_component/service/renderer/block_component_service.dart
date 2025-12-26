import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// The key used for the error block component builder.
///
/// This is used when a block fails validation and needs to be rendered
/// as a placeholder error widget.
const errorBlockComponentBuilderKey = 'errorBlockComponentBuilderKey';

/// Forces block actions to always show.
///
/// This value is only for testing purposes.
bool forceShowBlockAction = false;

/// A function that builds the action widget shown when hovering over a block.
///
/// Parameters:
/// - [blockComponentContext]: Context information about the block
/// - [state]: The current state of the block component action
///
/// Returns a widget to display as the block action (e.g., drag handle, add button).
typedef BlockActionBuilder = Widget Function(
  BlockComponentContext blockComponentContext,
  BlockComponentActionState state,
);

/// A function that builds the trailing action widget shown after the block.
///
/// Parameters:
/// - [blockComponentContext]: Context information about the block
/// - [state]: The current state of the block component action
///
/// Returns a widget to display after the block content.
typedef BlockActionTrailingBuilder = Widget Function(
  BlockComponentContext blockComponentContext,
  BlockComponentActionState state,
);

/// A function that validates whether a node can be rendered by a block component.
///
/// Returns true if the node is valid for this component, false otherwise.
/// If false, the node will be displayed as a placeholder error widget.
typedef BlockComponentValidate = bool Function(Node node);

/// Interface for controlling block component action visibility.
abstract class BlockComponentActionState {
  /// Sets whether the block actions should always be visible.
  set alwaysShowActions(bool alwaysShowActions);
}

/// Abstract builder for creating block component widgets.
///
/// This is the core extensibility point for adding new block types to the editor.
/// Implement this class to create custom block components.
///
/// Example:
/// ```dart
/// class MyBlockComponentBuilder extends BlockComponentBuilder {
///   @override
///   BlockComponentWidget build(BlockComponentContext context) {
///     return MyBlockComponentWidget(
///       key: context.node.key,
///       node: context.node,
///       configuration: configuration,
///     );
///   }
/// }
/// ```
abstract class BlockComponentBuilder with BlockComponentSelectable {
  BlockComponentBuilder({
    this.configuration = const BlockComponentConfiguration(),
  });

  /// Validates whether a node can be rendered by this component.
  ///
  /// Return true if the node is valid.
  /// Return false if the node is invalid - it will be displayed as a placeholder widget.
  BlockComponentValidate validate = (_) => true;

  /// Builds the block component widget.
  ///
  /// This is the main method that creates the visual representation of the block.
  BlockComponentWidget build(BlockComponentContext blockComponentContext);

  /// Determines whether to show action buttons for a node.
  ///
  /// Return true to display action buttons (e.g., drag handle, add button).
  bool Function(Node node) showActions = (_) => false;

  /// Builds the action widget shown when hovering over the block.
  BlockActionBuilder actionBuilder = (_, __) => const SizedBox.shrink();

  /// Builds the trailing action widget shown after the block.
  BlockActionTrailingBuilder actionTrailingBuilder =
      (_, __) => const SizedBox.shrink();

  /// Configuration for the block component's appearance and behavior.
  BlockComponentConfiguration configuration =
      const BlockComponentConfiguration();
}

/// Mixin that provides selection boundary methods for block components.
///
/// This mixin defines how to determine the start and end positions
/// for selection within a block component.
mixin BlockComponentSelectable<T extends BlockComponentBuilder> {
  /// Gets the start position of the block component.
  ///
  /// For text block components, this is always position 0.
  /// Override this for custom selection behavior.
  Position start(Node node) => Position(path: node.path, offset: 0);

  /// Gets the end position of the block component.
  ///
  /// For text block components, this is the length of the text delta.
  /// Override this for custom selection behavior.
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
    BlockComponentWrapper? wrapper,
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
    BlockComponentWrapper? wrapper,
  }) {
    final blockComponentContext = BlockComponentContext(
      buildContext,
      node,
      header: header,
      footer: footer,
      wrapper: wrapper,
    );
    final errorBuilder = _builders[errorBlockComponentBuilderKey];
    final builder = blockComponentBuilder(node.type);
    if (builder == null || !builder.validate(node)) {
      if (errorBuilder != null) {
        return BlockComponentContainer(
          node: node,
          configuration: errorBuilder.configuration,
          builder: (_) => errorBuilder.build(blockComponentContext),
        );
      } else {
        return _buildPlaceHolderWidget(blockComponentContext);
      }
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
    AppFlowyEditorLog.editor
        .info('register block component builder for type($type)');
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
