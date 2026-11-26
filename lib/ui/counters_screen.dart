import 'package:flutter/material.dart';

import 'package:countersink/models/counter_group.dart';
import 'package:countersink/ui/counter_actions.dart';
import 'package:countersink/ui/counter_editor.dart';
import 'package:countersink/ui/counter_store.dart';
import 'package:countersink/ui/groups_screen.dart';
import 'package:countersink/ui/language.dart';
import 'package:countersink/ui/layout.dart';
import 'package:countersink/ui/search_screen.dart';
import 'package:countersink/ui/settings_screen.dart';

/// Home: the groups as tabs, each a list of counter cards.
class CountersScreen extends StatelessWidget {
  const CountersScreen({super.key, required this.store});

  final CounterStore store;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final groups = store.counters.groups;
        return DefaultTabController(
          // A new controller when a group comes or goes.
          key: ValueKey(groups.length),
          length: groups.length,
          child: Builder(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: Text(context.l.appTitle),
                actions: [
                  IconButton(
                    tooltip: context.l.search,
                    icon: const Icon(Icons.search),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SearchScreen(store: store),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: context.l.groups,
                    icon: const Icon(Icons.folder_outlined),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GroupsScreen(store: store),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: context.l.settings,
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SettingsScreen(store: store),
                      ),
                    ),
                  ),
                ],
                bottom: groups.isEmpty
                    ? null
                    : TabBar(
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        tabs: [for (final g in groups) Tab(text: g.name)],
                      ),
              ),
              floatingActionButton: groups.isEmpty
                  ? null
                  : FloatingActionButton.extended(
                      onPressed: () => _addCounter(
                        context,
                        groups[DefaultTabController.of(context).index],
                      ),
                      icon: const Icon(Icons.add),
                      label: Text(context.l.addCounter),
                    ),
              body: TabBarView(
                children: [
                  for (final g in groups) _GroupList(store: store, group: g),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _addCounter(BuildContext context, CounterGroup group) async {
    final draft = await showCounterEditor(
      context,
      counters: store.counters,
      suggested: store.nextColor,
    );
    if (draft == null) return;
    await store.addCounter(
      groupId: group.id,
      name: draft.name,
      description: draft.description,
      color: draft.look.color,
      color2: draft.look.color2,
      pattern: draft.look.pattern,
      step: draft.step,
      goal: draft.goal,
      goalPeriod: draft.goalPeriod,
      buzzEvery: draft.buzzEvery,
      formula: draft.formula.formula,
      sources: draft.formula.sources,
      roundSize: draft.formula.roundSize,
      allTime: draft.formula.allTime,
      startFrom: draft.formula.startFrom,
      daily: draft.daily,
    );
  }
}

class _GroupList extends StatelessWidget {
  const _GroupList({required this.store, required this.group});

  final CounterStore store;
  final CounterGroup group;

  @override
  Widget build(BuildContext context) {
    final counters = store.counters.inGroup(group.id);
    if (counters.isEmpty) {
      return Center(
        child: Text(
          context.l.noCounters,
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
    }
    return ListView.separated(
      // Room at the bottom so the last card clears the add button.
      padding: readablePadding(
        context,
        base: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      ),
      itemCount: counters.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final counter = counters[i];
        return LiveCounterCard(
          key: ValueKey(counter.id),
          store: store,
          counter: counter,
        );
      },
    );
  }
}
