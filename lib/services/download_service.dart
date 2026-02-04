import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audiotags/audiotags.dart';
import '../services/youtube_service.dart';

class DownloadService {
  final Dio _dio = Dio();

  Future<void> downloadTrack(VideoMetadata track,
      {String format = 'mp3', String? customPath}) async {
    try {
      final yt = YouTubeService();
      final streamUrl = await yt.getAudioStreamUrl(track.id);

      if (streamUrl == null) return;

      final directoryPath =
          customPath ?? (await getApplicationDocumentsDirectory()).path;
      final safeTitle = track.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final savePath = '$directoryPath/$safeTitle.$format';

      await _dio.download(
        streamUrl,
        savePath,
        options: Options(
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          },
        ),
      );

      // Embed tags
      if (format == 'mp3') {
        try {
          final tag = Tag(
            title: track.title,
            trackArtist: track.author,
            album: 'OmniPlayer Downloads',
            pictures: [],
          );
          await AudioTags.write(savePath, tag);
        } catch (e) {
          // Tagging failed
        }
      }

      yt.dispose();
    } catch (e) {
      // debugPrint('Download error: $e');
    }
  }

  Future<void> downloadVideo(VideoMetadata video,
      {String quality = '1080p', String? customPath}) async {
    try {
      final yt = YouTubeService();
      final streamUrl = await yt.getVideoStreamUrl(video.id, quality: quality);

      if (streamUrl == null) return;

      final directoryPath =
          customPath ?? (await getApplicationDocumentsDirectory()).path;
      final safeTitle = video.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final savePath = '$directoryPath/$safeTitle.mp4';

      await _dio.download(
        streamUrl,
        savePath,
        options: Options(
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          },
        ),
      );
      yt.dispose();
    } catch (e) {
      // debugPrint('Video download error: $e');
    }
  }
}
