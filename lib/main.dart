import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/app_state_provider.dart';
import 'providers/player_provider.dart';
import 'providers/settings_provider.dart';
import 'services/music_service.dart';
// import 'services/youtube_service.dart'; // Using via MusicService or exported elsewhere
import 'package:media_kit_video/media_kit_video.dart';
import 'providers/video_player_provider.dart';
import 'providers/favorites_provider.dart' as fav;
import 'screens/settings_screen.dart';
import 'services/download_service.dart';

// Widgets
import 'widgets/animated_logo.dart';
import 'widgets/auth_dialog.dart';
import 'widgets/mode_switcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  runApp(const ProviderScope(child: MyApp()));

  doWhenWindowReady(() {
    const initialSize = Size(1280, 800);
    appWindow.minSize = const Size(1000, 700);
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OmniPlayer',
      theme: _getTheme(settings.theme),
      home: const MainScreen(),
    );
  }

  ThemeData _getTheme(String themeName) {
    switch (themeName) {
      case 'light':
        return ThemeData.light().copyWith(
          scaffoldBackgroundColor: Colors.white,
          textTheme: GoogleFonts.interTextTheme(),
        );
      case 'dark':
        return ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF121212),
          textTheme: GoogleFonts.interTextTheme(),
        );
      case 'soundwave':
      default:
        return ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF09090F),
          textTheme: GoogleFonts.interTextTheme(),
        );
    }
  }
}

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final playerState = ref.watch(playerProvider);
    final authState = ref.watch(authProvider);

    // Theme Colors
    const bgDark = Color(0xFF09090F);
    const cardDark = Color(0xFF14141E);
    const accentRed = Color(0xFFFF003C);
    const textGrey = Color(0xFF888899);

    return Scaffold(
      backgroundColor: bgDark,
      body: Column(
        children: [
          // Custom Title Bar
          WindowTitleBarBox(
            child: Container(
              color: bgDark,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  AnimatedLogo(
                    isPlaying: playerState.isPlaying,
                    accentColor: accentRed,
                  ),
                  const SizedBox(width: 20),
                  const ModeSwitcher(),
                  Expanded(child: MoveWindow()),
                  const WindowButtons(),
                ],
              ),
            ),
          ),

          // Main Body (3 Columns)
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Responsive layout
                final bool isCompact = constraints.maxWidth < 1200;

                return Row(
                  children: [
                    // 1. Left Sidebar
                    Container(
                      width: isCompact ? 200 : 240,
                      color: bgDark,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Local',
                                style: GoogleFonts.inter(
                                  color: textGrey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildSidebarItem(
                                Icons.folder_open,
                                'Open Audio',
                                false,
                                Colors.white,
                                onTap: () => ref
                                    .read(playerProvider.notifier)
                                    .playFile(),
                              ),
                              _buildSidebarItem(
                                Icons.video_file_outlined,
                                'Open Video',
                                false,
                                Colors.white,
                                onTap: () async {
                                  final result = await FilePicker.platform
                                      .pickFiles(type: FileType.video);
                                  if (result != null &&
                                      result.files.single.path != null) {
                                    ref
                                        .read(videoPlayerProvider.notifier)
                                        .playLocalVideo(
                                            result.files.single.path!,
                                            result.files.single.name);
                                    ref
                                        .read(appStateProvider.notifier)
                                        .setMode(AppMode.video);
                                  }
                                },
                              ),
                              const SizedBox(height: 30),
                              Text(
                                'Recommended',
                                style: GoogleFonts.inter(
                                  color: textGrey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildSidebarItem(
                                Icons.check_circle_outline,
                                'For you',
                                appState.selectedCategory == 'For you',
                                accentRed,
                                onTap: () => ref
                                    .read(appStateProvider.notifier)
                                    .setSelectedCategory('For you'),
                              ),
                              _buildSidebarItem(
                                Icons.library_music_outlined,
                                'Library',
                                appState.selectedCategory == 'Library',
                                accentRed,
                                onTap: () => ref
                                    .read(appStateProvider.notifier)
                                    .setSelectedCategory('Library'),
                              ),
                              _buildSidebarItem(
                                Icons.wifi_tethering,
                                'Stream',
                                appState.selectedCategory == 'Stream',
                                accentRed,
                                onTap: () => ref
                                    .read(appStateProvider.notifier)
                                    .setSelectedCategory('Stream'),
                              ),
                              const SizedBox(height: 30),
                              Text(
                                'My music',
                                style: GoogleFonts.inter(
                                  color: textGrey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildSidebarItem(
                                Icons.favorite_border,
                                'Liked Track',
                                appState.selectedCategory == 'Liked Track',
                                accentRed,
                                onTap: () => ref
                                    .read(appStateProvider.notifier)
                                    .setSelectedCategory('Liked Track'),
                              ),
                              _buildSidebarItem(
                                Icons.album_outlined,
                                'Albums',
                                appState.selectedCategory == 'Albums',
                                accentRed,
                                onTap: () => ref
                                    .read(appStateProvider.notifier)
                                    .setSelectedCategory('Albums'),
                              ),
                              _buildSidebarItem(
                                Icons.person_outline,
                                'Artist',
                                appState.selectedCategory == 'Artist',
                                accentRed,
                                onTap: () => ref
                                    .read(appStateProvider.notifier)
                                    .setSelectedCategory('Artist'),
                              ),
                              _buildSidebarItem(
                                Icons.history,
                                'History',
                                appState.selectedCategory == 'History',
                                accentRed,
                                onTap: () => ref
                                    .read(appStateProvider.notifier)
                                    .setSelectedCategory('History'),
                              ),
                              _buildSidebarItem(
                                Icons.download_done_outlined,
                                'Downloads',
                                appState.selectedCategory == 'Downloads',
                                accentRed,
                                onTap: () => ref
                                    .read(appStateProvider.notifier)
                                    .setSelectedCategory('Downloads'),
                              ),
                              const SizedBox(height: 30),
                              _buildSidebarItem(
                                Icons.settings_outlined,
                                'Settings',
                                false,
                                Colors.white,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SettingsScreen()),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 2. Main Content
                    Expanded(
                      flex: 3,
                      child: Container(
                        margin: const EdgeInsets.only(
                          top: 10,
                          bottom: 10,
                          right: 10,
                        ),
                        decoration: BoxDecoration(
                          color: cardDark,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: _buildMainContent(
                            context,
                            ref,
                            appState,
                            playerState,
                            authState,
                            bgDark,
                            accentRed,
                            textGrey,
                          ),
                        ),
                      ),
                    ),

                    // 3. Right Sidebar (hide on compact)
                    if (!isCompact)
                      Container(
                        width: 260,
                        color: bgDark,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildSectionHeader(
                                  'Most Popular',
                                  accentRed,
                                ),
                                const SizedBox(height: 15),
                                _buildAvatarRow(5, 20),
                                const SizedBox(height: 30),
                                _buildSectionHeader('Top & Viral', accentRed),
                                const SizedBox(height: 15),
                                _buildAvatarRow(5, 30),
                                const SizedBox(height: 30),
                                _buildSectionHeader(
                                  'Upcoming Events',
                                  accentRed,
                                ),
                                const SizedBox(height: 15),
                                _buildAvatarRow(5, 40),
                                const SizedBox(height: 30),
                                Text(
                                  "Live Lyric's",
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Remember The Day When You\nEmbraced Of Tears Of Thoughts?\nYou Called Allah With Patience\nHoping For Mercy To Take Place",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    color: textGrey,
                                    height: 1.5,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          // Bottom Player Bar
          _buildPlayerBar(
            context,
            ref,
            playerState,
            bgDark,
            accentRed,
            textGrey,
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    WidgetRef ref,
    AppState appState,
    PlayerStateModel playerState,
    AuthState authState,
    Color bgDark,
    Color accentRed,
    Color textGrey,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Search & Profile
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 40,
                  decoration: BoxDecoration(
                    color: bgDark,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: textGrey, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          style: GoogleFonts.inter(color: Colors.white),
                          onSubmitted: (value) async {
                            if (value.isNotEmpty) {
                              final musicService = MusicService();
                              final results =
                                  await musicService.searchMusic(value);
                              if (results.isNotEmpty) {
                                if (appState.mode == AppMode.music) {
                                  ref
                                      .read(playerProvider.notifier)
                                      .playYouTubeTrack(results.first);
                                } else {
                                  ref
                                      .read(videoPlayerProvider.notifier)
                                      .playVideo(results.first);
                                }
                              }
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Search music or video...',
                            hintStyle: GoogleFonts.inter(color: textGrey),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Icon(Icons.mic_none, color: textGrey, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              InkWell(
                onTap: () {
                  if (!authState.isAuthenticated) {
                    showDialog(
                      context: context,
                      builder: (context) => const AuthDialog(),
                    );
                  }
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: accentRed,
                      backgroundImage: authState.user?.photoUrl != null
                          ? NetworkImage(authState.user!.photoUrl!)
                          : null,
                      child: authState.user?.photoUrl == null
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      authState.isAuthenticated
                          ? 'Hey, ${authState.user?.displayName ?? 'User'}'
                          : 'Sign In',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.notifications_none, color: Colors.white),
            ],
          ),
          const SizedBox(height: 30),

          // Content based on category and mode
          Expanded(
            child: _buildCategoryContent(
              context,
              ref,
              appState,
              playerState,
              authState,
              bgDark,
              accentRed,
              textGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryContent(
    BuildContext context,
    WidgetRef ref,
    AppState appState,
    PlayerStateModel playerState,
    AuthState authState,
    Color bgDark,
    Color accentRed,
    Color textGrey,
  ) {
    switch (appState.selectedCategory) {
      case 'For you':
        return appState.mode == AppMode.music
            ? _buildMusicContent(
                context, ref, playerState, bgDark, accentRed, textGrey)
            : _buildVideoContent(
                context, ref, playerState, bgDark, accentRed, textGrey);
      case 'Library':
        return _buildPlaceholderContent(
            'Library', Icons.library_music_outlined, textGrey);
      case 'Stream':
        return _buildPlaceholderContent(
            'Live Streams', Icons.wifi_tethering, textGrey);
      case 'Liked Track':
      case 'Liked Tracks':
        return _buildFavoritesContent(context, ref, accentRed, textGrey);
      case 'Downloads':
        return _buildPlaceholderContent(
            'Downloads', Icons.download_done_outlined, textGrey);
      default:
        return _buildPlaceholderContent(
            appState.selectedCategory, Icons.folder_open, textGrey);
    }
  }

  Widget _buildPlaceholderContent(String title, IconData icon, Color textGrey) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: textGrey.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming soon to OmniPlayer',
            style: GoogleFonts.inter(color: textGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesContent(
      BuildContext context, WidgetRef ref, Color accentRed, Color textGrey) {
    final favorites = ref.watch(fav.favoritesProvider);
    final tracks = favorites.tracks;

    if (tracks.isEmpty) {
      return _buildPlaceholderContent(
          'No Liked Tracks', Icons.favorite_border, textGrey);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Your Favorites', accentRed),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: tracks.length,
            itemBuilder: (context, index) {
              final track = tracks[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: track.albumArt != null
                      ? Image.network(
                          track.albumArt!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            color: Colors.grey[900],
                            width: 50,
                            height: 50,
                            child: const Icon(Icons.music_note,
                                color: Colors.white),
                          ),
                        )
                      : Container(
                          color: Colors.grey[900],
                          width: 50,
                          height: 50,
                          child:
                              const Icon(Icons.music_note, color: Colors.white),
                        ),
                ),
                title: Text(track.title,
                    style: const TextStyle(color: Colors.white)),
                subtitle: Text(track.artist, style: TextStyle(color: textGrey)),
                trailing: IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: () {
                    ref
                        .read(fav.favoritesProvider.notifier)
                        .toggleFavorite(track);
                  },
                ),
                onTap: () {
                  // Play track logic (if possible, convert favorites.Track to VideoMetadata)
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMusicContent(
    BuildContext context,
    WidgetRef ref,
    PlayerStateModel playerState,
    Color bgDark,
    Color accentRed,
    Color textGrey,
  ) {
    final currentTrack = playerState.currentTrack;
    return Column(
      children: [
        // Featured Banner
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: NetworkImage(
                currentTrack?.thumbnailUrl ??
                    'https://images.unsplash.com/photo-1496661415325-ef852f9e8e7c?q=80&w=2021&auto=format&fit=crop',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.8),
                  Colors.transparent,
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  currentTrack?.title ?? 'Ready to Play',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentTrack?.author ?? 'Search for music to start streaming',
                  style: GoogleFonts.inter(color: textGrey),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.headphones, color: textGrey, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      'Ready to Stream',
                      style: GoogleFonts.inter(color: textGrey, fontSize: 12),
                    ),
                    const SizedBox(width: 20),
                    if (currentTrack != null)
                      IconButton(
                        icon: const Icon(Icons.download_rounded,
                            color: Colors.white70, size: 20),
                        onPressed: () {
                          final downloadService = DownloadService();
                          downloadService.downloadTrack(currentTrack);
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),

        // Song List
        Expanded(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: bgDark,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 30,
                      child: Text(
                        'song',
                        style: GoogleFonts.inter(
                          color: textGrey,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        'SONG',
                        style: GoogleFonts.inter(
                          color: textGrey,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'ARTIST/ALBUM',
                        style: GoogleFonts.inter(
                          color: textGrey,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      'TIME',
                      style: GoogleFonts.inter(
                        color: textGrey,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // List
              Expanded(
                child: ListView.builder(
                  itemCount: 8,
                  itemBuilder: (context, index) {
                    final isSelected = index == 0;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1E1E28)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(
                                color: accentRed.withValues(alpha: 0.5))
                            : null,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 30,
                            child: Text(
                              '${index + 1}',
                              style: GoogleFonts.inter(color: textGrey),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.favorite_border,
                                  color: textGrey,
                                  size: 16,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    isSelected
                                        ? 'Farhat al amr'
                                        : 'Song Title $index',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Artist Name',
                              style: GoogleFonts.inter(color: textGrey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '3:45',
                            style: GoogleFonts.inter(color: textGrey),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Waveform
              SizedBox(
                height: 40,
                child: CustomPaint(
                  painter: WaveformPainter(color: accentRed),
                  child: Container(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVideoContent(
    BuildContext context,
    WidgetRef ref,
    PlayerStateModel playerState,
    Color bgDark,
    Color accentRed,
    Color textGrey,
  ) {
    final videoState = ref.watch(videoPlayerProvider);

    return Column(
      children: [
        // Video Player Container
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 20,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Video(controller: videoState.controller),
                  if (videoState.isBuffering)
                    const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFFFF003C)),
                    ),
                  if (videoState.currentVideo == null)
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.video_library, color: textGrey, size: 64),
                          const SizedBox(height: 20),
                          Text(
                            'Search for a video to start watching',
                            style: GoogleFonts.inter(color: textGrey),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // Video info
        if (videoState.currentVideo != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        videoState.currentVideo!.title,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        videoState.currentVideo!.author,
                        style: GoogleFonts.inter(color: textGrey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.download_rounded,
                      color: Colors.white70, size: 28),
                  onPressed: () {
                    final downloadService = DownloadService();
                    downloadService.downloadVideo(videoState.currentVideo!);
                  },
                ),
                IconButton(
                  icon: Icon(
                    videoState.isPlaying
                        ? Icons.pause_circle
                        : Icons.play_circle,
                    color: accentRed,
                    size: 48,
                  ),
                  onPressed: () =>
                      ref.read(videoPlayerProvider.notifier).playOrPause(),
                ),
              ],
            ),
          ),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPlayerBar(
    BuildContext context,
    WidgetRef ref,
    PlayerStateModel playerState,
    Color bgDark,
    Color accentRed,
    Color textGrey,
  ) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: bgDark,
        border: const Border(top: BorderSide(color: Colors.white10)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              image: DecorationImage(
                image: NetworkImage(
                  playerState.currentTrack?.thumbnailUrl ??
                      'https://images.unsplash.com/photo-1496661415325-ef852f9e8e7c?q=80&w=2021&auto=format&fit=crop',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  playerState.currentTrack?.title ?? 'No Track Playing',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  playerState.currentTrack?.author ?? '',
                  style: GoogleFonts.inter(color: textGrey, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (playerState.currentTrack != null)
            Consumer(
              builder: (context, ref, child) {
                final favorites = ref.watch(fav.favoritesProvider);
                final isFav =
                    favorites.isFavorite(playerState.currentTrack!.id);
                return IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? accentRed : textGrey,
                    size: 20,
                  ),
                  onPressed: () {
                    final track = fav.Track(
                      id: playerState.currentTrack!.id,
                      title: playerState.currentTrack!.title,
                      artist: playerState.currentTrack!.author,
                      albumArt: playerState.currentTrack!.thumbnailUrl,
                    );
                    ref
                        .read(fav.favoritesProvider.notifier)
                        .toggleFavorite(track);
                  },
                );
              },
            ),
          const SizedBox(width: 20),
          Icon(Icons.headphones, color: textGrey, size: 20),
          const SizedBox(width: 20),
          const Icon(Icons.skip_previous, color: Colors.white),
          const SizedBox(width: 20),
          InkWell(
            onTap: () {
              ref.read(playerProvider.notifier).playOrPause();
            },
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: accentRed,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: accentRed.withValues(alpha: 0.4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 20),
          IconButton(
            icon: const Icon(Icons.skip_next, color: Colors.white),
            onPressed: () => ref.read(playerProvider.notifier).skipNext(),
          ),
          const SizedBox(width: 20),
          Icon(Icons.shuffle, color: textGrey, size: 20),
          const SizedBox(width: 10),
          Icon(Icons.tune, color: textGrey, size: 20),
          const Spacer(),
          Icon(Icons.volume_up, color: textGrey),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                activeTrackColor: accentRed,
                inactiveTrackColor: textGrey.withValues(alpha: 0.3),
                thumbColor: Colors.white,
              ),
              child: Slider(
                value: playerState.volume,
                min: 0,
                max: 100,
                onChanged: (value) {
                  ref.read(playerProvider.notifier).setVolume(value);
                },
              ),
            ),
          ),
          const SizedBox(width: 20),
          Icon(Icons.more_horiz, color: textGrey),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    IconData icon,
    String label,
    bool isSelected,
    Color accentColor, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? accentColor : Colors.grey, size: 20),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  color: isSelected ? accentColor : Colors.grey,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color accent) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        Text(
          'View All',
          style: GoogleFonts.inter(color: accent, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildAvatarRow(int count, int startIndex) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          count,
          (index) => Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(
                'https://i.pravatar.cc/150?img=${startIndex + index}',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = WindowButtonColors(
      iconNormal: Colors.white,
      mouseOver: const Color(0xFFFF003C).withValues(alpha: 0.2),
      mouseDown: const Color(0xFFFF003C).withValues(alpha: 0.4),
      iconMouseOver: const Color(0xFFFF003C),
      iconMouseDown: const Color(0xFFFF003C),
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

class WaveformPainter extends CustomPainter {
  final Color color;
  WaveformPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final paint2 = Paint()
      ..color = Colors.cyan.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    final path2 = Path();

    path.moveTo(0, size.height / 2);
    path2.moveTo(0, size.height / 2);

    for (double i = 0; i < size.width; i += 10) {
      path.quadraticBezierTo(
        i + 5,
        size.height / 2 + (i % 20 == 0 ? 10 : -10),
        i + 10,
        size.height / 2,
      );
      path2.quadraticBezierTo(
        i + 5,
        size.height / 2 + (i % 20 == 0 ? -8 : 8),
        i + 10,
        size.height / 2,
      );
    }

    canvas.drawPath(path, paint);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
