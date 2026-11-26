import 'package:flutter/material.dart';

/// Countersink's look: the SuperDaveLab family, led by its clay.
///
/// Every app in the family shares one look: Fraunces for titles and the
/// numbers that matter, Figtree for text, warm paper, cards with a hairline
/// border. The colours here are the family's own tokens (the cream, ink and
/// clay of superdavelab.com and Ebb's "Tide"); Countersink puts the clay in
/// front where Nexpill uses teal and Ebb uses navy.
///
/// Fonts are bundled (assets/fonts, SIL OFL). Never fetch them at runtime:
/// Countersink has no network, by design.

/// The handful of colours a look is built from.
class CountersinkPalette {
  const CountersinkPalette({
    required this.name,
    required this.primary,
    required this.onPrimary,
    required this.primaryInk,
    required this.background,
    required this.card,
    required this.ink,
    required this.muted,
    required this.line,
    required this.error,
  });

  final String name;

  /// Filled buttons and the action button.
  final Color primary;
  final Color onPrimary;

  /// The accent where it is text or an icon on the paper: a deeper clay in
  /// the light look, so small words stay readable.
  final Color primaryInk;
  final Color background;

  /// Raised surfaces: cards, sheets, dialogs.
  final Color card;

  /// Body text.
  final Color ink;

  /// Secondary text and icons.
  final Color muted;

  /// Hairlines: card borders and dividers.
  final Color line;
  final Color error;

  /// Clay on cream paper.
  static const clay = CountersinkPalette(
    name: 'Clay',
    primary: Color(0xFFC4613F),
    onPrimary: Color(0xFFFFFFFF),
    primaryInk: Color(0xFFA84F2F),
    background: Color(0xFFF5F1EA),
    card: Color(0xFFFFFCF7),
    ink: Color(0xFF14232E),
    muted: Color(0xFF5F6D75),
    line: Color(0xFFE4DCCF),
    error: Color(0xFFB3261E),
  );

  /// The dark twin sits on true black: nothing lit where there's nothing
  /// to show, which is easier on screens that light each dot themselves and
  /// lets a counter's colour stand out.
  static const clayDark = CountersinkPalette(
    name: 'Clay',
    primary: Color(0xFFE48D6D),
    onPrimary: Color(0xFF2B120A),
    primaryInk: Color(0xFFE48D6D),
    background: Color(0xFF000000),
    card: Color(0xFF10171A),
    ink: Color(0xFFE8EEF0),
    muted: Color(0xFF93A3A9),
    line: Color(0xFF222D31),
    error: Color(0xFFF2B8B5),
  );
}

/// A light palette and its dark twin.
typedef CountersinkLook = ({CountersinkPalette light, CountersinkPalette dark});

/// Which of a look's palettes to wear: light, dark, or whichever the phone
/// is set to. Chosen in Settings, loaded from Preferences at start.
final themeChoice = ValueNotifier<ThemeMode>(ThemeMode.system);

/// The family's five: clay, teal, navy, lavender, green. New counters take
/// these in turn, and the editor offers them for a one-tap choice.
const counterColors = [
  Color(0xFFC4613F),
  Color(0xFF1A8783),
  Color(0xFF14344B),
  Color(0xFFA09EB9),
  Color(0xFF196741),
];

/// Every colour offered by name: the family's five, then more in the same
/// earthy register. Any other colour can be mixed by hand.
const counterPalette = [
  ...counterColors,
  Color(0xFF8C3B2E), // brick
  Color(0xFFC28A2C), // ochre
  Color(0xFFD9B98A), // sand
  Color(0xFF6B7A3A), // olive
  Color(0xFF8FA58B), // sage
  Color(0xFF2F5A45), // moss
  Color(0xFF5F6D75), // slate
  Color(0xFF3F5568), // storm
  Color(0xFF6FA3C0), // sky
  Color(0xFF6B3F5B), // plum
  Color(0xFFC98A8A), // rose
  Color(0xFF5A4034), // cocoa
  Color(0xFF26323A), // charcoal
  Color(0xFF4B3A63), // aubergine
  Color(0xFFE9DFCF), // linen
];

/// White or the family's dark ink, whichever reads better on [fill]. Worked
/// out from the counter's own colour, never from the phone's light or dark
/// setting, so a card stays readable in both.
Color inkOn(Color fill) {
  const dark = Color(0xFF14232E);
  final l = fill.computeLuminance();
  final withWhite = 1.05 / (l + 0.05);
  final withDark = (l + 0.05) / (dark.computeLuminance() + 0.05);
  return withWhite >= withDark ? Colors.white : dark;
}

