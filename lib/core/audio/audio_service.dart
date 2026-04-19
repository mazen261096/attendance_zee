import 'package:audioplayers/audioplayers.dart';

import 'audio_events.dart';

/// Simple audio service for playing sound effects
///
/// Provides a centralized way to play sounds throughout the app.
/// Currently supports question and answer submission sounds.
class AudioService {
  // Singleton pattern
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();

  /// Play sound for the given audio event
  Future<void> play(MyAudioEvent event) async {
    try {
      final soundPath = _getSoundPath(event);
      await _player.play(AssetSource(soundPath));
    } catch (e) {
      // Silently fail - audio is not critical functionality
      // Could log error in production for debugging
    }
  }

  /// Map audio events to their corresponding sound files
  String _getSoundPath(MyAudioEvent event) {
    switch (event) {
      case MyAudioEvent.questionSent:
      case MyAudioEvent.answerSent:
        return 'audio/zee_notify.wav';
    }
  }

  /// Dispose resources
  void dispose() {
    _player.dispose();
  }
}
