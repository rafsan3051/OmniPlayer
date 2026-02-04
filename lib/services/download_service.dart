import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audiotags/audiotags.dart';
import '../services/youtube_service.dart';

class DownloadService {
  final Dio _dio = Dio();

  Future<void> downloadTrack(VideoMetadata track,
      {String format = 'mp3'}) async {
    try {
      final yt = YouTubeService();
      final streamUrl = await yt.getAudioStreamUrl(track.id);

      if (streamUrl == null) return;

      final directory = await getApplicationDocumentsDirectory();
      final savePath =
          '${directory.path}/${track.title.replaceAll(RegExp(r'[^\w\s]+'), '')}.$format';

      await _dio.download(
        streamUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            // progress tracking logic could be added here
          }
        },
      );

      // Embed tags
      if (format == 'mp3') {
        final tag = Tag(
          title: track.title,
          trackArtist: track.author,
          album: 'OmniPlayer Downloads',
          pictures: [],
        );
        await AudioTags.write(savePath, tag);
      }

      yt.dispose();
    } catch (e) {
      // debugPrint('Download error: $e');
    }
  }

  Future<void> downloadVideo(VideoMetadata video,
      {String quality = '1080p'}) async {
    try {
      final yt = YouTubeService();
      final streamUrl = await yt.getVideoStreamUrl(video.id, quality: quality);

      if (streamUrl == null) return;

      final directory = await getApplicationDocumentsDirectory();
      final savePath =
          '${directory.path}/${video.title.replaceAll(RegExp(r'[^\w\s]+'), '')}.mp4';

      await _dio.download(streamUrl, savePath);
      yt.dispose();
    } catch (e) {
      // debugPrint('Video download error: $e');
    }
  }
}
