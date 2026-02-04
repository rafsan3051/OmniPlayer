import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// -----------------------------------------------------------------------------
// State Models
// -----------------------------------------------------------------------------

class Track {
  final String id;
  final String title;
  final String artist;
  final String? albumArt;
  final String? filePath;
  final Duration? duration;

  const Track({
    required this.id,
    required this.title,
    required this.artist,
    this.albumArt,
    this.filePath,
    this.duration,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'albumArt': albumArt,
      'filePath': filePath,
      'duration': duration?.inSeconds,
    };
  }

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      albumArt: json['albumArt'],
      filePath: json['filePath'],
      duration:
          json['duration'] != null ? Duration(seconds: json['duration']) : null,
    );
  }
}

class FavoritesState {
  final List<Track> tracks;
  final bool isLoading;

  const FavoritesState({
    this.tracks = const [],
    this.isLoading = false,
  });

  FavoritesState copyWith({
    List<Track>? tracks,
    bool? isLoading,
  }) {
    return FavoritesState(
      tracks: tracks ?? this.tracks,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool isFavorite(String trackId) {
    return tracks.any((track) => track.id == trackId);
  }
}

// -----------------------------------------------------------------------------
// Provider
// -----------------------------------------------------------------------------

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  return FavoritesNotifier();
});

class FavoritesNotifier extends StateNotifier<FavoritesState> {
  static const String _prefsKey = 'favorite_tracks';

  FavoritesNotifier() : super(const FavoritesState()) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      state = state.copyWith(isLoading: true);
      await SharedPreferences.getInstance();

      // In a real app, you'd fetch full track data from a database or API
      // For now, we'll just store the IDs
      state = state.copyWith(
        tracks: [],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final trackIds = state.tracks.map((track) => track.id).toList();
      await prefs.setStringList(_prefsKey, trackIds);
    } catch (e) {
      // Error saving
    }
  }

  Future<void> toggleFavorite(Track track) async {
    final isFavorite = state.isFavorite(track.id);

    if (isFavorite) {
      // Remove from favorites
      final updatedTracks =
          state.tracks.where((t) => t.id != track.id).toList();
      state = state.copyWith(tracks: updatedTracks);
    } else {
      // Add to favorites
      final updatedTracks = [...state.tracks, track];
      state = state.copyWith(tracks: updatedTracks);
    }

    await _saveFavorites();
  }

  Future<void> addFavorite(Track track) async {
    if (!state.isFavorite(track.id)) {
      final updatedTracks = [...state.tracks, track];
      state = state.copyWith(tracks: updatedTracks);
      await _saveFavorites();
    }
  }

  Future<void> removeFavorite(String trackId) async {
    final updatedTracks = state.tracks.where((t) => t.id != trackId).toList();
    state = state.copyWith(tracks: updatedTracks);
    await _saveFavorites();
  }

  Future<void> clearFavorites() async {
    state = const FavoritesState();
    await _saveFavorites();
  }
}
