import 'package:flutter/material.dart';

import 'package:countersink/domain/search.dart';
import 'package:countersink/ui/counter_actions.dart';
import 'package:countersink/ui/counter_store.dart';
import 'package:countersink/ui/language.dart';
import 'package:countersink/ui/layout.dart';

/// Finds counters across every group as you type, and shows them as their
/// own cards, so the one you were looking for can be counted on right here.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.store});

  final CounterStore store;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _query = TextEditingController();

  @override
  void initState() {
    super.initState();
    _query.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = context.l;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _query,
          autofocus: true,
          textInputAction: TextInputAction.search,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: l.searchHint,
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
        actions: [
          if (_query.text.isNotEmpty)
            IconButton(
              tooltip: MaterialLocalizations.of(context).clearButtonTooltip,
              icon: const Icon(Icons.close),
              onPressed: _query.clear,
            ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.store,
        builder: (context, _) {
          final counters = widget.store.counters;
          final found = searchCounters(counters, _query.text);
          if (found.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  _query.text.trim().isEmpty ? l.searchPrompt : l.noResults,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }
          final groupNames = {for (final g in counters.groups) g.id: g.name};
          return ListView.separated(
            padding: readablePadding(
              context,
              base: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            ),
            itemCount: found.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final counter = found[i];
              return Column(
                key: ValueKey(counter.id),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Which tab it lives on, when that changes down the list.
                  if (i == 0 || found[i - 1].groupId != counter.groupId)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                      child: Text(
                        (groupNames[counter.groupId] ?? '').toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  LiveCounterCard(store: widget.store, counter: counter),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
