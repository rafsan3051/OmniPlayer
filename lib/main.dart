import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:google_fonts/google_fonts.dart';

// No longer using theme_engine for this specific UI override as per "look like this" request
// But we keep the providers if needed. For now, hardcoding the SoundWave look.

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  runApp(const ProviderScope(child: MyApp()));

  doWhenWindowReady(() {
    const initialSize = Size(1280, 800);
    appWindow.minSize = const Size(1000, 700);
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SoundWave',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF09090F),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // SoundWave Theme Colors
    const bgDark = Color(0xFF09090F);
    const cardDark = Color(0xFF14141E);
    const accentRed = Color(0xFFFF003C);
    const textGrey = Color(0xFF888899);

    return Scaffold(
      backgroundColor: bgDark,
      body: Column(
        children: [
          // Custom Title Bar
          WindowTitleBarBox(
            child: Container(
              color: bgDark,
              child: Row(
                children: [
                  Expanded(child: MoveWindow()),
                  const WindowButtons(),
                ],
              ),
            ),
          ),

          // Main Body (3 Columns)
          Expanded(
            child: Row(
              children: [
                // 1. Left Sidebar
                Container(
                  width: 240,
                  color: bgDark,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('SOUND',
                              style: GoogleFonts.righteous(
                                  fontSize: 24, color: Colors.white)),
                          Text('WAVE',
                              style: GoogleFonts.righteous(
                                  fontSize: 24, color: accentRed)),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Text('Recommended',
                          style: GoogleFonts.inter(
                              color: textGrey,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      _buildSidebarItem(Icons.check_circle_outline, 'For you',
                          true, accentRed),
                      _buildSidebarItem(Icons.library_music_outlined, 'Library',
                          false, Colors.white),
                      _buildSidebarItem(
                          Icons.wifi_tethering, 'Stream', false, Colors.white),
                      _buildSidebarItem(
                          Icons.radio, 'Fm Radio', false, Colors.white),
                      const SizedBox(height: 30),
                      Text('My music',
                          style: GoogleFonts.inter(
                              color: textGrey,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      _buildSidebarItem(Icons.favorite_border, 'Liked Track',
                          false, Colors.white),
                      _buildSidebarItem(
                          Icons.album_outlined, 'Albums', false, Colors.white),
                      _buildSidebarItem(
                          Icons.person_outline, 'Artist', false, Colors.white),
                      _buildSidebarItem(
                          Icons.history, 'History', false, Colors.white),
                      _buildSidebarItem(Icons.download_done_outlined,
                          'Downloads', false, Colors.white),
                      const SizedBox(height: 30),
                      Text('Playlist',
                          style: GoogleFonts.inter(
                              color: textGrey,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: accentRed,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: accentRed.withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ]),
                        child: Row(
                          children: [
                            const Icon(Icons.music_note,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                            Text('Nasheed',
                                style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Main Content
                Expanded(
                  flex: 3,
                  child: Container(
                    margin:
                        const EdgeInsets.only(top: 10, bottom: 10, right: 10),
                    decoration: BoxDecoration(
                      color: cardDark,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Search & Profile
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                height: 40,
                                decoration: BoxDecoration(
                                  color: bgDark,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.search,
                                        color: textGrey, size: 20),
                                    const SizedBox(width: 10),
                                    Text('Search',
                                        style:
                                            GoogleFonts.inter(color: textGrey)),
                                    const Spacer(),
                                    const Icon(Icons.mic_none,
                                        color: textGrey, size: 20),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            const CircleAvatar(
                                radius: 18,
                                backgroundColor: accentRed,
                                backgroundImage: NetworkImage(
                                    'https://i.pravatar.cc/150?img=11')),
                            const SizedBox(width: 10),
                            Text('Hey, Hasan',
                                style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(width: 10),
                            const Icon(Icons.notifications_none,
                                color: Colors.white),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Featured Banner
                        Container(
                          height: 220,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: const DecorationImage(
                              image: NetworkImage(
                                  'https://images.unsplash.com/photo-1496661415325-ef852f9e8e7c?q=80&w=2021&auto=format&fit=crop'), // Placeholder for red roses
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withValues(alpha: 0.8),
                                    Colors.transparent
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                )),
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('Farhat al amr',
                                    style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text('Nasheed Playlist is now playing',
                                    style: GoogleFonts.inter(color: textGrey)),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.headphones,
                                        color: textGrey, size: 14),
                                    const SizedBox(width: 5),
                                    Text('4,600,000 Listening',
                                        style: GoogleFonts.inter(
                                            color: textGrey, fontSize: 12)),
                                    const SizedBox(width: 15),
                                    const Icon(Icons.star,
                                        color: accentRed, size: 14),
                                    const SizedBox(width: 5),
                                    Text('4.9',
                                        style: GoogleFonts.inter(
                                            color: textGrey, fontSize: 12)),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Song List Header
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          decoration: BoxDecoration(
                            color: bgDark,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                  width: 30,
                                  child: Text(
                                    'song',
                                    style: GoogleFonts.inter(
                                        color: textGrey,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  )), // Icon space
                              Expanded(
                                  flex: 4,
                                  child: Text('SONG',
                                      style: GoogleFonts.inter(
                                          color: textGrey,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold))),
                              Expanded(
                                  flex: 3,
                                  child: Text('ARTIST/ALBUM',
                                      style: GoogleFonts.inter(
                                          color: textGrey,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold))),
                              Text('TIME',
                                  style: GoogleFonts.inter(
                                      color: textGrey,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // List
                        Expanded(
                          child: ListView.builder(
                            itemCount: 8,
                            itemBuilder: (context, index) {
                              final isSelected = index == 0;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF1E1E28)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: isSelected
                                      ? Border.all(
                                          color:
                                              accentRed.withValues(alpha: 0.5))
                                      : null,
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.2),
                                              blurRadius: 4)
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                        width: 30,
                                        child: Text('${index + 1}',
                                            style: GoogleFonts.inter(
                                                color: textGrey))),
                                    Expanded(
                                      flex: 4,
                                      child: Row(
                                        children: [
                                          const Icon(Icons.favorite_border,
                                              color: textGrey, size: 16),
                                          const SizedBox(width: 10),
                                          Text(
                                              isSelected
                                                  ? 'Farhat al amr'
                                                  : 'Song Title $index',
                                              style: GoogleFonts.inter(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500)),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text('Artist Name',
                                          style: GoogleFonts.inter(
                                              color: textGrey)),
                                    ),
                                    Text('3:45',
                                        style:
                                            GoogleFonts.inter(color: textGrey)),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        // Waveform (Static for now)
                        SizedBox(
                          height: 40,
                          child: CustomPaint(
                            painter: WaveformPainter(color: accentRed),
                            child: Container(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. Right Sidebar
                Container(
                  width: 260,
                  color: bgDark,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Most Popular', accentRed),
                      const SizedBox(height: 15),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(
                              5,
                              (index) => Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: CircleAvatar(
                                      radius: 18,
                                      backgroundImage: NetworkImage(
                                          'https://i.pravatar.cc/150?img=${20 + index}'),
                                    ),
                                  )),
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildSectionHeader('Top & Viral', accentRed),
                      const SizedBox(height: 15),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(
                              5,
                              (index) => Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: CircleAvatar(
                                      radius: 18,
                                      backgroundImage: NetworkImage(
                                          'https://i.pravatar.cc/150?img=${30 + index}'),
                                    ),
                                  )),
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildSectionHeader('Upcoming Events', accentRed),
                      const SizedBox(height: 15),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(
                              5,
                              (index) => Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: CircleAvatar(
                                      radius: 18,
                                      backgroundImage: NetworkImage(
                                          'https://i.pravatar.cc/150?img=${40 + index}'),
                                    ),
                                  )),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.keyboard_arrow_down, color: textGrey),
                      const Center(
                          child: Icon(Icons.keyboard_arrow_down,
                              color: textGrey, size: 16)),
                      const SizedBox(height: 20),
                      Text("Live Lyric's",
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text(
                          "Remember The Day When You\nEmbraced Of Tears Of Thoughts?\nYou Called Allah With Patience\nHoping For Mercy To Take Place",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                              color: textGrey, height: 1.5, fontSize: 12)),
                      const SizedBox(height: 20),
                      _buildSectionHeader('Friends Activity', accentRed),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: List.generate(
                                3,
                                (index) => Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: CircleAvatar(
                                          radius: 12,
                                          backgroundImage: NetworkImage(
                                              'https://i.pravatar.cc/150?img=${50 + index}')),
                                    )),
                          ),
                          Text('120 friends',
                              style: GoogleFonts.inter(
                                  color: textGrey, fontSize: 10)),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Player Bar
          Container(
            height: 80,
            decoration: const BoxDecoration(
              color: bgDark,
              border: Border(top: BorderSide(color: Colors.white10)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    image: const DecorationImage(
                        image: NetworkImage(
                            'https://images.unsplash.com/photo-1496661415325-ef852f9e8e7c?q=80&w=2021&auto=format&fit=crop'),
                        fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 15),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Farhat al amr',
                        style: GoogleFonts.inter(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('Anas Dosari, Joys of life',
                        style:
                            GoogleFonts.inter(color: textGrey, fontSize: 12)),
                  ],
                ),
                const SizedBox(width: 40),
                const Icon(Icons.headphones, color: textGrey, size: 20),
                const SizedBox(width: 20),
                const Icon(Icons.skip_previous, color: Colors.white),
                const SizedBox(width: 20),
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      color: accentRed,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: accentRed.withValues(alpha: 0.4),
                          blurRadius: 10,
                        )
                      ]),
                  child: const Icon(Icons.pause, color: Colors.white),
                ),
                const SizedBox(width: 20),
                const Icon(Icons.skip_next, color: Colors.white),
                const SizedBox(width: 20),
                const Icon(Icons.shuffle, color: textGrey, size: 20),
                const Icon(Icons.tune, color: textGrey, size: 20),
                const Spacer(),
                const Icon(Icons.volume_up, color: textGrey),
                Container(
                  width: 100,
                  height: 3,
                  margin: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.7,
                    child: Container(
                      decoration: BoxDecoration(
                          color: accentRed,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: const [
                            BoxShadow(color: accentRed, blurRadius: 4)
                          ]),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                const Icon(Icons.more_horiz, color: textGrey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
      IconData icon, String label, bool isSelected, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: isSelected ? accentColor : Colors.grey, size: 20),
          const SizedBox(width: 15),
          Text(label,
              style: GoogleFonts.inter(
                color: isSelected ? accentColor : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              )),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color accent) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13)),
        Text('View All', style: GoogleFonts.inter(color: accent, fontSize: 10)),
      ],
    );
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = WindowButtonColors(
      iconNormal: Colors.white,
      mouseOver: const Color(0xFFFF003C).withValues(alpha: 0.2),
      mouseDown: const Color(0xFFFF003C).withValues(alpha: 0.4),
      iconMouseOver: const Color(0xFFFF003C),
      iconMouseDown: const Color(0xFFFF003C),
    );
    return Row(
      children: [
        MinimizeWindowButton(colors: colors),
        MaximizeWindowButton(colors: colors),
        CloseWindowButton(colors: colors),
      ],
    );
  }
}

class WaveformPainter extends CustomPainter {
  final Color color;
  WaveformPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final paint2 = Paint()
      ..color = Colors.cyan.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    final path2 = Path();

    path.moveTo(0, size.height / 2);
    path2.moveTo(0, size.height / 2);

    for (double i = 0; i < size.width; i += 10) {
      path.quadraticBezierTo(i + 5, size.height / 2 + (i % 20 == 0 ? 10 : -10),
          i + 10, size.height / 2);
      path2.quadraticBezierTo(i + 5, size.height / 2 + (i % 20 == 0 ? -8 : 8),
          i + 10, size.height / 2);
    }

    canvas.drawPath(path, paint);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
