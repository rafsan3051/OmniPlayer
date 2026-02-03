import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:omni_player/theme_engine.dart';
import 'package:google_fonts/google_fonts.dart'; // Added missing import

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  runApp(const ProviderScope(child: MyApp()));

  doWhenWindowReady(() {
    const initialSize = Size(1280, 800);
    appWindow.minSize = const Size(800, 600);
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSkin = ref.watch(themeNotifierProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OmniPlayer',
      theme: createTheme(currentSkin),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final skin = theme.extension<SkinThemeExtension>()!;

    return Stack(
      children: [
        // Background - supports Gradient or Solid Color
        Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            gradient: skin.backgroundGradient,
          ),
        ),

        // Content
        Column(
          children: [
            // Custom Title Bar
            WindowTitleBarBox(
              child: Row(
                children: [
                  Expanded(child: MoveWindow()),
                  const WindowButtons(),
                ],
              ),
            ),

            // Body
            Expanded(
              child: Row(
                children: [
                  // Sidebar
                  NavigationSidebar(skin: skin),

                  // Main Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: DashboardContent(skin: skin),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class NavigationSidebar extends StatelessWidget {
  final SkinThemeExtension skin;
  const NavigationSidebar({super.key, required this.skin});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: skin.isGlass
          ? skin.sidebarColor
          : skin.sidebarColor.withValues(alpha: 1), // Fixed deprecation
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'OMNI Player',
            style: GoogleFonts.righteous(fontSize: 24, color: skin.accentColor),
          ),
          const SizedBox(height: 40),
          _buildNavItem(Icons.home, 'Home', true),
          _buildNavItem(Icons.library_music, 'Library', false),
          _buildNavItem(Icons.playlist_play, 'Playlists', false),
          const Spacer(),
          const ThemeSelector(), // Temporary for testing
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? skin.accentColor : Colors.grey),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? skin.accentColor : Colors.grey,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class DashboardContent extends StatelessWidget {
  final SkinThemeExtension skin;
  const DashboardContent({super.key, required this.skin});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Library',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: skin.neonColor != Colors.transparent
                ? skin.neonColor
                : Theme.of(context).textTheme.bodyLarge?.color,
            shadows: skin.neonColor != Colors.transparent
                ? [Shadow(color: skin.neonColor, blurRadius: 10)]
                : null,
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: skin.cardColor,
                  borderRadius: skin.cardRadius,
                  border: skin.neonColor != Colors.transparent
                      ? Border.all(
                          color: skin.neonColor.withValues(
                            alpha: 0.5,
                          ), // Fixed deprecation
                          width: 1,
                        )
                      : null,
                  boxShadow: skin.neonColor != Colors.transparent
                      ? [
                          BoxShadow(
                            color: skin.neonColor.withValues(
                              alpha: 0.2,
                            ), // Fixed deprecation
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Icon(
                    Icons.music_note,
                    size: 40,
                    color: skin.accentColor,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ThemeSelector extends ConsumerWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 8,
      children: AppSkin.values.map((skin) {
        return GestureDetector(
          onTap: () => ref.read(themeNotifierProvider.notifier).setSkin(skin),
          child: CircleAvatar(backgroundColor: _getSkinColor(skin), radius: 12),
        );
      }).toList(),
    );
  }

  Color _getSkinColor(AppSkin skin) {
    switch (skin) {
      case AppSkin.fire:
        return Colors.orange;
      case AppSkin.neon:
        return Colors.red;
      case AppSkin.clean:
        return Colors.blue;
      case AppSkin.glass:
        return Colors.purple;
      case AppSkin.cp9:
        return const Color(0xFF6200EA); // Added const
      case AppSkin.billie:
        return const Color(0xFF00E676); // Added const
      case AppSkin.deepOrange:
        return const Color(0xFFFF5722); // Added const
      case AppSkin.tealGlass:
        return const Color(0xFF00BFA5); // Added const
      case AppSkin.blueCard:
        return const Color(0xFF2979FF); // Added const
      case AppSkin.frostedGlass:
        return Colors.white;
      case AppSkin.darkSidebar:
        return const Color(0xFFD7A788); // Added const
      case AppSkin.ultraLight:
        return const Color(0xFFF7F9FC); // Added const
    }
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = WindowButtonColors(
      iconNormal: Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black,
      mouseOver: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
      mouseDown: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
      iconMouseOver: Theme.of(context).colorScheme.primary,
      iconMouseDown: Theme.of(context).colorScheme.primary,
    );
    return Row(
      children: [
        MinimizeWindowButton(colors: colors),
        MaximizeWindowButton(colors: colors),
        CloseWindowButton(colors: colors),
      ],
    );
  }
}
