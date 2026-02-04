import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../services/youtube_service.dart';

class VideoPlayerState {
  final Player player;
  final VideoController controller;
  final bool isPlaying;
  final VideoMetadata? currentVideo;
  final bool isBuffering;

  VideoPlayerState({
    required this.player,
    required this.controller,
    this.isPlaying = false,
    this.currentVideo,
    this.isBuffering = false,
  });

  VideoPlayerState copyWith({
    bool? isPlaying,
    VideoMetadata? currentVideo,
    bool? isBuffering,
    bool clearVideo = false,
  }) {
    return VideoPlayerState(
      player: player,
      controller: controller,
      isPlaying: isPlaying ?? this.isPlaying,
      currentVideo: clearVideo ? null : (currentVideo ?? this.currentVideo),
      isBuffering: isBuffering ?? this.isBuffering,
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
  }

  Future<void> playVideo(VideoMetadata video) async {
    try {
      state = state.copyWith(isBuffering: true, currentVideo: video);
      final yt = YouTubeService();
      final url = await yt.getVideoStreamUrl(video.id);
      if (url != null) {
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

  Future<void> playOrPause() => state.player.playOrPause();

  @override
  void dispose() {
    state.player.dispose();
    super.dispose();
  }
}
