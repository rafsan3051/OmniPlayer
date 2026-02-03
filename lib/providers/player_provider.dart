import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:file_picker/file_picker.dart';

// -----------------------------------------------------------------------------
// State Models
// -----------------------------------------------------------------------------

class PlayerStateModel {
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final double volume; // 0.0 to 100.0
  final bool isBuffering;

  const PlayerStateModel({
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 100.0,
    this.isBuffering = false,
  });

  PlayerStateModel copyWith({
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    double? volume,
    bool? isBuffering,
  }) {
    return PlayerStateModel(
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      isBuffering: isBuffering ?? this.isBuffering,
    );
  }
}

// -----------------------------------------------------------------------------
// Provider
// -----------------------------------------------------------------------------

final playerProvider = StateNotifierProvider<PlayerNotifier, PlayerStateModel>((
  ref,
) {
  return PlayerNotifier();
});

class PlayerNotifier extends StateNotifier<PlayerStateModel> {
  late final Player _player;

  PlayerNotifier() : super(const PlayerStateModel()) {
    _init();
  }

  Future<void> _init() async {
    // Determine native or web
    _player = Player();

    // Listen to stream updates
    _player.stream.playing.listen((isPlaying) {
      if (mounted) state = state.copyWith(isPlaying: isPlaying);
    });

    _player.stream.position.listen((position) {
      if (mounted) state = state.copyWith(position: position);
    });

    _player.stream.duration.listen((duration) {
      if (mounted) state = state.copyWith(duration: duration);
    });

    _player.stream.volume.listen((volume) {
      if (mounted) state = state.copyWith(volume: volume);
    });

    _player.stream.buffering.listen((isBuffering) {
      if (mounted) state = state.copyWith(isBuffering: isBuffering);
    });
  }

  Future<void> playFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      await _player.open(Media(path));
      // Auto-play is handled by player configuration usually, but we ensure it
      // _player.play(); // media_kit usually auto-plays on open
    }
  }

  // Basic controls
  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> playOrPause() => _player.playOrPause();

  Future<void> seek(Duration position) async {
    // Optimistic update to prevent flickering
    state = state.copyWith(position: position);
    await _player.seek(position);
  }

  Future<void> setVolume(double volume) => _player.setVolume(volume);

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
