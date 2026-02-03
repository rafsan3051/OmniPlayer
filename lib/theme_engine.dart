import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:google_fonts/google_fonts.dart';

part 'theme_engine.g.dart';

// -----------------------------------------------------------------------------
// Skin Theme Extension
// -----------------------------------------------------------------------------

@immutable
class SkinThemeExtension extends ThemeExtension<SkinThemeExtension> {
  final LinearGradient? backgroundGradient;
  final Color sidebarColor;
  final Color cardColor;
  final Color accentColor;
  final Color neonColor;
  final double glassOpacity;
  final BorderRadius cardRadius;
  final bool isGlass;

  const SkinThemeExtension({
    required this.sidebarColor,
    required this.cardColor,
    required this.accentColor,
    required this.neonColor,
    this.backgroundGradient,
    this.glassOpacity = 1.0,
    this.cardRadius = const BorderRadius.all(Radius.circular(12)),
    this.isGlass = false,
  });

  @override
  SkinThemeExtension copyWith({
    LinearGradient? backgroundGradient,
    Color? sidebarColor,
    Color? cardColor,
    Color? accentColor,
    Color? neonColor,
    double? glassOpacity,
    BorderRadius? cardRadius,
    bool? isGlass,
  }) {
    return SkinThemeExtension(
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
      sidebarColor: sidebarColor ?? this.sidebarColor,
      cardColor: cardColor ?? this.cardColor,
      accentColor: accentColor ?? this.accentColor,
      neonColor: neonColor ?? this.neonColor,
      glassOpacity: glassOpacity ?? this.glassOpacity,
      cardRadius: cardRadius ?? this.cardRadius,
      isGlass: isGlass ?? this.isGlass,
    );
  }

  @override
  SkinThemeExtension lerp(ThemeExtension<SkinThemeExtension>? other, double t) {
    if (other is! SkinThemeExtension) {
      return this;
    }
    return SkinThemeExtension(
      backgroundGradient: LinearGradient.lerp(
        backgroundGradient,
        other.backgroundGradient,
        t,
      ),
      sidebarColor: Color.lerp(sidebarColor, other.sidebarColor, t)!,
      cardColor: Color.lerp(cardColor, other.cardColor, t)!,
      accentColor: Color.lerp(accentColor, other.accentColor, t)!,
      neonColor: Color.lerp(neonColor, other.neonColor, t)!,
      glassOpacity: (glassOpacity + (other.glassOpacity - glassOpacity) * t),
      cardRadius: BorderRadius.lerp(cardRadius, other.cardRadius, t)!,
      isGlass: t < 0.5 ? isGlass : other.isGlass,
    );
  }
}

// -----------------------------------------------------------------------------
// App Skin Enum & Data
// -----------------------------------------------------------------------------

enum AppSkin {
  fire,
  neon,
  clean,
  glass,
  cp9,
  billie,
  deepOrange,
  tealGlass,
  blueCard,
  frostedGlass,
  darkSidebar,
  ultraLight,
}

ThemeData createTheme(AppSkin skin) {
  switch (skin) {
    case AppSkin.fire:
      return _buildFireTheme();
    case AppSkin.neon:
      return _buildNeonTheme();
    case AppSkin.clean:
      return _buildCleanTheme();
    case AppSkin.glass:
      return _buildGlassTheme();
    case AppSkin.cp9:
      return _buildCp9Theme();
    case AppSkin.billie:
      return _buildBillieTheme();
    case AppSkin.deepOrange:
      return _buildDeepOrangeTheme();
    case AppSkin.tealGlass:
      return _buildTealGlassTheme();
    case AppSkin.blueCard:
      return _buildBlueCardTheme();
    case AppSkin.frostedGlass:
      return _buildFrostedGlassTheme();
    case AppSkin.darkSidebar:
      return _buildDarkSidebarTheme();
    case AppSkin.ultraLight:
      return _buildUltraLightTheme();
  }
}

