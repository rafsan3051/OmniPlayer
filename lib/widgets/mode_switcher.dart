import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_state_provider.dart';

class ModeSwitcher extends ConsumerWidget {
  const ModeSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final appStateNotifier = ref.read(appStateProvider.notifier);

    const accentRed = Color(0xFFFF003C);
    const bgDark = Color(0xFF09090F);
    const textGrey = Color(0xFF888899);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModeButton(
            label: 'Music',
            icon: Icons.music_note,
            isSelected: appState.mode == AppMode.music,
            onTap: () => appStateNotifier.setMode(AppMode.music),
            accentColor: accentRed,
            textColor: textGrey,
          ),
          const SizedBox(width: 4),
          _buildModeButton(
            label: 'Video',
            icon: Icons.video_library,
            isSelected: appState.mode == AppMode.video,
            onTap: () => appStateNotifier.setMode(AppMode.video),
            accentColor: accentRed,
            textColor: textGrey,
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color accentColor,
    required Color textColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : textColor,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isSelected ? Colors.white : textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
