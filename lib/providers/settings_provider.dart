import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// -----------------------------------------------------------------------------
// State Models
// -----------------------------------------------------------------------------

class SettingsState {
  final String theme; // 'dark', 'light', 'soundwave'
  final String downloadLocation;
  final String audioQuality; // '128', '192', '320'
  final String videoQuality; // '720p', '1080p', '1440p', '2160p'
  final bool autoDownloadMetadata;

  const SettingsState({
    this.theme = 'soundwave',
    this.downloadLocation = '',
    this.audioQuality = '320',
    this.videoQuality = '1080p',
    this.autoDownloadMetadata = true,
  });

  SettingsState copyWith({
    String? theme,
    String? downloadLocation,
    String? audioQuality,
    String? videoQuality,
    bool? autoDownloadMetadata,
  }) {
    return SettingsState(
      theme: theme ?? this.theme,
      downloadLocation: downloadLocation ?? this.downloadLocation,
      audioQuality: audioQuality ?? this.audioQuality,
      videoQuality: videoQuality ?? this.videoQuality,
      autoDownloadMetadata: autoDownloadMetadata ?? this.autoDownloadMetadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'downloadLocation': downloadLocation,
      'audioQuality': audioQuality,
      'videoQuality': videoQuality,
      'autoDownloadMetadata': autoDownloadMetadata,
    };
  }

  factory SettingsState.fromJson(Map<String, dynamic> json) {
    return SettingsState(
      theme: json['theme'] ?? 'soundwave',
      downloadLocation: json['downloadLocation'] ?? '',
      audioQuality: json['audioQuality'] ?? '320',
      videoQuality: json['videoQuality'] ?? '1080p',
      autoDownloadMetadata: json['autoDownloadMetadata'] ?? true,
    );
  }
}

// -----------------------------------------------------------------------------
// Provider
// -----------------------------------------------------------------------------

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<SettingsState> {
  static const String _prefsKey = 'app_settings';

  SettingsNotifier() : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_prefsKey);

      if (jsonString != null) {
        // Parse JSON and update state
        // Simple parsing since we're storing individual keys
        state = SettingsState(
          theme: prefs.getString('theme') ?? 'soundwave',
          downloadLocation: prefs.getString('downloadLocation') ?? '',
          audioQuality: prefs.getString('audioQuality') ?? '320',
          videoQuality: prefs.getString('videoQuality') ?? '1080p',
          autoDownloadMetadata: prefs.getBool('autoDownloadMetadata') ?? true,
        );
      }
    } catch (e) {
      // Error loading
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme', state.theme);
      await prefs.setString('downloadLocation', state.downloadLocation);
      await prefs.setString('audioQuality', state.audioQuality);
      await prefs.setString('videoQuality', state.videoQuality);
      await prefs.setBool('autoDownloadMetadata', state.autoDownloadMetadata);
    } catch (e) {
      // Error saving
    }
  }

  Future<void> setTheme(String theme) async {
    state = state.copyWith(theme: theme);
    await _saveSettings();
  }

  Future<void> setDownloadLocation(String location) async {
    state = state.copyWith(downloadLocation: location);
    await _saveSettings();
  }

  Future<void> setAudioQuality(String quality) async {
    state = state.copyWith(audioQuality: quality);
    await _saveSettings();
  }

  Future<void> setVideoQuality(String quality) async {
    state = state.copyWith(videoQuality: quality);
    await _saveSettings();
  }

  Future<void> setAutoDownloadMetadata(bool value) async {
    state = state.copyWith(autoDownloadMetadata: value);
    await _saveSettings();
  }
}
