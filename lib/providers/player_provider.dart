import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:file_picker/file_picker.dart';
import '../services/youtube_service.dart';
import '../services/music_service.dart';

// -----------------------------------------------------------------------------
// State Models
// -----------------------------------------------------------------------------

class PlayerStateModel {
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final double volume; // 0.0 to 100.0
  final bool isBuffering;
  final VideoMetadata? currentTrack;
  final List<VideoMetadata> queue;

  const PlayerStateModel({
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 100.0,
    this.isBuffering = false,
    this.currentTrack,
    this.queue = const [],
  });

  PlayerStateModel copyWith({
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    double? volume,
    bool? isBuffering,
    VideoMetadata? currentTrack,
    List<VideoMetadata>? queue,
    bool clearTrack = false,
  }) {
    return PlayerStateModel(
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      isBuffering: isBuffering ?? this.isBuffering,
      currentTrack: clearTrack ? null : (currentTrack ?? this.currentTrack),
      queue: queue ?? this.queue,
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
  final MusicService _musicService = MusicService();

  PlayerNotifier() : super(const PlayerStateModel()) {
    _init();
  }

  Future<void> _init() async {
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

  Future<void> playYouTubeTrack(VideoMetadata track) async {
    try {
      state = state.copyWith(isBuffering: true, currentTrack: track);
      final url = await _musicService.getStreamingUrl(track.id);
      if (url != null) {
        await _player.open(Media(url));
      }
    } catch (e) {
      // debugPrint('Error playing YouTube track: $e');
    } finally {
      if (mounted) state = state.copyWith(isBuffering: false);
    }
  }

  void addToQueue(VideoMetadata track) {
    state = state.copyWith(queue: [...state.queue, track]);
  }

  Future<void> skipNext() async {
    if (state.queue.isNotEmpty) {
      final nextTrack = state.queue.first;
      final remainingQueue = state.queue.sublist(1);
      state = state.copyWith(queue: remainingQueue);
      await playYouTubeTrack(nextTrack);
    }
  }

  Future<void> playFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final name = result.files.single.name;

      final track = VideoMetadata(
        id: path,
        title: name,
        author: 'Local File',
        thumbnailUrl: '',
        duration: Duration.zero,
      );

      state = state.copyWith(currentTrack: track);
      await _player.open(Media(path));
    }
  }

  // Basic controls
  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> playOrPause() => _player.playOrPause();

  Future<void> seek(Duration position) async {
    state = state.copyWith(position: position);
    await _player.seek(position);
  }

  Future<void> setVolume(double volume) => _player.setVolume(volume);

  @override
  void dispose() {
    _player.dispose();
    _musicService.dispose();
    super.dispose();
  }
}