// --- Skin 1: Fire (Dark/Gold) ---
ThemeData _buildFireTheme() {
  const primary = Color(0xFFFFD700); // Gold
  const bg = Color(0xFF121212);
  const card = Color(0xFF1E1E1E);

  return ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(primary: primary, surface: bg),
    scaffoldBackgroundColor: bg,
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
    extensions: const <ThemeExtension<dynamic>>[
      SkinThemeExtension(
        sidebarColor: Color(0xFF181818),
        cardColor: card,
        accentColor: Colors.orangeAccent,
        neonColor: Colors.transparent,
        backgroundGradient: LinearGradient(
          colors: [Color(0xFF2C1008), Color(0xFF121212)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ],
  );
}

// --- Skin 2: Neon (Dark/Red/Glow) ---
ThemeData _buildNeonTheme() {
  const primary = Color(0xFFFF003C); // Neon Red
  const bg = Color(0xFF050505);

  return ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(primary: primary, surface: bg),
    scaffoldBackgroundColor: bg,
    textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme),
    extensions: const <ThemeExtension<dynamic>>[
      SkinThemeExtension(
        sidebarColor: Color(0xFF0A0A0A),
        cardColor: Color(0xFF141414),
        accentColor: Color(0xFF00FFEA), // Cyan accent
        neonColor: primary,
        cardRadius: BorderRadius.all(Radius.circular(4)), // Sharp tech look
      ),
    ],
  );
}

// --- Skin 3: Clean (Light/Blue/White) ---
ThemeData _buildCleanTheme() {
  const primary = Color(0xFF007AFF);
  const bg = Color(0xFFF5F5F7);

  return ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(primary: primary, surface: bg),
    scaffoldBackgroundColor: bg,
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
    extensions: const <ThemeExtension<dynamic>>[
      SkinThemeExtension(
        sidebarColor: Colors.white,
        cardColor: Colors.white,
        accentColor: Color(0xFF5856D6),
        neonColor: Colors.transparent,
        cardRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ],
  );
}

// --- Skin 4: Glass (Glassmorphism) ---
ThemeData _buildGlassTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: Colors.white,
      surface: Colors.black,
    ),
    scaffoldBackgroundColor: Colors.black, // Will be overlaid by gradient
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
    extensions: const <ThemeExtension<dynamic>>[
      SkinThemeExtension(
        sidebarColor: Color(0x1AFFFFFF), // White 10%
        cardColor: Color(0x33FFFFFF), // White 20%
        accentColor: Color(0xFFE0E0E0),
        neonColor: Colors.transparent,
        glassOpacity: 0.1,
        isGlass: true,
        backgroundGradient: LinearGradient(
          colors: [Color(0xFF4568DC), Color(0xFFB06AB3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ],
  );
}

// --- Skin 5: CP9 (Purple/Light) ---
ThemeData _buildCp9Theme() {
  const primary = Color(0xFF6200EA);
  const bg = Color(0xFFF3F0F7);

  return ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(primary: primary, surface: bg),
    scaffoldBackgroundColor: bg,
    textTheme: GoogleFonts.dmSansTextTheme(ThemeData.light().textTheme),
    extensions: const <ThemeExtension<dynamic>>[
      SkinThemeExtension(
        sidebarColor: Color(0xFF4A148C),
        cardColor: Colors.white,
        accentColor: Color(0xFFAA00FF),
        neonColor: Colors.transparent,
        cardRadius: BorderRadius.all(Radius.circular(20)),
      ),
    ],
  );
}

// --- Skin 6: Billie (Green/Black) ---
ThemeData _buildBillieTheme() {
  const primary = Color(0xFF00E676);
  const bg = Color(0xFF000000);

  return ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(primary: primary, surface: bg),
    scaffoldBackgroundColor: bg,
    textTheme: GoogleFonts.syneTextTheme(ThemeData.dark().textTheme),
    extensions: const <ThemeExtension<dynamic>>[
      SkinThemeExtension(
        sidebarColor: Color(0xFF121212),
        cardColor: Color(0xFF1E1E1E),
        accentColor: primary,
        neonColor: Color(0xFF69F0AE),
        cardRadius: BorderRadius.zero,
      ),
    ],
  );
}

// --- Skin 7: Deep Orange (Dark Blue/Grey) ---
ThemeData _buildDeepOrangeTheme() {
  const primary = Color(0xFFFF5722);
  const bg = Color(0xFF263238);

  return ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(primary: primary, surface: bg),
    scaffoldBackgroundColor: bg,
    textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme),
    extensions: const <ThemeExtension<dynamic>>[
      SkinThemeExtension(
        sidebarColor: Color(0xFF21272B),
        cardColor: Color(0xFF37474F),
        accentColor: Colors.deepOrangeAccent,
        neonColor: Colors.transparent,
        cardRadius: BorderRadius.all(Radius.circular(28)),
      ),
    ],
  );
}

