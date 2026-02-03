import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'dart:isolate';

class MediaScanner {
  /// recursively scans the given [directories] for audio files using an Isolate.
  Future<List<String>> scanForAudio(List<String> directories) async {
    // Pass directories to the isolate
    return await Isolate.run(() => _scanInIsolate(directories));
  }

  // Static function to run in Isolate
  static Future<List<String>> _scanInIsolate(
    List<String> userDirectories,
  ) async {
    final List<String> audioFilePaths = [];
    final extensions = {'.mp3', '.wav', '.flac', '.m4a', '.aac'};
    final directoriesToScan = [...userDirectories];

    if (directoriesToScan.isEmpty) {
      final userProfile = Platform.environment['USERPROFILE'];
      if (userProfile != null) {
        directoriesToScan.add(p.join(userProfile, 'Music'));
        directoriesToScan.add(p.join(userProfile, 'Downloads'));
      }
    }

    for (final dirPath in directoriesToScan) {
      final dir = Directory(dirPath);
      if (!dir.existsSync()) continue;

      try {
        final entities = dir.listSync(recursive: true, followLinks: false);
        for (final entity in entities) {
          if (entity is File) {
            final ext = p.extension(entity.path).toLowerCase();
            if (extensions.contains(ext)) {
              audioFilePaths.add(entity.path);
            }
          }
        }
      } catch (e) {
        // Ignore errors in isolate
      }
    }
    return audioFilePaths;
  }

  Future<String?> pickDirectory() async {
    return await FilePicker.platform.getDirectoryPath();
  }
}
