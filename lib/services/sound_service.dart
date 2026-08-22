import 'package:audioplayers/audioplayers.dart';

class SoundService {
  SoundService._();

  static final SoundService instance = SoundService._();

  final AudioPlayer _player = AudioPlayer();

  Future<void> playNgoko(String uid) async {
    await _player.stop();

    await _player.play(
      AssetSource('sounds/ngoko/$uid.wav'),
    );
  }

  Future<void> playKrama(String uid) async {
    await _player.stop();

    await _player.play(
      AssetSource('sounds/krama/$uid.wav'),
    );
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}

