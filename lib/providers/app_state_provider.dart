import 'package:flutter_riverpod/flutter_riverpod.dart';

// -----------------------------------------------------------------------------
// App Mode Enum
// -----------------------------------------------------------------------------

enum AppMode {
  music,
  video,
}

// -----------------------------------------------------------------------------
// State Models
// -----------------------------------------------------------------------------

class AppState {
  final AppMode mode;
  final String selectedCategory;
  final String? currentScreen;

  const AppState({
    this.mode = AppMode.music,
    this.selectedCategory = 'For you',
    this.currentScreen,
  });

  AppState copyWith({
    AppMode? mode,
    String? selectedCategory,
    String? currentScreen,
  }) {
    return AppState(
      mode: mode ?? this.mode,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      currentScreen: currentScreen ?? this.currentScreen,
    );
  }
}

// -----------------------------------------------------------------------------
// Provider
// -----------------------------------------------------------------------------

final appStateProvider =
    StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier();
});

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(const AppState());

  void setMode(AppMode mode) {
    state = state.copyWith(mode: mode);
  }

  void toggleMode() {
    state = state.copyWith(
      mode: state.mode == AppMode.music ? AppMode.video : AppMode.music,
    );
  }

  void setSelectedCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setCurrentScreen(String screen) {
    state = state.copyWith(currentScreen: screen);
  }
}
