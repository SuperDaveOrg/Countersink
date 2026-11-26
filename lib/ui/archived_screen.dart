import 'package:flutter/material.dart';

import 'package:countersink/models/counter.dart';
import 'package:countersink/ui/counter_look.dart';
import 'package:countersink/ui/counter_store.dart';
import 'package:countersink/ui/history_screen.dart';
import 'package:countersink/ui/language.dart';
import 'package:countersink/ui/layout.dart';

/// The counters put away: off their tabs, with their history kept. Each
/// can be looked back over, moved back to its group, or deleted.
class ArchivedScreen extends StatelessWidget {
  const ArchivedScreen({super.key, required this.store});

  final CounterStore store;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final theme = Theme.of(context);
        final l = context.l;
        final counters = store.counters;
        final archived = counters.archived;
        final groupNames = {for (final g in counters.groups) g.id: g.name};
        return Scaffold(
          appBar: AppBar(title: Text(l.archivedCounters)),
          body: archived.isEmpty
              ? Center(
                  child: Text(
                    l.noArchived,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: readablePadding(
                    context,
                    base: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  ),
                  itemCount: archived.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final counter = archived[i];
                    return Card(
                      key: ValueKey(counter.id),
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        leading: LookBox(
                          look: lookOf(counter),
                          circle: true,
                          width: 32,
                          height: 32,
                        ),
                        title: Text(
                          counter.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          groupNames[counter.groupId] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // What it had reached, all told.
                        trailing: Text(
                          '${counters.totals[counter.id] ?? 0}',
                          style: theme.textTheme.titleLarge,
                        ),
                        onTap: () => _menu(context, counter),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Future<void> _menu(BuildContext context, Counter counter) async {
    final theme = Theme.of(context);
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  counter.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.unarchive_outlined),
              title: Text(context.l.unarchive),
              onTap: () => Navigator.pop(context, 'unarchive'),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: Text(context.l.history),
              onTap: () => Navigator.pop(context, 'history'),
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.error,
              ),
              title: Text(
                context.l.delete,
                style: TextStyle(color: theme.colorScheme.error),
              ),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (!context.mounted) return;
    switch (choice) {
      case 'unarchive':
        await store.unarchiveCounter(counter);
      case 'history':
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HistoryScreen(store: store, counter: counter),
          ),
        );
      case 'delete':
        final messenger = ScaffoldMessenger.of(context);
        final l = context.l;
        final deleted = await store.deleteCounter(counter);
        messenger
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              // Goes after its time like any other message. Left to itself, one
              // with a button now stays until it is dismissed.
              persist: false,
              content: Text(l.counterDeleted(counter.name)),
              duration: const Duration(seconds: 8),
              action: SnackBarAction(
                label: l.undo,
                onPressed: () => store.restoreCounter(deleted),
              ),
            ),
          );
    }
  }
}
