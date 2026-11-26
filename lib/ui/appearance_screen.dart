import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:countersink/models/counter.dart';
import 'package:countersink/ui/counter_look.dart';
import 'package:countersink/ui/language.dart';
import 'package:countersink/ui/layout.dart';
import 'package:countersink/ui/section.dart';
import 'package:countersink/ui/theme.dart';

/// Opens the full choice of looks for a counter called [name], starting
/// from [look]. Null if backed out of.
Future<CounterLook?> showAppearance(
  BuildContext context, {
  required CounterLook look,
  required String name,
}) => Navigator.push<CounterLook>(
  context,
  MaterialPageRoute(
    builder: (_) => AppearanceScreen(look: look, name: name),
  ),
);

/// Every way a counter's card can look: any colour, a second colour to
/// blend into, and a pattern, with the card itself shown as it will be.
class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key, required this.look, required this.name});

  final CounterLook look;
  final String name;

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  late CounterLook _look = widget.look;

  void _set({
    Color? color,
    Color? Function()? color2,
    CounterPattern? pattern,
  }) => setState(() {
    _look = (
      color: color ?? _look.color,
      color2: color2 == null ? _look.color2 : color2(),
      pattern: pattern ?? _look.pattern,
    );
  });

  Future<void> _custom({required bool second}) async {
    final picked = await showColorPicker(
      context,
      initial: (second ? _look.color2 : null) ?? _look.color,
    );
    if (picked == null) return;
    second ? _set(color2: () => picked) : _set(color: picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = context.l;
    final ink = inkOnLook(_look);
    final name = widget.name.trim().isEmpty ? l.counterName : widget.name;

    return Scaffold(
      appBar: AppBar(title: Text(l.appearanceTitle)),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: readablePadding(
            context,
            base: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          ),
          child: FilledButton(
            onPressed: () => Navigator.pop(context, _look),
            child: Text(l.done),
          ),
        ),
      ),
      body: ListView(
        padding: readablePadding(
          context,
          base: const EdgeInsets.only(bottom: 24),
        ),
        children: [
          // The card as it will be.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: LookBox(
              look: _look,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(color: ink),
                    ),
                    Text(
                      l.sampleCount,
                      style: CountersinkTheme.font(
                        CountersinkTheme.serif,
                        56,
                        560,
                        height: 1.15,
                        color: ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Section(
            title: l.counterColor,
            children: [
              _Swatches(
                selected: _look.color,
                onPick: (c) => _set(color: c),
                onCustom: () => _custom(second: false),
              ),
            ],
          ),
          Section(
            title: l.secondColor,
            children: [
              // One block, so no divider falls between the note and the
              // swatches it is about.
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        l.secondColorHint,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ),
                  _Swatches(
                    selected: _look.color2,
                    allowNone: true,
                    onPick: (c) => _set(color2: () => c),
                    onNone: () => _set(color2: () => null),
                    onCustom: () => _custom(second: true),
                  ),
                ],
              ),
            ],
          ),
          Section(
            title: l.pattern,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    for (final p in CounterPattern.values) ...[
                      if (p != CounterPattern.values.first)
                        const SizedBox(width: 10),
                      Expanded(
                        child: _PatternChoice(
                          look: (
                            color: _look.color,
                            color2: _look.color2,
                            pattern: p,
                          ),
                          name: patternName(l, p),
                          selected: p == _look.pattern,
                          onTap: () => _set(pattern: p),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The named palette as a grid of round swatches, with "none" in front when
/// allowed and a swatch for mixing any other colour at the end.
class _Swatches extends StatelessWidget {
  const _Swatches({
    required this.selected,
    required this.onPick,
    required this.onCustom,
    this.allowNone = false,
    this.onNone,
  });

  final Color? selected;
  final ValueChanged<Color> onPick;
  final VoidCallback onCustom;
  final bool allowNone;
  final VoidCallback? onNone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = context.l;
    final selected = this.selected;
    final custom = selected != null && !counterPalette.contains(selected);
    // Full width, so the card around it is as wide as its neighbours
    // however the swatches happen to wrap.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          if (allowNone)
            ColorSwatchButton(
              name: l.noSecondColor,
              selected: selected == null,
              onTap: onNone!,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.colorScheme.outline),
                ),
                child: Icon(
                  Icons.block,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          for (final c in counterPalette)
            ColorSwatchButton(
              name: colorName(l, c),
              selected: c == selected,
              onTap: () => onPick(c),
              child: LookBox(
                look: plainLook(c),
                circle: true,
                child: c == selected
                    ? Icon(Icons.check, color: inkOn(c))
                    : null,
              ),
            ),
          // Any colour at all. Shows the one in use when it isn't a named one.
          ColorSwatchButton(
            name: l.customColor,
            selected: custom,
            onTap: onCustom,
            child: custom
                ? LookBox(
                    look: plainLook(selected),
                    circle: true,
                    child: Icon(
                      Icons.colorize,
                      size: 20,
                      color: inkOn(selected),
                    ),
                  )
                : Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          Color(0xFFC4613F),
                          Color(0xFFC28A2C),
                          Color(0xFF196741),
                          Color(0xFF1A8783),
                          Color(0xFF14344B),
                          Color(0xFF6B3F5B),
                          Color(0xFFC4613F),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.colorize,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// A round, tappable swatch with a ring when chosen. [name] is what a
/// screen reader says and what a long press shows.
class ColorSwatchButton extends StatelessWidget {
  const ColorSwatchButton({
    super.key,
    required this.name,
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final String name;
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: name,
      selected: selected,
      button: true,
      child: Tooltip(
        message: name,
        excludeFromSemantics: true,
        child: InkResponse(
          onTap: onTap,
          radius: 28,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.transparent,
                width: 2.5,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _PatternChoice extends StatelessWidget {
  const _PatternChoice({
    required this.look,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final CounterLook look;
  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      container: true,
      label: name,
      selected: selected,
      button: true,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          // Stretched, or the swatch, which has nothing inside it to give it
          // a width, collapses to a sliver.
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected
                      ? theme.colorScheme.onSurface
                      : Colors.transparent,
                  width: 2.5,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
              ),
              child: LookBox(look: look, radius: 12),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: selected
                  ? theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    )
                  : theme.textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// Mixes any colour: hue, saturation and brightness on sliders, or a hex
/// code typed in. Null if cancelled.
Future<Color?> showColorPicker(
  BuildContext context, {
  required Color initial,
}) => showDialog<Color>(
  context: context,
  builder: (_) => _ColorPicker(initial: initial),
);

class _ColorPicker extends StatefulWidget {
  const _ColorPicker({required this.initial});

  final Color initial;

  @override
  State<_ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<_ColorPicker> {
  late HSVColor _hsv = HSVColor.fromColor(widget.initial);
  late final _hex = TextEditingController(text: hexOf(widget.initial));

  Color get _color => _hsv.toColor();

  @override
  void dispose() {
    _hex.dispose();
    super.dispose();
  }

  /// From a slider: the hex field follows.
  void _slide(HSVColor hsv) => setState(() {
    _hsv = hsv;
    _hex.text = hexOf(hsv.toColor());
  });

  /// From the hex field: the sliders follow once it's a whole code.
  void _typed(String text) {
    final color = parseHex(text);
    if (color != null) setState(() => _hsv = HSVColor.fromColor(color));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final color = _color;
    final ink = inkOn(color);
    return AlertDialog(
      title: Text(l.customColor),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LookBox(
              look: plainLook(color),
              radius: 16,
              height: 72,
              width: double.infinity,
              child: Center(
                child: Text(
                  l.sampleCount,
                  style: CountersinkTheme.font(
                    CountersinkTheme.serif,
                    34,
                    560,
                    color: ink,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _ChannelSlider(
              label: l.hue,
              value: _hsv.hue,
              max: 360,
              colors: [
                for (var h = 0; h <= 360; h += 60)
                  HSVColor.fromAHSV(1, h.toDouble() % 360, 1, 1).toColor(),
              ],
              onChanged: (v) => _slide(_hsv.withHue(v.clamp(0, 359.99))),
            ),
            _ChannelSlider(
              label: l.saturation,
              value: _hsv.saturation,
              colors: [
                _hsv.withSaturation(0).toColor(),
                _hsv.withSaturation(1).toColor(),
              ],
              onChanged: (v) => _slide(_hsv.withSaturation(v)),
            ),
            _ChannelSlider(
              label: l.brightness,
              value: _hsv.value,
              colors: [Colors.black, _hsv.withValue(1).toColor()],
              onChanged: (v) => _slide(_hsv.withValue(v)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _hex,
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[#0-9a-fA-F]')),
                LengthLimitingTextInputFormatter(7),
              ],
              decoration: InputDecoration(labelText: l.hexCode),
              onChanged: _typed,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, color),
          child: Text(l.useColor),
        ),
      ],
    );
  }
}

/// A slider whose track shows what sliding it does.
class _ChannelSlider extends StatelessWidget {
  const _ChannelSlider({
    required this.label,
    required this.value,
    required this.colors,
    required this.onChanged,
    this.max = 1,
  });

  final String label;
  final double value;
  final double max;
  final List<Color> colors;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 14,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                gradient: LinearGradient(colors: colors),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.transparent,
                inactiveTrackColor: Colors.transparent,
                overlayColor: Colors.transparent,
                thumbColor: theme.colorScheme.onSurface,
                trackHeight: 14,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              child: Slider(
                value: value.clamp(0, max),
                max: max,
                semanticFormatterCallback: (v) =>
                    max == 1 ? '${(v * 100).round()}%' : '${v.round()}',
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
