import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';

class AuthDialog extends ConsumerWidget {
  const AuthDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    const bgDark = Color(0xFF09090F);
    const cardDark = Color(0xFF14141E);
    const accentRed = Color(0xFFFF003C);
    const textGrey = Color(0xFF888899);

    return Dialog(
      backgroundColor: cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              'Welcome to OmniPlayer',
              style: GoogleFonts.righteous(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Sign in to sync your favorites and playlists',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: textGrey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 30),

            // Error message
            if (authState.error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        authState.error!,
                        style: GoogleFonts.inter(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Google Sign In Button
            InkWell(
              onTap: authState.isLoading
                  ? null
                  : () async {
                      await authNotifier.signInWithGoogle();
                      if (context.mounted && authState.user != null) {
                        Navigator.of(context).pop();
                      }
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: authState.isLoading
                    ? const Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(accentRed),
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            'https://www.google.com/favicon.ico',
                            width: 20,
                            height: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Sign in with Google',
                            style: GoogleFonts.inter(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // Divider
            Row(
              children: [
                Expanded(
                    child: Divider(color: textGrey.withValues(alpha: 0.3))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    'OR',
                    style: GoogleFonts.inter(color: textGrey, fontSize: 12),
                  ),
                ),
                Expanded(
                    child: Divider(color: textGrey.withValues(alpha: 0.3))),
              ],
            ),

            const SizedBox(height: 20),

            // Continue as Guest Button
            InkWell(
              onTap: () {
                authNotifier.continueAsGuest();
                Navigator.of(context).pop();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: bgDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: textGrey.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text(
                    'Continue as Guest',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Info text
            Text(
              'Guest mode: You can stream music and videos, but cannot sync favorites across devices.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: textGrey,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
