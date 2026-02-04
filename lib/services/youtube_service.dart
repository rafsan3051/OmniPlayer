import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class VideoMetadata {
  final String id;
  final String title;
  final String author;
  final String thumbnailUrl;
  final Duration duration;
  final DateTime? uploadDate;

  VideoMetadata({
    required this.id,
    required this.title,
    required this.author,
    required this.thumbnailUrl,
    required this.duration,
    this.uploadDate,
  });
}

class YouTubeService {
  final YoutubeExplode _yt = YoutubeExplode();

  Future<List<VideoMetadata>> search(String query) async {
    try {
      final searchList = await _yt.search.search(query);
      return searchList
          .map((video) => VideoMetadata(
                id: video.id.value,
                title: video.title,
                author: video.author,
                thumbnailUrl: video.thumbnails.highResUrl,
                duration: video.duration ?? Duration.zero,
                uploadDate: video.uploadDate,
              ))
          .toList();
    } catch (e) {
      // debugPrint('YouTube search error: $e');
      return [];
    }
  }

  Future<String?> getAudioStreamUrl(String videoId) async {
    try {
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      final audioStream = manifest.audioOnly.firstOrNull ??
          manifest.muxed
              .where((s) => s.videoQuality.toString().contains('360p'))
              .firstOrNull ??
          manifest.muxed.withHighestBitrate();
      return audioStream.url.toString();
    } catch (e) {
      // debugPrint('YouTube audio stream error: $e');
      return null;
    }
  }

  Future<String?> getVideoStreamUrl(String videoId,
      {String quality = '1080p'}) async {
    try {
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      final videoStream = manifest.muxed
              .where((s) => s.videoQuality.toString().contains(quality))
              .firstOrNull ??
          manifest.muxed.withHighestBitrate();
      return videoStream.url.toString();
    } catch (e) {
      // debugPrint('YouTube video stream error: $e');
      return null;
    }
  }

  void dispose() {
    _yt.close();
  }
}