class CountersinkTheme {
  /// Every look the app can wear. One so far; add a set here to offer
  /// another.
  static const List<CountersinkLook> looks = [
    (light: CountersinkPalette.clay, dark: CountersinkPalette.clayDark),
  ];

  static ThemeData light([CountersinkLook? look]) =>
      _build((look ?? looks.first).light, Brightness.light);
  static ThemeData dark([CountersinkLook? look]) =>
      _build((look ?? looks.first).dark, Brightness.dark);

  static const serif = 'Fraunces';
  static const sans = 'Figtree';

  /// The bundled fonts are variable: Flutter needs the weight axis set
  /// explicitly, not just [FontWeight].
  static TextStyle font(
    String family,
    double size,
    double weight, {
    double? height,
    double? spacing,
    Color? color,
  }) => TextStyle(
    fontFamily: family,
    fontSize: size,
    fontWeight: FontWeight.values[((weight / 100).round() - 1).clamp(0, 8)],
    fontVariations: [
      FontVariation('wght', weight),
      if (family == serif) const FontVariation('SOFT', 50),
      if (family == serif) FontVariation('opsz', size.clamp(9, 144)),
    ],
    height: height,
    letterSpacing: spacing,
    color: color,
  );

  static ThemeData _build(CountersinkPalette p, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: p.primary,
      onPrimary: p.onPrimary,
      primaryContainer: Color.alphaBlend(
        p.primary.withValues(alpha: 0.14),
        p.card,
      ),
      onPrimaryContainer: p.primaryInk,
      secondary: p.primary,
      onSecondary: p.onPrimary,
      secondaryContainer: Color.alphaBlend(
        p.primary.withValues(alpha: 0.10),
        p.card,
      ),
      onSecondaryContainer: p.primaryInk,
      error: p.error,
      onError: brightness == Brightness.light ? Colors.white : Colors.black,
      surface: p.background,
      onSurface: p.ink,
      onSurfaceVariant: p.muted,
      surfaceContainerLowest: p.card,
      surfaceContainerLow: p.card,
      surfaceContainer: p.card,
      surfaceContainerHigh: p.card,
      surfaceContainerHighest: p.line,
      outline: p.muted,
      outlineVariant: p.line,
    );

    final text = TextTheme(
      displaySmall: font(serif, 34, 560, height: 1.1, color: p.ink),
      headlineMedium: font(serif, 28, 540, height: 1.15, color: p.ink),
      headlineSmall: font(serif, 24, 540, height: 1.2, color: p.ink),
      titleLarge: font(serif, 21, 580, height: 1.25, color: p.ink),
      titleMedium: font(sans, 16.5, 640, height: 1.3, color: p.ink),
      titleSmall: font(sans, 14, 650, height: 1.3, spacing: 0.2, color: p.ink),
      bodyLarge: font(sans, 16.5, 430, height: 1.45, color: p.ink),
      bodyMedium: font(sans, 15, 430, height: 1.45, color: p.ink),
      bodySmall: font(sans, 13, 450, height: 1.4, color: p.muted),
      labelLarge: font(sans, 15.5, 620, spacing: 0.1),
      labelMedium: font(sans, 13, 600, spacing: 0.2, color: p.muted),
      labelSmall: font(sans, 11.5, 650, spacing: 0.6, color: p.muted),
    );

    final rounded = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      textTheme: text,
      fontFamily: sans,
      scaffoldBackgroundColor: p.background,
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        foregroundColor: p.ink,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
        titleTextStyle: font(serif, 23, 580, color: p.ink),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: p.primaryInk,
        unselectedLabelColor: p.muted,
        indicatorColor: p.primaryInk,
        dividerColor: p.line,
        labelStyle: font(sans, 15, 650, spacing: 0.1),
        unselectedLabelStyle: font(sans, 15, 560, spacing: 0.1),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: p.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: p.line),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: text.labelLarge,
          side: BorderSide(color: p.line),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.primaryInk,
          textStyle: text.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: p.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: p.line),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.card,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        // Swiped away to either side, the way a floating bar invites.
        dismissDirection: DismissDirection.horizontal,
        backgroundColor: p.ink,
        contentTextStyle: font(sans, 14.5, 500, color: p.background),
        shape: rounded,
      ),
      dividerTheme: DividerThemeData(color: p.line, thickness: 1, space: 1),
      listTileTheme: ListTileThemeData(
        iconColor: p.muted,
        titleTextStyle: text.bodyLarge,
        subtitleTextStyle: text.bodySmall,
      ),
      switchTheme: const SwitchThemeData(
        trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.primary,
        foregroundColor: p.onPrimary,
        elevation: 1,
        shape: rounded,
      ),
    );
  }
}
