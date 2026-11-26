import 'package:flutter/material.dart';

import 'package:countersink/models/counter_group.dart';
import 'package:countersink/ui/counter_look.dart';
import 'package:countersink/ui/counter_store.dart';
import 'package:countersink/ui/language.dart';
import 'package:countersink/ui/layout.dart';

/// One group's counters as a list to drag into order. Kept apart from the
/// home screen, where a drag would be too easy to start in the middle of a
/// count.
class ArrangeScreen extends StatelessWidget {
  const ArrangeScreen({super.key, required this.store, required this.group});

  final CounterStore store;
  final CounterGroup group;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final counters = store.counters.inGroup(group.id);
        return Scaffold(
          appBar: AppBar(title: Text(context.l.reorderCounters)),
          body: ReorderableListView.builder(
            padding: readablePadding(
              context,
              base: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            ),
            buildDefaultDragHandles: false,
            itemCount: counters.length,
            onReorderItem: (from, to) => store.moveCounter(group.id, from, to),
            itemBuilder: (context, i) {
              final counter = counters[i];
              return Padding(
                key: ValueKey(counter.id),
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    contentPadding: const EdgeInsetsDirectional.only(
                      start: 4,
                      end: 16,
                    ),
                    leading: ReorderableDragStartListener(
                      index: i,
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.drag_handle),
                      ),
                    ),
                    title: Text(
                      counter.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: LookBox(
                      look: lookOf(counter),
                      circle: true,
                      width: 28,
                      height: 28,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
