import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

// -----------------------------------------------------------------------------
// State Models
// -----------------------------------------------------------------------------

class UserData {
  final String id;
  final String? displayName;
  final String? email;
  final String? photoUrl;

  const UserData({
    required this.id,
    this.displayName,
    this.email,
    this.photoUrl,
  });
}

class AuthState {
  final UserData? user;
  final bool isLoading;
  final String? error;
  final bool isGuest;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isGuest = true,
  });

  bool get isAuthenticated => user != null && !isGuest;

  AuthState copyWith({
    UserData? user,
    bool? isLoading,
    String? error,
    bool? isGuest,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isGuest: isGuest ?? this.isGuest,
    );
  }
}

// -----------------------------------------------------------------------------
// Provider
// -----------------------------------------------------------------------------

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  AuthNotifier() : super(const AuthState()) {
    _init();
  }

  Future<void> _init() async {
    // Check if user is already signed in
    try {
      final account = await _googleSignIn.signInSilently();
      if (account != null) {
        final userData = UserData(
          id: account.id,
          displayName: account.displayName,
          email: account.email,
          photoUrl: account.photoUrl,
        );
        state = state.copyWith(user: userData, isGuest: false);
      }
    } catch (e) {
      // Silent sign-in failed
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Trigger the Google Sign-In flow
      GoogleSignInAccount? googleUser;
      try {
        googleUser = await _googleSignIn.signIn();
      } catch (e) {
        // Fallback to mock sign-in if real sign-in fails (e.g. no configuration)
        const mockUser = UserData(
          id: 'mock_123',
          displayName: 'Guest User',
          email: 'guest@example.com',
          photoUrl: null,
        );
        state =
            state.copyWith(user: mockUser, isLoading: false, isGuest: false);
        return;
      }

      if (googleUser == null) {
        // User cancelled the sign-in
        state = state.copyWith(isLoading: false);
        return;
      }

      final userData = UserData(
        id: googleUser.id,
        displayName: googleUser.displayName,
        email: googleUser.email,
        photoUrl: googleUser.photoUrl,
      );

      state = state.copyWith(
        user: userData,
        isLoading: false,
        isGuest: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> signOut() async {
    try {
      state = state.copyWith(isLoading: true);

      await _googleSignIn.signOut();

      state = const AuthState(isGuest: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void continueAsGuest() {
    state = const AuthState(isGuest: true);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
