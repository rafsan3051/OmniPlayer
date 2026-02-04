import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../services/youtube_service.dart';
import '../services/music_service.dart';

// -----------------------------------------------------------------------------
// App Mode Enum
// -----------------------------------------------------------------------------

enum AppMode {
  music,
  video,
}

// -----------------------------------------------------------------------------
// State Models
// -----------------------------------------------------------------------------

class AppState {
  final AppMode mode;
  final String selectedCategory;
  final String? currentScreen;
  final List<VideoMetadata> searchResults;
  final List<VideoMetadata> suggestedTracks;
  final List<File> downloadedFiles;
  final VideoMetadata? heroTrack;
  final bool isSearching;

  const AppState({
    this.mode = AppMode.music,
    this.selectedCategory = 'For you',
    this.currentScreen,
    this.searchResults = const [],
    this.suggestedTracks = const [],
    this.downloadedFiles = const [],
    this.heroTrack,
    this.isSearching = false,
  });

  AppState copyWith({
    AppMode? mode,
    String? selectedCategory,
    String? currentScreen,
    List<VideoMetadata>? searchResults,
    List<VideoMetadata>? suggestedTracks,
    List<File>? downloadedFiles,
    VideoMetadata? heroTrack,
    bool? isSearching,
  }) {
    return AppState(
      mode: mode ?? this.mode,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      currentScreen: currentScreen ?? this.currentScreen,
      searchResults: searchResults ?? this.searchResults,
      suggestedTracks: suggestedTracks ?? this.suggestedTracks,
      downloadedFiles: downloadedFiles ?? this.downloadedFiles,
      heroTrack: heroTrack ?? this.heroTrack,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}

// -----------------------------------------------------------------------------
// Provider
// -----------------------------------------------------------------------------

final appStateProvider =
    StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier();
});

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(const AppState()) {
    _init();
  }

  final MusicService _musicService = MusicService();

  void _init() {
    refreshSuggestions();
    refreshDownloadedFiles();
  }

  void setMode(AppMode mode) {
    state = state.copyWith(mode: mode);
    refreshSuggestions();
  }

  void toggleMode() {
    final nextMode =
        state.mode == AppMode.music ? AppMode.video : AppMode.music;
    state = state.copyWith(mode: nextMode);
    refreshSuggestions();
  }

  void setSelectedCategory(String category) {
    state = state.copyWith(selectedCategory: category);
    if (category == 'Downloads') {
      refreshDownloadedFiles();
    }
  }

  void setCurrentScreen(String screen) {
    state = state.copyWith(currentScreen: screen);
  }

  Future<void> refreshSuggestions() async {
    state = state.copyWith(isSearching: true);
    final query = state.mode == AppMode.music ? 'Top Hits' : 'Trending Movies';
    final results = await _musicService.searchMusic(query);

    if (results.isNotEmpty) {
      state = state.copyWith(
        suggestedTracks: results,
        heroTrack: results.first,
        isSearching: false,
      );
    } else {
      state = state.copyWith(isSearching: false);
    }
  }

  Future<void> refreshDownloadedFiles({String? customPath}) async {
    try {
      final String path =
          customPath ?? (await getApplicationDocumentsDirectory()).path;
      final directory = Directory(path);
      if (await directory.exists()) {
        final List<FileSystemEntity> entities = await directory.list().toList();
        final files = entities
            .whereType<File>()
            .where((f) => f.path.endsWith('.mp3') || f.path.endsWith('.mp4'))
            .toList();
        state = state.copyWith(downloadedFiles: files);
      }
    } catch (e) {
      // Error loading
    }
  }

  Future<void> searchMusic(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(searchResults: [], isSearching: false);
      return;
    }

    state = state.copyWith(isSearching: true);
    final results = await _musicService.searchMusic(query);
    state = state.copyWith(searchResults: results, isSearching: false);
  }

  @override
  void dispose() {
    _musicService.dispose();
    super.dispose();
  }
}
