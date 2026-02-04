import 'youtube_service.dart';

class MusicService {
  final YouTubeService _youtubeService = YouTubeService();

  Future<List<VideoMetadata>> searchMusic(String query) async {
    // Append "official audio" to help narrow down search to music
    return _youtubeService.search('$query official audio');
  }

  Future<String?> getStreamingUrl(String videoId) {
    return _youtubeService.getAudioStreamUrl(videoId);
  }

  void dispose() {
    _youtubeService.dispose();
  }
}
