import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class QuranAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer player = AudioPlayer();

  void Function()? onSkipToNext;
  void Function()? onSkipToPrevious;

  QuranAudioHandler() {
    player.playbackEventStream.listen((_) => _broadcastState());
    player.playerStateStream.listen((_) => _broadcastState());
  }

  void _broadcastState() {
    final playing = player.playing;
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {MediaAction.seek},
      androidCompactActionIndices: const [0, 1, 3],
      processingState: {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[player.processingState]!,
      playing: playing,
      updatePosition: player.position,
      bufferedPosition: player.bufferedPosition,
      speed: player.speed,
    ));
  }

  void updateNowPlaying(int surahNumber, String surahName, String? reciterName) {
    mediaItem.add(MediaItem(
      id: 'surah_$surahNumber',
      title: surahName,
      artist: reciterName ?? "Qur'an NG",
      album: 'The Holy Qur\'an',
      displayTitle: surahName,
      displaySubtitle: reciterName ?? "Qur'an NG",
    ));
  }

  @override
  Future<void> play() => player.play();

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> seek(Duration position) => player.seek(position);

  @override
  Future<void> stop() async {
    await player.stop();
    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.idle,
    ));
  }

  @override
  Future<void> setSpeed(double speed) => player.setSpeed(speed);

  @override
  Future<void> skipToNext() async => onSkipToNext?.call();

  @override
  Future<void> skipToPrevious() async => onSkipToPrevious?.call();

  Future<void> disposePlayer() async {
    await player.dispose();
  }
}
