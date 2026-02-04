import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/app_state_provider.dart';
import 'providers/player_provider.dart';
import 'providers/settings_provider.dart';
import 'services/music_service.dart';
import 'services/youtube_service.dart';
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
                      Icon(Icons.search, color: textGrey, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          style: GoogleFonts.inter(
                              color: Colors.white, fontSize: 13),
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
                            hintText: 'Search...',
                            hintStyle: GoogleFonts.inter(
                                color: textGrey, fontSize: 13),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 15),
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
                      radius: 16,
                      backgroundColor: accentRed,
                      backgroundImage: authState.user?.photoUrl != null
                          ? NetworkImage(authState.user!.photoUrl!)
                          : null,
                      child: authState.user?.photoUrl == null
                          ? const Icon(Icons.person,
                              color: Colors.white, size: 18)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      authState.isAuthenticated
                          ? (authState.user?.displayName?.split(' ').first ??
                              'User')
                          : 'Sign In',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Main Scrollable Area
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Now Playing Section
                Consumer(
                  builder: (context, ref, child) {
                    final appState = ref.watch(appStateProvider);
                    final playerState = ref.watch(playerProvider);
                    final videoState = ref.watch(videoPlayerProvider);
                    final heroTrack = (appState.mode == AppMode.video
                            ? videoState.currentVideo
                            : playerState.currentTrack) ??
                        appState.heroTrack;

                    if (heroTrack != null) {
                      return _buildNowPlayingSection(
                          context,
                          ref,
                          heroTrack,
                          accentRed,
                          textGrey,
                          appState.mode == AppMode.video,
                          videoState,
                          appState.selectedCategory);
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 20),
                // Content based on category and mode
                _buildCategoryContent(
                  context,
                  ref,
                  appState,
                  playerState,
                  authState,
                  bgDark,
                  accentRed,
                  textGrey,
                ),
              ],
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
        return _buildLibraryContent(context, ref, accentRed, textGrey);
      case 'Stream':
        return _buildStreamContent(context, ref, appState, accentRed, textGrey);
      case 'Liked Track':
      case 'Liked Tracks':
        return _buildFavoritesContent(context, ref, accentRed, textGrey);
      case 'Downloads':
        return _buildDownloadsContent(context, ref, accentRed, textGrey);
      default:
        return _buildPlaceholderContent(
            appState.selectedCategory, Icons.folder_open, textGrey);
    }
  }

  Widget _buildStreamContent(
    BuildContext context,
    WidgetRef ref,
    AppState appState,
    Color accentRed,
    Color textGrey,
  ) {
    return Column(
      children: [
        _buildSectionHeader('Live Stream & Search', accentRed),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search for live streams or music...',
              hintStyle: TextStyle(color: textGrey),
              prefixIcon: Icon(Icons.search, color: textGrey),
              filled: true,
              fillColor: Colors.white12,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (query) {
              ref.read(appStateProvider.notifier).searchMusic(query);
            },
          ),
        ),
        const SizedBox(height: 20),
        if (appState.isSearching)
          const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF003C)))
        else if (appState.searchResults.isEmpty)
          Expanded(
              child: _buildPlaceholderContent(
                  'Explore YouTube', Icons.explore_outlined, textGrey))
        else
          Expanded(
            child: ListView.builder(
              itemCount: appState.searchResults.length,
              itemBuilder: (context, index) {
                final track = appState.searchResults[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      track.thumbnailUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(track.title,
                      style: const TextStyle(color: Colors.white)),
                  subtitle:
                      Text(track.author, style: TextStyle(color: textGrey)),
                  trailing: IconButton(
                    icon: const Icon(Icons.play_circle_fill,
                        color: Color(0xFFFF003C)),
                    onPressed: () {
                      ref.read(playerProvider.notifier).playYouTubeTrack(track);
                    },
                  ),
                  onTap: () {
                    ref.read(playerProvider.notifier).playYouTubeTrack(track);
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildLibraryContent(
      BuildContext context, WidgetRef ref, Color accentRed, Color textGrey) {
    // Show a mix of local files and recently played
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Your Library', accentRed),
        const SizedBox(height: 20),
        Expanded(
          child: ListView(
            children: [
              _buildLibraryItem(
                  'Local Audio', Icons.audio_file_outlined, textGrey, () async {
                await ref.read(playerProvider.notifier).playFile();
              }),
              _buildLibraryItem(
                  'Local Videos', Icons.video_file_outlined, textGrey, () {
                ref.read(videoPlayerProvider.notifier).playFile();
              }),
              const Divider(color: Colors.white10),
              _buildPlaceholderContent(
                  'Your library is growing', Icons.auto_awesome, textGrey),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLibraryItem(
      String title, IconData icon, Color textGrey, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: textGrey),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing:
          const Icon(Icons.arrow_forward_ios, color: Colors.white12, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildDownloadsContent(
      BuildContext context, WidgetRef ref, Color accentRed, Color textGrey) {
    final downloadedFiles = ref.watch(appStateProvider).downloadedFiles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Downloads', accentRed),
        const SizedBox(height: 20),
        if (downloadedFiles.isEmpty)
          Expanded(
            child: _buildPlaceholderContent(
                'No downloads yet', Icons.download_for_offline, textGrey),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: downloadedFiles.length,
              itemBuilder: (context, index) {
                final file = downloadedFiles[index];
                final fileName = file.path.split(Platform.pathSeparator).last;
                return ListTile(
                  leading: Icon(
                      fileName.endsWith('.mp4')
                          ? Icons.videocam
                          : Icons.music_note,
                      color: textGrey),
                  title: Text(fileName,
                      style: const TextStyle(color: Colors.white)),
                  trailing: IconButton(
                    icon: const Icon(Icons.play_circle_fill,
                        color: Color(0xFFFF003C)),
                    onPressed: () {
                      if (fileName.endsWith('.mp4')) {
                        ref
                            .read(videoPlayerProvider.notifier)
                            .playLocalVideo(file.path, fileName);
                      } else {
                        _playLocalFile(ref, file.path, fileName);
                      }
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Future<void> _playLocalFile(WidgetRef ref, String path, String title) async {
    // For simplicity, reuse the playFile logic or direct player access
    // But since we want the UI to update, we should ideally use the provider.
    // The player_provider.playFile picks a file, but we already have the path.
    // Let's assume we can play it directly via the player_provider's player.
    // Actually, I'll add a playAtPath method to player_provider.
    await ref.read(playerProvider.notifier).playLocalVideo(path, title);
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
    final appState = ref.watch(appStateProvider);
    final suggestions = appState.suggestedTracks;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Recommended for you', accentRed),
          const SizedBox(height: 20),
          if (appState.isSearching)
            const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF003C)))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final track = suggestions[index];
                return _buildDynamicTrackItem(
                    ref, track, index + 1, accentRed, textGrey);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildNowPlayingSection(
    BuildContext context,
    WidgetRef ref,
    VideoMetadata track,
    Color accentRed,
    Color textGrey,
    bool isVideoMode,
    VideoPlayerState videoState,
    String selectedCategory,
  ) {
    final isCurrentVideo =
        isVideoMode && videoState.currentVideo?.id == track.id;
    // Show video only if it's the current video AND we're not in For You tab.
    // If in For You, we show a "Watch" button to switch views.
    final showVideo = isCurrentVideo && selectedCategory != 'For you';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Now Playing', accentRed),
        const SizedBox(height: 20),
        Container(
          height: 280,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
            image: showVideo
                ? null
                : DecorationImage(
                    image: NetworkImage(track.thumbnailUrl),
                    fit: BoxFit.cover,
                  ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                if (showVideo) Video(controller: videoState.controller),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.9),
                        Colors.black.withValues(alpha: 0.4),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        track.author,
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              if (isVideoMode) {
                                ref
                                    .read(videoPlayerProvider.notifier)
                                    .playVideo(track);
                              } else {
                                ref
                                    .read(playerProvider.notifier)
                                    .playYouTubeTrack(track);
                              }
                            },
                            icon: Icon(isCurrentVideo
                                ? (videoState.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow)
                                : Icons.play_arrow),
                            label: Text(isCurrentVideo
                                ? (videoState.isPlaying ? 'Pause' : 'Resume')
                                : 'Play Now'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentRed,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                            ),
                          ),
                          if (isVideoMode && selectedCategory == 'For you') ...[
                            const SizedBox(width: 15),
                            OutlinedButton.icon(
                              onPressed: () {
                                ref
                                    .read(appStateProvider.notifier)
                                    .setSelectedCategory('Stream');
                                ref
                                    .read(videoPlayerProvider.notifier)
                                    .playVideo(track);
                              },
                              icon: const Icon(Icons.visibility, size: 18),
                              label: const Text('Watch'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(width: 15),
                          IconButton(
                            icon:
                                const Icon(Icons.download, color: Colors.white),
                            onPressed: () async {
                              final settings = ref.read(settingsProvider);
                              if (isVideoMode) {
                                await DownloadService().downloadVideo(track,
                                    customPath:
                                        settings.downloadLocation.isEmpty
                                            ? null
                                            : settings.downloadLocation);
                              } else {
                                await DownloadService().downloadTrack(track,
                                    customPath:
                                        settings.downloadLocation.isEmpty
                                            ? null
                                            : settings.downloadLocation);
                              }
                              ref
                                  .read(appStateProvider.notifier)
                                  .refreshDownloadedFiles(
                                      customPath:
                                          settings.downloadLocation.isEmpty
                                              ? null
                                              : settings.downloadLocation);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicTrackItem(
    WidgetRef ref,
    VideoMetadata track,
    int index,
    Color accentRed,
    Color textGrey,
  ) {
    return ListTile(
      leading: SizedBox(
        width: 60,
        child: Row(
          children: [
            Text('$index', style: TextStyle(color: textGrey, fontSize: 12)),
            const SizedBox(width: 8),
            const Icon(Icons.favorite_border, color: Colors.white24, size: 16),
          ],
        ),
      ),
      title: Text(track.title,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w500)),
      subtitle:
          Text(track.author, style: TextStyle(color: textGrey, fontSize: 12)),
      trailing: Text(
        '${track.duration.inMinutes}:${(track.duration.inSeconds % 60).toString().padLeft(2, '0')}',
        style: TextStyle(color: textGrey, fontSize: 12),
      ),
      onTap: () => ref.read(playerProvider.notifier).playYouTubeTrack(track),
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
    final appState = ref.watch(appStateProvider);
    final suggestions = appState.suggestedTracks;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Trending Videos', accentRed),
          const SizedBox(height: 20),
          if (appState.isSearching)
            const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF003C)))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final track = suggestions[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(track.thumbnailUrl,
                        width: 100, height: 60, fit: BoxFit.cover),
                  ),
                  title: Text(track.title,
                      style: const TextStyle(color: Colors.white)),
                  subtitle:
                      Text(track.author, style: TextStyle(color: textGrey)),
                  onTap: () =>
                      ref.read(videoPlayerProvider.notifier).playVideo(track),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPlayerBar(
    BuildContext context,
    WidgetRef ref,
    PlayerStateModel audioState,
    Color bgDark,
    Color accentRed,
    Color textGrey,
  ) {
    final appState = ref.watch(appStateProvider);
    final videoState = ref.watch(videoPlayerProvider);

    final isVideoMode = appState.mode == AppMode.video;

    final isPlaying = isVideoMode ? videoState.isPlaying : audioState.isPlaying;
    final position = isVideoMode ? videoState.position : audioState.position;
    final duration = isVideoMode ? videoState.duration : audioState.duration;
    final volume = isVideoMode ? videoState.volume : audioState.volume;
    final currentTrack =
        isVideoMode ? videoState.currentVideo : audioState.currentTrack;

    final title = currentTrack?.title ?? 'No Track Playing';
    final author = currentTrack?.author ?? '';
    final thumbnail = currentTrack?.thumbnailUrl ??
        'https://images.unsplash.com/photo-1496661415325-ef852f9e8e7c?q=80&w=2021&auto=format&fit=crop';

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
                image: NetworkImage(thumbnail),
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
                  title,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  author,
                  style: GoogleFonts.inter(color: textGrey, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (currentTrack != null)
            Consumer(
              builder: (context, ref, child) {
                final favorites = ref.watch(fav.favoritesProvider);
                final isFav = favorites.isFavorite(currentTrack.id);
                return IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? accentRed : textGrey,
                    size: 18,
                  ),
                  onPressed: () {
                    final track = fav.Track(
                      id: currentTrack.id,
                      title: currentTrack.title,
                      artist: currentTrack.author,
                      albumArt: currentTrack.thumbnailUrl,
                    );
                    ref
                        .read(fav.favoritesProvider.notifier)
                        .toggleFavorite(track);
                  },
                );
              },
            ),
          const SizedBox(width: 10),
          // Progress & Seek
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(position),
                      style: GoogleFonts.inter(color: textGrey, fontSize: 10),
                    ),
                    Text(
                      _formatDuration(duration),
                      style: GoogleFonts.inter(color: textGrey, fontSize: 10),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 14),
                    activeTrackColor: accentRed,
                    inactiveTrackColor: textGrey.withValues(alpha: 0.3),
                    thumbColor: Colors.white,
                  ),
                  child: Slider(
                    value: position.inSeconds.toDouble(),
                    max: duration.inSeconds.toDouble() > 0
                        ? duration.inSeconds.toDouble()
                        : 0.0,
                    onChanged: (value) {
                      if (isVideoMode) {
                        ref
                            .read(videoPlayerProvider.notifier)
                            .seek(Duration(seconds: value.toInt()));
                      } else {
                        ref
                            .read(playerProvider.notifier)
                            .seek(Duration(seconds: value.toInt()));
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.skip_previous, color: Colors.white),
            onPressed: () {
              if (isVideoMode) {
                // Video skip previous?
                ref.read(videoPlayerProvider.notifier).seek(Duration.zero);
              } else {
                ref.read(playerProvider.notifier).skipPrevious();
              }
            },
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: () {
              if (isVideoMode) {
                ref.read(videoPlayerProvider.notifier).playOrPause();
              } else {
                ref.read(playerProvider.notifier).playOrPause();
              }
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
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.skip_next, color: Colors.white, size: 24),
            onPressed: () {
              if (!isVideoMode) {
                ref.read(playerProvider.notifier).skipNext();
              }
            },
          ),
          const SizedBox(width: 10),
          Icon(Icons.shuffle, color: textGrey, size: 16),
          const SizedBox(width: 8),
          Icon(Icons.tune, color: textGrey, size: 16),
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
                value: volume,
                min: 0,
                max: 100,
                onChanged: (value) {
                  if (isVideoMode) {
                    ref.read(videoPlayerProvider.notifier).setVolume(value);
                  } else {
                    ref.read(playerProvider.notifier).setVolume(value);
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 10),
          Icon(Icons.more_horiz, color: textGrey, size: 20),
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
    return Row(
      children: List.generate(
        count,
        (index) => Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: CircleAvatar(
            radius: 12,
            backgroundImage: NetworkImage(
              'https://i.pravatar.cc/150?u=${startIndex + index}',
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
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
