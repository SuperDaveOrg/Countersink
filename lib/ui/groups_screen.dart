import 'package:flutter/material.dart';

import 'package:countersink/models/counter_group.dart';
import 'package:countersink/ui/archived_screen.dart';
import 'package:countersink/ui/counter_store.dart';
import 'package:countersink/ui/language.dart';
import 'package:countersink/ui/layout.dart';
import 'package:countersink/ui/presets.dart';

/// The groups, which are the tabs on the home screen: add (empty, or as a
/// ready-made set), rename, copy, drag into order, delete.
class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key, required this.store});

  final CounterStore store;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final theme = Theme.of(context);
        final l = context.l;
        final groups = store.counters.groups;
        // There is always one tab to count on.
        final canDelete = groups.length > 1;
        return Scaffold(
          appBar: AppBar(
            title: Text(l.groups),
            actions: [
              IconButton(
                tooltip: l.archivedCounters,
                icon: const Icon(Icons.archive_outlined),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ArchivedScreen(store: store),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _add(context),
            icon: const Icon(Icons.add),
            label: Text(l.addGroup),
          ),
          body: ReorderableListView.builder(
            // Room at the bottom so the last row clears the add button.
            padding: readablePadding(
              context,
              base: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            ),
            buildDefaultDragHandles: false,
            itemCount: groups.length,
            onReorderItem: store.moveGroup,
            itemBuilder: (context, i) {
              final group = groups[i];
              return Padding(
                key: ValueKey(group.id),
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    contentPadding: const EdgeInsetsDirectional.only(
                      start: 4,
                      end: 4,
                    ),
                    leading: ReorderableDragStartListener(
                      index: i,
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.drag_handle),
                      ),
                    ),
                    title: Text(group.name),
                    subtitle: Text(
                      l.countersCount(store.counters.inGroup(group.id).length),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // The same counters again, for the next game or
                        // the next piece of knitting.
                        IconButton(
                          tooltip: l.copyGroupNamed(group.name),
                          icon: const Icon(Icons.copy_outlined),
                          onPressed: () => store.copyGroup(
                            group,
                            l.groupCopyName(group.name),
                          ),
                        ),
                        IconButton(
                          tooltip: canDelete
                              ? l.deleteNamed(group.name)
                              : l.lastGroupHint,
                          icon: const Icon(Icons.delete_outline),
                          color: theme.colorScheme.error,
                          onPressed: canDelete
                              ? () => _delete(context, group)
                              : null,
                        ),
                      ],
                    ),
                    onTap: () => _rename(context, group),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// An empty group to name, or a ready-made set that brings its counters
  /// with it and can be renamed like any other.
  Future<void> _add(BuildContext context) async {
    final theme = Theme.of(context);
    final sets = presets(context.l);
    // -1 for an empty group, otherwise a set's place in the list.
    final choice = await showModalBottomSheet<int>(
      context: context,
      // As tall as it needs, and scrolling on a short or sideways screen.
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(Icons.add),
                title: Text(context.l.emptyGroup),
                subtitle: Text(context.l.emptyGroupHint),
                onTap: () => Navigator.pop(context, -1),
              ),
              const Divider(indent: 16, endIndent: 16),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
                child: Text(
                  context.l.readyMadeSets.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              for (final (i, set) in sets.indexed)
                ListTile(
                  leading: const Icon(Icons.dashboard_customize_outlined),
                  title: Text(set.name),
                  subtitle: Text(set.description),
                  onTap: () => Navigator.pop(context, i),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
    if (choice == null || !context.mounted) return;
    if (choice >= 0) {
      await store.addGroupWith(sets[choice].name, sets[choice].counters);
      return;
    }
    final name = await _askName(context);
    if (name != null) await store.addGroup(name);
  }

  Future<void> _rename(BuildContext context, CounterGroup group) async {
    final name = await _askName(context, existing: group.name);
    if (name != null && name != group.name) {
      await store.renameGroup(group, name);
    }
  }

  /// Deletes straight away and offers to undo, as deleting a counter does.
  /// Undo brings back the tab, its counters and their history.
  Future<void> _delete(BuildContext context, CounterGroup group) async {
    final messenger = ScaffoldMessenger.of(context);
    final l = context.l;
    final deleted = await store.deleteGroup(group);
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          // Goes after its time like any other message. Left to itself, one
          // with a button now stays until it is dismissed.
          persist: false,
          content: Text(l.groupDeleted(group.name, deleted.counters.length)),
          duration: const Duration(seconds: 8),
          action: SnackBarAction(
            label: l.undo,
            onPressed: () => store.restoreGroup(deleted),
          ),
        ),
      );
  }
}

/// Asks for a group's name; null if canceled or left empty.
Future<String?> _askName(BuildContext context, {String? existing}) =>
    showDialog<String>(
      context: context,
      builder: (_) => _GroupNameDialog(existing: existing),
    );

class _GroupNameDialog extends StatefulWidget {
  const _GroupNameDialog({this.existing});

  final String? existing;

  @override
  State<_GroupNameDialog> createState() => _GroupNameDialogState();
}

class _GroupNameDialogState extends State<_GroupNameDialog> {
  late final _name = TextEditingController(text: widget.existing);

  @override
  void initState() {
    super.initState();
    // The action stays off until there's a name.
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _done() {
    final name = _name.text.trim();
    if (name.isNotEmpty) Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final editing = widget.existing != null;
    return AlertDialog(
      title: Text(editing ? l.renameGroup : l.addGroup),
      content: TextField(
        controller: _name,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: l.groupName),
        onSubmitted: (_) => _done(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel),
        ),
        TextButton(
          onPressed: _name.text.trim().isEmpty ? null : _done,
          child: Text(editing ? l.save : l.add),
        ),
      ],
    );
  }
}
