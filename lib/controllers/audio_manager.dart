import 'package:just_audio/just_audio.dart';

import '../bloc/bloc_provider.dart';

class AudioManager implements BlocBase {
  final AudioPlayer backgroundAudio = AudioPlayer();
  final AudioPlayer wonAudio = AudioPlayer();
  final AudioPlayer lostAudio = AudioPlayer();

  AudioManager() {
    loadAudioAssets();
    setCompletionHandlers();
  }

  void loadAudioAssets() {
    backgroundAudio.setAsset('assets/audio/Background_Music.mp3');
    wonAudio.setAsset('assets/audio/winning_music.mp3');
    lostAudio.setAsset('assets/audio/losing_music.mp3');
  }

  Future<void> playBackgroundMusic() async {
    backgroundAudio.play();
  }

  Future<void> stopMusic() async {
    await backgroundAudio.stop();
  }

  Future<void> playWonLostMusic(bool won) async {
    stopMusic();
    if (won) {
      wonAudio.play();
    } else {
      lostAudio.play();
    }
  }

  void setCompletionHandlers() {
    wonAudio.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        wonAudio.stop();
      }
    });

    lostAudio.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        lostAudio.stop();
      }
    });
  }

  Future<void> stopWonLostMusic() async {
    await wonAudio.stop();
    await lostAudio.stop();
  }

  @override
  void dispose() {
    backgroundAudio.dispose();
    wonAudio.dispose();
    lostAudio.dispose();
  }
}
