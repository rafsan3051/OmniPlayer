import 'dart:io';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

class DownloadService {
  final YoutubeExplode _yt = YoutubeExplode();

  Future<Video> getVideoInfo(String url) async {
    return await _yt.videos.get(url);
  }

  Future<void> downloadAudio(String videoUrl, {String? customPath}) async {
    try {
      final video = await _yt.videos.get(videoUrl);
      final manifest = await _yt.videos.streamsClient.getManifest(video.id);

      // Get highest quality audio only stream
      final audioStreamInfo = manifest.audioOnly.withHighestBitrate();

      final audioStream = _yt.videos.streamsClient.get(audioStreamInfo);

      // Determine save path
      String savePath;
      if (customPath != null) {
        savePath = customPath;
      } else {
        // Default to Downloads/OmniMusic
        final userProfile = Platform.environment['USERPROFILE'];
        if (userProfile == null) {
          throw Exception(
            'Could not determine user profile for default download path.',
          );
        }

        // Use Downloads folder or Music folder
        final downloadsDir = Directory(p.join(userProfile, 'Downloads'));
        if (downloadsDir.existsSync()) {
          savePath = p.join(downloadsDir.path, 'OmniMusic');
        } else {
          // Fallback to local app data or similar if Downloads doesn't exist (unlikely on Windows)
          savePath = p.join(userProfile, 'Music', 'OmniMusic');
        }
      }

      final dir = Directory(savePath);
      if (!await dir.exists()) {
        try {
          await dir.create(recursive: true);
        } catch (e) {
          throw Exception(
            'Permission denied: Could not create directory $savePath. Please select a custom path.',
          );
        }
      }

      // Sanitize filename
      final fileName = '${video.title}.${audioStreamInfo.container.name}'
          .replaceAll(RegExp(r'[\\/:*?"<>|]'), '');

      final file = File(p.join(savePath, fileName));

      // Download
      final fileStream = file.openWrite();
      await audioStream.pipe(fileStream);
      await fileStream.flush();
      await fileStream.close();
    } catch (e) {
      // debugPrint('Download Failed: $e');
      rethrow;
    }
  }

  Future<String?> selectDownloadPath() async {
    return await FilePicker.platform.getDirectoryPath();
  }

  void dispose() {
    _yt.close();
  }
}
