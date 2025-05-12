import 'dart:async';
import 'dart:typed_data';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor_sync_plugin/appflowy_editor_sync_utility_functions.dart';
import 'package:appflowy_editor_sync_plugin/editor_state_sync_wrapper.dart';
import 'package:appflowy_editor_sync_plugin/types/sync_db_attributes.dart';
import 'package:appflowy_editor_sync_plugin/types/update_types.dart';
import 'package:flutter/material.dart';

/// Manages changes and updates for an editor in a collaborative setting
class EditorChanges {
  final _updatesStreamController = StreamController<List<DbUpdate>>.broadcast();
  final List<DbUpdate> updates = [];
  final List<DbUpdate> pendingUpdates = [];

  /// Updates length Notifier
  final ValueNotifier<int> updatesLengthNotifier = ValueNotifier(0);
  final ValueNotifier<int> pendingUpdatesLengthNotifier = ValueNotifier(0);

  /// Stream of updates that can be subscribed to
  Stream<List<DbUpdate>> get updatesStream => _updatesStreamController.stream;

  /// Add an update and broadcast it to listeners
  void addUpdate(DbUpdate update) {
    updates.add(update);
    _updateStream();
  }

  /// Add a pending update (for offline mode)
  void addPending(DbUpdate update) {
    pendingUpdates.add(update);
    pendingUpdatesLengthNotifier.value = pendingUpdates.length;
  }

  /// Apply all pending updates and broadcast them
  void applyAllPending() {
    if (pendingUpdates.isNotEmpty) {
      updates.addAll(pendingUpdates);
      pendingUpdates.clear();
      _updateStream();
    }
  }

  void _updateStream() async {
    // This function is not used in the current implementation
    // but can be used to update the stream with new data
    _updatesStreamController.add(updates);
    updatesLengthNotifier.value = updates.length;
    pendingUpdatesLengthNotifier.value = pendingUpdates.length;
  }

  /// Get all updates as a list
  List<DbUpdate> getAllUpdates() {
    return List<DbUpdate>.from(updates);
  }

  /// Dispose of resources
  void dispose() {
    _updatesStreamController.close();
  }
}

class CollabEditorOffline extends StatefulWidget {
  const CollabEditorOffline({super.key});

  @override
  State<CollabEditorOffline> createState() => _CollabEditorState();
}

class _CollabEditorState extends State<CollabEditorOffline> {
  late EditorState editorStateA;
  late EditorState editorStateB;
  late EditorStateSyncWrapper wrapperA;
  late EditorStateSyncWrapper wrapperB;

  late EditorChanges changesA;
  late EditorChanges changesB;

  bool isOnline = true;
  bool isInitialized = false;
  List<Uint8List> initialUpdates = [];

  @override
  void initState() {
    super.initState();
    changesA = EditorChanges();
    changesB = EditorChanges();
    _initializeDocument();
  }

  Future<void> _initializeDocument() async {
    // Create a document and get initial updates
    initialUpdates = [
      await AppflowyEditorSyncUtilityFunctions.initDocumentFromExistingDocument(
        Document.blank(withInitialText: true),
      ),
    ];

    await _initEditors();
    setState(() {
      isInitialized = true;
    });
  }

  Future<void> _initEditors() async {
    // Add initial updates to both editors
    for (final update in initialUpdates) {
      changesA.addUpdate(DbUpdate(update: update));
      changesB.addUpdate(DbUpdate(update: update));
    }

    // Initialize editor A
    wrapperA = EditorStateSyncWrapper(
      syncAttributes: SyncAttributes(
        // Both editors get the same initial updates
        getInitialUpdates: () async {
          return changesA.getAllUpdates();
        },
        getUpdatesStream: changesA.updatesStream,
        saveUpdate: (Uint8List update) async {
          if (isOnline) {
            changesA.addUpdate(DbUpdate(update: update));
            changesB.addUpdate(DbUpdate(update: update));
          } else {
            changesA.addUpdate(DbUpdate(update: update));
            changesB.addPending(DbUpdate(update: update));
          }
        },
      ),
    );

    // Initialize editor B
    wrapperB = EditorStateSyncWrapper(
      syncAttributes: SyncAttributes(
        // Both editors get the same initial updates
        getInitialUpdates: () async {
          return changesB.getAllUpdates();
        },
        getUpdatesStream: changesB.updatesStream,
        saveUpdate: (Uint8List update) async {
          if (isOnline) {
            changesA.addUpdate(DbUpdate(update: update));
            changesB.addUpdate(DbUpdate(update: update));
          } else {
            changesB.addUpdate(DbUpdate(update: update));
            changesA.addPending(DbUpdate(update: update));
          }
        },
      ),
    );

    editorStateA = await wrapperA.initAndHandleChanges();
    editorStateB = await wrapperB.initAndHandleChanges();
  }

  void _toggleOfflineMode() {
    setState(() {
      isOnline = !isOnline;
      if (isOnline) {
        changesA.applyAllPending();
        changesB.applyAllPending();
      }
    });
  }

  @override
  void dispose() {
    changesA.dispose();
    changesB.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Collaborative Offline Editor'),
            SizedBox(height: 8),
            Text(
              'Best tested on desktop',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Online Mode'),
                    Switch(
                      value: isOnline,
                      onChanged: (_) => _toggleOfflineMode(),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        const Text('Pending Updates A: '),
                        ValueListenableBuilder<int>(
                          valueListenable:
                              changesA.pendingUpdatesLengthNotifier,
                          builder: (context, value, _) => Text('$value'),
                        ),
                        const Text(', B: '),
                        ValueListenableBuilder<int>(
                          valueListenable:
                              changesB.pendingUpdatesLengthNotifier,
                          builder: (context, value, _) => Text('$value'),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Row(
                      children: [
                        const Text('History A: '),
                        ValueListenableBuilder<int>(
                          valueListenable: changesA.updatesLengthNotifier,
                          builder: (context, value, _) => Text('$value'),
                        ),
                        const Text(', B: '),
                        ValueListenableBuilder<int>(
                          valueListenable: changesB.updatesLengthNotifier,
                          builder: (context, value, _) => Text('$value'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: Column(
              children: [
                Flexible(
                  flex: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: !isOnline ? Colors.red : Colors.green,
                        width: 2,
                      ),
                    ),
                    child: AppFlowyEditor(
                      editorState: editorStateA,
                    ),
                  ),
                ),
                const Divider(),
                Flexible(
                  flex: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: !isOnline ? Colors.red : Colors.green,
                        width: 2,
                      ),
                    ),
                    child: AppFlowyEditor(
                      editorState: editorStateB,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
