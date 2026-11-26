import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';

import 'package:countersink/data/backup.dart';
import 'package:countersink/data/qr_transfer.dart';
import 'package:countersink/ui/language.dart';
import 'package:countersink/ui/layout.dart';

/// Scans the codes shown by another phone's Send screen. Pops with what was
/// received, as a [BackupData], once every code is in; the caller adds it
/// beside what is already here.
///
/// This is the one place Countersink uses the camera, and so the one place
/// Android asks for it.
class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  /// Stands in for the camera in tests, which have none: given the function
  /// to call with each code's text, it returns what to show in the
  /// camera's place.
  @visibleForTesting
  static Widget Function(ValueChanged<String> onText)? readerForTests;

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  TransferReceiver _receiver = TransferReceiver();
  String? _cameraProblem;
  String? _notice;
  bool _done = false;

  void _onScan(Code code) {
    final text = code.text;
    if (!code.isValid || text == null) return;
    _onText(text);
  }

  void _onText(String text) {
    if (_done) return;
    final result = _receiver.add(text);
    setState(() {
      _notice = switch (result) {
        FrameResult.notCountersink => context.l.shareNotCountersink,
        FrameResult.newerVersion => context.l.shareNewerVersion,
        FrameResult.restarted => context.l.shareRestarted,
        FrameResult.added || FrameResult.duplicate => null,
      };
    });
    if (_receiver.isComplete) _finish();
  }

  void _finish() {
    _done = true;
    try {
      final backup = decodeBackup(_receiver.assemble());
      Navigator.of(context).pop(backup);
    } on BackupFormatException {
      _startOver(context.l.shareUnreadable);
    } on FormatException {
      _startOver(context.l.shareUnreadable);
    }
  }

  void _startOver(String why) {
    setState(() {
      _receiver = TransferReceiver();
      _done = false;
      _notice = why;
    });
  }

  void _onCamera(Object? controller, Exception? error) {
    if (error == null) return;
    setState(() => _cameraProblem = context.l.shareNeedsCamera);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = context.l;
    final r = _receiver;
    final reader = ReceiveScreen.readerForTests;

    final String status;
    if (r.total == 0) {
      status = l.sharePointCamera;
    } else if (r.total == 1) {
      status = l.shareReading;
    } else {
      status = l.shareCodesReceived(r.received, r.total);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.receiveFromPhone)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Readable(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(status, style: theme.textTheme.titleMedium),
                  if (r.total > 1) ...[
                    const SizedBox(height: 10),
                    LinearProgressIndicator(value: r.received / r.total),
                    if (r.missing.isNotEmpty && r.received > 0) ...[
                      const SizedBox(height: 6),
                      Text(
                        l.shareStillNeeded(r.missing.join(', ')),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                  if (_notice != null) ...[
                    const SizedBox(height: 8),
                    Text(_notice!, style: theme.textTheme.bodyMedium),
                  ],
                ],
              ),
            ),
          ),
          Expanded(
            child: reader != null
                ? reader(_onText)
                : _cameraProblem != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(_cameraProblem!, textAlign: TextAlign.center),
                    ),
                  )
                : ReaderWidget(
                    onScan: _onScan,
                    onControllerCreated: _onCamera,
                    codeFormat: Format.qrCode,
                    tryHarder: true,
                    showToggleCamera: false,
                    // Reading a saved screenshot works too, through the
                    // system photo picker: no storage permission needed.
                    showGallery: true,
                    cropPercent: 0.8,
                    scanDelay: const Duration(milliseconds: 250),
                    scanDelaySuccess: const Duration(milliseconds: 250),
                  ),
          ),
        ],
      ),
    );
  }
}
