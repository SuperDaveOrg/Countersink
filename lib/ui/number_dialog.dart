import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:countersink/ui/language.dart';

/// Whole numbers this long and no longer, so a slip of the thumb can't
/// overflow a count.
const maxNumberDigits = 9;

/// Reads what was typed as a whole number, or null if it isn't one.
int? parseWholeNumber(String text) => int.tryParse(text.trim());

/// Asks for one whole number, with the number keyboard. [initial] starts
/// the field off, selected so typing replaces it. Nothing below [min] is
/// accepted. Null if cancelled.
Future<int?> showNumberDialog(
  BuildContext context, {
  required String title,
  required String label,
  required String action,
  int? initial,
  int min = 0,
}) => showDialog<int>(
  context: context,
  builder: (_) => _NumberDialog(
    title: title,
    label: label,
    action: action,
    initial: initial,
    min: min,
  ),
);

class _NumberDialog extends StatefulWidget {
  const _NumberDialog({
    required this.title,
    required this.label,
    required this.action,
    required this.initial,
    required this.min,
  });

  final String title;
  final String label;
  final String action;
  final int? initial;
  final int min;

  @override
  State<_NumberDialog> createState() => _NumberDialogState();
}

class _NumberDialogState extends State<_NumberDialog> {
  late final _text = TextEditingController(text: widget.initial?.toString());

  @override
  void initState() {
    super.initState();
    _text.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _text.text.length,
    );
    // The action stays off until there's a number that will do.
    _text.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  int? get _number {
    final n = parseWholeNumber(_text.text);
    return n == null || n < widget.min ? null : n;
  }

  void _done() {
    final n = _number;
    if (n != null) Navigator.pop(context, n);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _text,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(maxNumberDigits),
        ],
        decoration: InputDecoration(labelText: widget.label),
        onSubmitted: (_) => _done(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l.cancel),
        ),
        TextButton(
          onPressed: _number == null ? null : _done,
          child: Text(widget.action),
        ),
      ],
    );
  }
}