// --- Skin 8: Teal Glass ---
ThemeData _buildTealGlassTheme() {
  const primary = Color(0xFF00BFA5);

  return ThemeData(
    useMaterial3: true,
    colorScheme:
        const ColorScheme.dark(primary: primary, surface: Colors.black),
    scaffoldBackgroundColor: Colors.black,
    textTheme: GoogleFonts.ralewayTextTheme(ThemeData.dark().textTheme),
    extensions: const <ThemeExtension<dynamic>>[
      SkinThemeExtension(
        sidebarColor: Color(0x1F004D40), // Teal tint
        cardColor: Color(0x3300695C),
        accentColor: Color(0xFF64FFDA),
        neonColor: primary,
        glassOpacity: 0.15,
        isGlass: true,
        backgroundGradient: LinearGradient(
          colors: [Color(0xFF004D40), Color(0xFF000000)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    ],
  );
}

// --- Skin 9: Blue Card (Dashboard) ---
ThemeData _buildBlueCardTheme() {
  const primary = Color(0xFF2979FF);
  const bg = Color(0xFFF5F7FA);

  return ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(primary: primary, surface: bg),
    scaffoldBackgroundColor: bg,
    textTheme: GoogleFonts.latoTextTheme(ThemeData.light().textTheme),
    extensions: const <ThemeExtension<dynamic>>[
      SkinThemeExtension(
        sidebarColor: Color(0xFF2962FF),
        cardColor: Colors.white,
        accentColor: Colors.white,
        neonColor: Colors.transparent,
        cardRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ],
  );
}

// --- Skin 10: Frosted Glass (Heavy Blur/White) ---
ThemeData _buildFrostedGlassTheme() {
  const primary = Color(0xFFFFFFFF);

  return ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      surface: Colors.black,
    ),
    scaffoldBackgroundColor:
        Colors.black, // Background handled by image/gradient
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
    extensions: const <ThemeExtension<dynamic>>[
      SkinThemeExtension(
        sidebarColor: Color(0x33FFFFFF),
        cardColor: Color(0x4DFFFFFF),
        accentColor: Colors.white,
        neonColor: Colors.transparent,
        glassOpacity: 0.3,
        isGlass: true,
        backgroundGradient: LinearGradient(
          colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)], // Purple Gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ],
  );
}

// --- Skin 11: Dark Sidebar (Modern Dark/Brown) ---
ThemeData _buildDarkSidebarTheme() {
  const primary = Color(0xFFD7A788); // Brown/Gold tint
  const bg = Color(0xFF1E1E1E);

  return ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(primary: primary, surface: bg),
    scaffoldBackgroundColor: bg,
    textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme),
    extensions: const <ThemeExtension<dynamic>>[
      SkinThemeExtension(
        sidebarColor: Color(0xFF141414), // Solid dark sidebar
        cardColor: Color(0xFF2C2C2C),
        accentColor: primary,
        neonColor: Colors.transparent,
        cardRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ],
  );
}

// --- Skin 12: Ultra Light (White/Blue/Marshmello) ---
ThemeData _buildUltraLightTheme() {
  const primary = Color(0xFF2962FF);
  const bg = Color(0xFFFFFFFF);

  return ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(primary: primary, surface: bg),
    scaffoldBackgroundColor: bg,
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
    extensions: const <ThemeExtension<dynamic>>[
      SkinThemeExtension(
        sidebarColor: Color(0xFFF7F9FC),
        cardColor: Colors.white,
        accentColor: Color(0xFF2979FF),
        neonColor: Colors.transparent,
        cardRadius: BorderRadius.all(Radius.circular(24)),
        backgroundGradient: LinearGradient(
          colors: [Colors.white, Color(0xFFF0F4F8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    ],
  );
}

class ThemeNotifier extends _$ThemeNotifier {
  @override
  AppSkin build() {
    return AppSkin.fire; // Default
  }

  void setSkin(AppSkin skin) {
    state = skin;
  }
}
