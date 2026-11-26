import 'package:flutter/material.dart';

import 'package:countersink/l10n/app_localizations.dart';
import 'package:countersink/models/counter.dart';
import 'package:countersink/ui/theme.dart';

/// How a counter's card is painted: its color, a second color it may blend
/// into, and a pattern drawn over both.
typedef CounterLook = ({Color color, Color? color2, CounterPattern pattern});

CounterLook lookOf(Counter counter) => (
  color: Color(counter.color),
  color2: counter.color2 == null ? null : Color(counter.color2!),
  pattern: counter.pattern,
);

/// One flat color and nothing else.
CounterLook plainLook(Color color) =>
    (color: color, color2: null, pattern: CounterPattern.none);

/// The blend from the first color to the second, corner to corner; null
/// for a card of one color.
Gradient? lookGradient(CounterLook look) => look.color2 == null
    ? null
    : LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [look.color, look.color2!],
      );

/// White or dark ink for words on [look], judged at the middle of a blend.
Color inkOnLook(CounterLook look) => inkOn(
  look.color2 == null ? look.color : Color.lerp(look.color, look.color2, 0.5)!,
);

/// A palette color's name, or the hex code of one mixed by hand: what a
/// screen reader says for a swatch, which is otherwise only a color.
String colorName(AppLocalizations l, Color color) {
  final names = [
    l.colorClay,
    l.colorTeal,
    l.colorNavy,
    l.colorLavender,
    l.colorGreen,
    l.colorBrick,
    l.colorOchre,
    l.colorSand,
    l.colorOlive,
    l.colorSage,
    l.colorMoss,
    l.colorSlate,
    l.colorStorm,
    l.colorSky,
    l.colorPlum,
    l.colorRose,
    l.colorCocoa,
    l.colorCharcoal,
    l.colorAubergine,
    l.colorLinen,
  ];
  final i = counterPalette.indexOf(color);
  return i < 0 ? hexOf(color) : names[i];
}

/// "#C4613F".
String hexOf(Color color) =>
    '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

/// "#C4613F" or "c4613f" as a color; null if it isn't six hex digits.
Color? parseHex(String text) {
  final m = RegExp(r'^#?([0-9a-fA-F]{6})$').firstMatch(text.trim());
  return m == null
      ? null
      : Color(0xFF000000 | int.parse(m.group(1)!, radix: 16));
}

String patternName(AppLocalizations l, CounterPattern pattern) =>
    switch (pattern) {
      CounterPattern.none => l.patternNone,
      CounterPattern.stripes => l.patternStripes,
      CounterPattern.dots => l.patternDots,
      CounterPattern.grid => l.patternGrid,
    };

/// Draws a pattern in faint [ink] over whatever is beneath it: quiet enough
/// that the number on top stays the thing you read.
class PatternPainter extends CustomPainter {
  const PatternPainter(this.pattern, this.ink);

  final CounterPattern pattern;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    switch (pattern) {
      case CounterPattern.none:
        return;
      case CounterPattern.stripes:
        final paint = Paint()
          ..color = ink.withValues(alpha: 0.10)
          ..strokeWidth = 6;
        for (var x = 0.0; x < size.width + size.height; x += 18) {
          canvas.drawLine(
            Offset(x, 0),
            Offset(x - size.height, size.height),
            paint,
          );
        }
      case CounterPattern.dots:
        final paint = Paint()..color = ink.withValues(alpha: 0.16);
        var odd = false;
        for (var y = 7.0; y < size.height; y += 14) {
          for (var x = odd ? 14.0 : 7.0; x < size.width; x += 14) {
            canvas.drawCircle(Offset(x, y), 2.2, paint);
          }
          odd = !odd;
        }
      case CounterPattern.grid:
        final paint = Paint()
          ..color = ink.withValues(alpha: 0.14)
          ..strokeWidth = 1.2;
        for (var x = 9.0; x < size.width; x += 18) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
        }
        for (var y = 9.0; y < size.height; y += 18) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
        }
    }
  }

  @override
  bool shouldRepaint(PatternPainter old) =>
      old.pattern != pattern || old.ink != ink;
}

/// A [look] painted as a box or a circle, for previews and swatches. The
/// counter card paints the same thing itself, so that it can ripple.
class LookBox extends StatelessWidget {
  const LookBox({
    super.key,
    required this.look,
    this.radius = 20,
    this.circle = false,
    this.width,
    this.height,
    this.child,
  });

  final CounterLook look;
  final double radius;
  final bool circle;
  final double? width;
  final double? height;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: look.color,
        gradient: lookGradient(look),
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(radius),
      ),
      child: CustomPaint(
        painter: PatternPainter(look.pattern, inkOnLook(look)),
        child: child,
      ),
    );
  }
}
