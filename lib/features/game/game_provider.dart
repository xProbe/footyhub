import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/storage_util.dart';
import '../../data/locals/database_helper.dart';

class GameState {
  final int score;
  final int highScore;
  final int hearts;
  final bool isGameOver;

  GameState({
    this.score = 0,
    this.highScore = 0,
    this.hearts = 3,
    this.isGameOver = false,
  });

  GameState copyWith({
    int? score,
    int? highScore,
    int? hearts,
    bool? isGameOver,
  }) {
    return GameState(
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      hearts: hearts ?? this.hearts,
      isGameOver: isGameOver ?? this.isGameOver,
    );
  }
}

class GameNotifier extends StateNotifier<GameState> {
  String? _username;

  GameNotifier() : super(GameState()) {
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    _username = await StorageUtil.getLoggedInUsername();
    if (_username != null) {
      final hs = await DatabaseHelper.instance.getHighScore(_username!);
      state = state.copyWith(highScore: hs);
    }
  }

  void increaseScore() async {
    if (state.isGameOver) return;
    final newScore = state.score + 10;
    var newHighScore = state.highScore;
    if (newScore > state.highScore) {
      newHighScore = newScore;
      if (_username != null) {
        await DatabaseHelper.instance.saveHighScore(_username!, newScore);
      }
    }
    state = state.copyWith(score: newScore, highScore: newHighScore);
  }

  void decreaseHeart() {
    if (state.isGameOver) return;
    final newHearts = state.hearts - 1;
    if (newHearts <= 0) {
      state = state.copyWith(hearts: 0, isGameOver: true);
    } else {
      state = state.copyWith(hearts: newHearts);
    }
  }

  void resetGame() {
    state = state.copyWith(score: 0, hearts: 3, isGameOver: false);
  }
}

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier();
});
