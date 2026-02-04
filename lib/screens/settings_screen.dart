import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    const accentRed = Color(0xFFFF003C);
    const bgDark = Color(0xFF09090F);
    const cardDark = Color(0xFF14141E);
    const textGrey = Color(0xFF888899);

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        title: Text(
          'Settings',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Appearance',
              [
                _buildSettingItem(
                  'Theme',
                  'Choose your preferred UI theme',
                  DropdownButton<String>(
                    value: settings.theme,
                    dropdownColor: cardDark,
                    underline: const SizedBox(),
                    style: GoogleFonts.inter(color: Colors.white),
                    onChanged: (val) => settingsNotifier.setTheme(val!),
                    items: ['soundwave', 'dark', 'midnight']
                        .map((t) => DropdownMenuItem(
                            value: t, child: Text(t.toUpperCase())))
                        .toList(),
                  ),
                ),
              ],
              accentRed,
              textGrey,
              cardDark,
            ),
            const SizedBox(height: 30),
            _buildSection(
              'Downloads',
              [
                _buildSettingItem(
                  'Download Location',
                  settings.downloadLocation.isEmpty
                      ? 'Default (Documents)'
                      : settings.downloadLocation,
                  IconButton(
                    icon: const Icon(Icons.folder_open, color: accentRed),
                    onPressed: () async {
                      String? selectedDirectory =
                          await FilePicker.platform.getDirectoryPath();
                      if (selectedDirectory != null) {
                        settingsNotifier.setDownloadLocation(selectedDirectory);
                      }
                    },
                  ),
                ),
                _buildSettingItem(
                  'Audio Quality',
                  'Select streaming and download quality',
                  DropdownButton<String>(
                    value: settings.audioQuality,
                    dropdownColor: cardDark,
                    underline: const SizedBox(),
                    style: GoogleFonts.inter(color: Colors.white),
                    onChanged: (val) => settingsNotifier.setAudioQuality(val!),
                    items: ['128', '192', '320']
                        .map((q) =>
                            DropdownMenuItem(value: q, child: Text('${q}kbps')))
                        .toList(),
                  ),
                ),
                _buildSettingItem(
                  'Auto-Download Metadata',
                  'Automatically fetch album art and tags',
                  Switch(
                    value: settings.autoDownloadMetadata,
                    activeThumbColor: accentRed,
                    onChanged: (val) =>
                        settingsNotifier.setAutoDownloadMetadata(val),
                  ),
                ),
              ],
              accentRed,
              textGrey,
              cardDark,
            ),
            const SizedBox(height: 30),
            _buildSection(
              'Playback',
              [
                _buildSettingItem(
                  'Video Quality',
                  'Preferred YouTube video resolution',
                  DropdownButton<String>(
                    value: settings.videoQuality,
                    dropdownColor: cardDark,
                    underline: const SizedBox(),
                    style: GoogleFonts.inter(color: Colors.white),
                    onChanged: (val) => settingsNotifier.setVideoQuality(val!),
                    items: ['360p', '480p', '720p', '1080p', '1440p', '4k']
                        .map((q) => DropdownMenuItem(value: q, child: Text(q)))
                        .toList(),
                  ),
                ),
              ],
              accentRed,
              textGrey,
              cardDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items, Color accent,
      Color textGrey, Color cardBg) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            color: accent,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  item,
                  if (idx < items.length - 1)
                    const Divider(
                        color: Colors.white10,
                        height: 1,
                        indent: 16,
                        endIndent: 16),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem(String title, String subtitle, Widget trailing) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF888899),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
