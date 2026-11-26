import 'dart:async';

import 'package:flutter/material.dart';

import 'package:countersink/data/backup.dart';
import 'package:countersink/data/importers.dart';
import 'package:countersink/data/qr_transfer.dart';
import 'package:countersink/models/counter.dart';
import 'package:countersink/services/app_info.dart';
import 'package:countersink/services/preferences.dart';
import 'package:countersink/ui/counter_look.dart';
import 'package:countersink/ui/counter_store.dart';
import 'package:countersink/ui/language.dart';
import 'package:countersink/ui/layout.dart';
import 'package:countersink/ui/qr_code_view.dart';
import 'package:countersink/ui/section.dart';

/// Sends counters to another phone as a series of QR codes: everything, or
/// the counters chosen, with their history or with just their numbers. The
/// other phone scans them on its Receive screen. Nothing leaves this phone
/// any other way, and nothing here is changed by sending.
class SendScreen extends StatefulWidget {
  const SendScreen({super.key, required this.store});

  final CounterStore store;

  @override
  State<SendScreen> createState() => _SendScreenState();
}

enum _Stage { what, codes }

class _SendScreenState extends State<SendScreen> {
  /// How long each code stays up. Long enough for a camera to lock on.
  static const _dwell = Duration(milliseconds: 1800);

  _Stage _stage = _Stage.what;
  bool _everything = true;
  bool _withHistory = true;

  /// The counters ticked under "Just some counters".
  final _chosen = <String>{};

  BackupData? _sent;
  List<String> _frames = const [];
  int _index = 0;
  bool _playing = true;
  Timer? _timer;

  CounterStore get _store => widget.store;

  Future<void> _send() async {
    final all = await _store.exportData();
    final sent = selectForTransfer(
      all,
      _everything ? {for (final c in all.counters) c.id} : _chosen,
      withHistory: _withHistory,
      valueOf: _store.counters.valueOf,
      now: _store.now,
    );
    if (!mounted) return;
    setState(() {
      _sent = sent;
      _frames = encodeTransfer(encodeBackup(sent, exportedAt: _store.now));
      _index = 0;
      _playing = true;
      _stage = _Stage.codes;
    });
    // The codes take a while to get through; the screen shouldn't dim.
    keepScreenOn(true);
    _schedule();
  }

  void _schedule() {
    _timer?.cancel();
    if (!_playing || _frames.length < 2) return;
    _timer = Timer.periodic(_dwell, (_) => _step(1, fromTimer: true));
  }

  /// Stepping by hand stops the codes changing on their own.
  void _step(int by, {bool fromTimer = false}) {
    setState(() => _index = (_index + by) % _frames.length);
    if (!fromTimer && _playing) {
      setState(() => _playing = false);
      _timer?.cancel();
    }
  }

  void _togglePlaying() {
    setState(() => _playing = !_playing);
    _schedule();
  }

  /// Back from the codes to the choices, with the screen left to its setting.
  void _backToChoices() {
    _timer?.cancel();
    Preferences.keepScreenOn().then(keepScreenOn);
    setState(() => _stage = _Stage.what);
  }

  @override
  void dispose() {
    _timer?.cancel();
    Preferences.keepScreenOn().then(keepScreenOn);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l.sendToPhone)),
      body: PopScope(
        canPop: _stage == _Stage.what,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _backToChoices();
        },
        child: switch (_stage) {
          _Stage.what => _choices(context),
          _Stage.codes => _codes(context),
        },
      ),
    );
  }

  Widget _radio({
    required bool selected,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) => ListTile(
    leading: Icon(
      selected ? Icons.radio_button_checked : Icons.radio_button_off,
    ),
    title: Text(title),
    subtitle: subtitle == null ? null : Text(subtitle),
    selected: selected,
    onTap: onTap,
  );

  Widget _choices(BuildContext context) {
    final theme = Theme.of(context);
    final l = context.l;
    final counters = _store.counters;
    final ready = _everything || _chosen.isNotEmpty;

    return ListView(
      padding: readablePadding(
        context,
        base: const EdgeInsets.only(bottom: 32),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: Text(l.shareWhatToSend, style: theme.textTheme.titleLarge),
        ),
        Section(
          children: [
            _radio(
              selected: _everything,
              title: l.sendEverything,
              subtitle: l.sendEverythingHint,
              onTap: () => setState(() => _everything = true),
            ),
            _radio(
              selected: !_everything,
              title: l.sendSomeCounters,
              onTap: () => setState(() => _everything = false),
            ),
          ],
        ),
        if (!_everything)
          for (final g in counters.groups)
            if (counters.inGroup(g.id).isNotEmpty)
              Section(
                title: g.name,
                children: [
                  for (final c in counters.inGroup(g.id)) _counterRow(c),
                ],
              ),
        Section(
          title: l.shareWhatToInclude,
          children: [
            _radio(
              selected: _withHistory,
              title: l.sendWithHistory,
              subtitle: l.sendWithHistoryHint,
              onTap: () => setState(() => _withHistory = true),
            ),
            _radio(
              selected: !_withHistory,
              title: l.sendNumbersOnly,
              subtitle: l.sendNumbersOnlyHint,
              onTap: () => setState(() => _withHistory = false),
            ),
          ],
        ),
        if (!ready)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Text(
              l.sendNothingChosen,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          child: FilledButton(
            onPressed: ready ? _send : null,
            child: Text(l.shareShowCodes),
          ),
        ),
      ],
    );
  }

  Widget _counterRow(Counter counter) => CheckboxListTile(
    secondary: SizedBox.square(
      dimension: 28,
      child: LookBox(look: lookOf(counter), circle: true),
    ),
    title: Text(counter.name, maxLines: 1, overflow: TextOverflow.ellipsis),
    value: _chosen.contains(counter.id),
    onChanged: (on) => setState(() {
      if (on ?? false) {
        _chosen.add(counter.id);
      } else {
        _chosen.remove(counter.id);
      }
    }),
  );

  Widget _codes(BuildContext context) {
    final theme = Theme.of(context);
    final l = context.l;
    final sent = _sent!;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return ListView(
      padding: readablePadding(
        context,
        base: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        maxWidth: 480,
      ),
      children: [
        Text(l.shareHowToReceive, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: QrCodeView(data: _frames[_index]),
        ),
        const SizedBox(height: 16),
        if (_frames.length > 1) ...[
          Text(
            l.shareCodeOf(_index + 1, _frames.length),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                tooltip: l.sharePreviousCode,
                onPressed: () => _step(-1),
              ),
              IconButton.filledTonal(
                icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
                tooltip: _playing ? l.sharePause : l.sharePlay,
                onPressed: _togglePlaying,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                tooltip: l.shareNextCode,
                onPressed: () => _step(1),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(l.shareCodesChange, textAlign: TextAlign.center, style: muted),
        ],
        const SizedBox(height: 16),
        Text(
          l.sendSummary(
            l.countersCount(sent.counters.length),
            l.entriesCount(sent.events.length),
          ),
          textAlign: TextAlign.center,
          style: muted,
        ),
        const SizedBox(height: 20),
        FilledButton.tonal(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.done),
        ),
      ],
    );
  }
}
