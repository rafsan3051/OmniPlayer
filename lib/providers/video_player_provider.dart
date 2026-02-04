import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:file_picker/file_picker.dart';
import '../services/youtube_service.dart';

class VideoPlayerState {
  final Player player;
  final VideoController controller;
  final bool isPlaying;
  final VideoMetadata? currentVideo;
  final bool isBuffering;
  final Duration position;
  final Duration duration;
  final double volume;

  VideoPlayerState({
    required this.player,
    required this.controller,
    this.isPlaying = false,
    this.currentVideo,
    this.isBuffering = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 100.0,
  });

  VideoPlayerState copyWith({
    bool? isPlaying,
    VideoMetadata? currentVideo,
    bool? isBuffering,
    Duration? position,
    Duration? duration,
    double? volume,
    bool clearVideo = false,
  }) {
    return VideoPlayerState(
      player: player,
      controller: controller,
      isPlaying: isPlaying ?? this.isPlaying,
      currentVideo: clearVideo ? null : (currentVideo ?? this.currentVideo),
      isBuffering: isBuffering ?? this.isBuffering,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
    );
  }
}

final videoPlayerProvider =
    StateNotifierProvider<VideoPlayerNotifier, VideoPlayerState>((ref) {
  return VideoPlayerNotifier();
});

class VideoPlayerNotifier extends StateNotifier<VideoPlayerState> {
  VideoPlayerNotifier() : super(_initialState()) {
    _init();
  }

  static VideoPlayerState _initialState() {
    final player = Player();
    final controller = VideoController(player);
    return VideoPlayerState(player: player, controller: controller);
  }

  void _init() {
    state.player.stream.playing.listen((isPlaying) {
      if (mounted) state = state.copyWith(isPlaying: isPlaying);
    });

    state.player.stream.buffering.listen((isBuffering) {
      if (mounted) state = state.copyWith(isBuffering: isBuffering);
    });

    state.player.stream.position.listen((position) {
      if (mounted) state = state.copyWith(position: position);
    });

    state.player.stream.duration.listen((duration) {
      if (mounted) state = state.copyWith(duration: duration);
    });

    state.player.stream.volume.listen((volume) {
      if (mounted) state = state.copyWith(volume: volume);
    });
  }

  Future<void> playVideo(VideoMetadata video) async {
    try {
      state = state.copyWith(isBuffering: true, currentVideo: video);
      final yt = YouTubeService();
      final url = await yt.getVideoStreamUrl(video.id);
      if (url != null) {
        await state.player.stop();
        await state.player.open(Media(url));
      }
      yt.dispose();
    } catch (e) {
      // debugPrint('Error playing video: $e');
    } finally {
      if (mounted) state = state.copyWith(isBuffering: false);
    }
  }

  Future<void> playLocalVideo(String path, String title) async {
    try {
      final video = VideoMetadata(
        id: path,
        title: title,
        author: 'Local File',
        thumbnailUrl: '',
        duration: Duration.zero,
      );
      state = state.copyWith(currentVideo: video);
      await state.player.open(Media(path));
    } catch (e) {
      // debugPrint('Error playing local video: $e');
    }
  }

  Future<void> playFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);

    if (result != null && result.files.single.path != null) {
      await playLocalVideo(result.files.single.path!, result.files.single.name);
    }
  }

  Future<void> playOrPause() => state.player.playOrPause();

  Future<void> seek(Duration position) async {
    state = state.copyWith(position: position);
    await state.player.seek(position);
  }

  Future<void> setVolume(double volume) => state.player.setVolume(volume);

  @override
  void dispose() {
    state.player.dispose();
    super.dispose();
  }
}
