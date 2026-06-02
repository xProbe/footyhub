import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

class AudioFeedbackService {
  final AudioPlayer _player = AudioPlayer();

  AudioFeedbackService() {
    _init();
  }

  Future<void> _init() async {
    try {
      // Pre-load the asset if possible
      await _player.setAsset('assets/audio/ball_kick.mp3');
    } catch (_) {
      // Fallback or ignore if asset doesn't exist yet
    }
  }

  Future<void> playKickSound() async {
    try {
      // Play a crisp soccer kick sound
      // If asset is not loaded/missing, we try to load it or play fallback
      await _player.setAsset('assets/audio/ball_kick.mp3');
      await _player.seek(Duration.zero);
      await _player.play();
    } catch (e) {
      // If asset fails, fall back to playing a light kick from a network URL
      try {
        await _player.setUrl('https://www.soundjay.com/button/button-5.mp3');
        await _player.play();
      } catch (_) {
        // Silent catch
      }
    }
  }

  void dispose() {
    _player.dispose();
  }
}

final audioFeedbackProvider = Provider<AudioFeedbackService>((ref) {
  final service = AudioFeedbackService();
  ref.onDispose(() => service.dispose());
  return service;
});
