import 'dart:convert';

import 'package:flutter/services.dart';

/// Android's own Save and Open pickers, via MainActivity.
///
/// The user picks the location every time. Countersink never writes a file on
/// its own and never learns where the file went beyond the one document
/// chosen.
class DocumentService {
  static const _channel = MethodChannel('countersink/documents');

  /// Offers to save [text] as [suggestedName]. False if the user backed out.
  Future<bool> save(
    String suggestedName,
    String text, {
    String mimeType = 'application/json',
  }) async {
    final saved = await _channel.invokeMethod<bool>('save', {
      'name': suggestedName,
      'bytes': Uint8List.fromList(utf8.encode(text)),
      'mimeType': mimeType,
    });
    return saved ?? false;
  }

  /// The chosen file's text, or null if the user backed out.
  Future<String?> open() async {
    final bytes = await _channel.invokeMethod<Uint8List>('open');
    return bytes == null ? null : utf8.decode(bytes, allowMalformed: true);
  }

  /// Asks for a folder to keep automatic backups in. Android remembers that
  /// the app may write there. Null if the user backed out.
  Future<({String uri, String name})?> pickFolder() async {
    final picked = await _channel.invokeMapMethod<String, String>('pickFolder');
    if (picked == null) return null;
    return (uri: picked['uri']!, name: picked['name'] ?? '');
  }

  /// Writes [text] as [name] in a folder from [pickFolder], replacing a file
  /// of that name, then deletes all but the newest [keep] files there whose
  /// names start with [prefix]. Throws if the folder can't be written to,
  /// which is what happens when it has been deleted or access taken away.
  Future<void> writeToFolder(
    String folder, {
    required String name,
    required String text,
    required String prefix,
    required int keep,
  }) => _channel.invokeMethod<bool>('writeToFolder', {
    'folder': folder,
    'name': name,
    'bytes': Uint8List.fromList(utf8.encode(text)),
    'prefix': prefix,
    'keep': keep,
  });

  /// Gives back the access [pickFolder] was granted.
  Future<void> releaseFolder(String folder) =>
      _channel.invokeMethod<void>('releaseFolder', {'folder': folder});
}
