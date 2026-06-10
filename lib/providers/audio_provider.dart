import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import '../data/reciters_data.dart';
import '../models/reciter_model.dart';
import '../services/audio_handler.dart';

class AudioProvider extends ChangeNotifier {
  final QuranAudioHandler _handler;
  AudioPlayer get _player => _handler.player;

  int? _currentSurahNumber;
  String? _currentSurahName;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _speed = 1.0;
  bool _isRepeat = false;
  ReciterModel? _currentReciter;
  bool _isSleepTimerActive = false;
  String? _errorMessage;

  int? _lastSurahNumber;
  String? _lastSurahName;
  String? _lastReciterId;
  String Function(int)? _surahNameFn;
  int? Function(int)? _surahAyahCountFn;

  bool _isPerAyahMode = false;
  int _currentAyahIndex = 0;
  bool _perAyahStarted = false;
  bool _isRepeatAyah = false;
  int _repeatAyahIndex = -1;
  bool _isAdvancing = false;

  Duration _lastNotifiedPosition = Duration.zero;

  int? get currentSurahNumber => _currentSurahNumber;
  String? get currentSurahName => _currentSurahName;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  Duration get position => _position;
  Duration get duration => _duration;
  double get speed => _speed;
  bool get isRepeat => _isRepeat;
  ReciterModel? get currentReciter => _currentReciter;
  bool get isSleepTimerActive => _isSleepTimerActive;
  bool get hasAudio => _currentSurahNumber != null;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get canPlayPrev => _currentSurahNumber != null && _currentSurahNumber! > 1;
  bool get canPlayNext => _currentSurahNumber != null && _currentSurahNumber! < 114;
  bool get isPerAyahMode => _isPerAyahMode;
  int get currentAyahIndex => _currentAyahIndex;
  bool get isRepeatAyah => _isRepeatAyah;

  AudioProvider(this._handler) {
    _handler.onSkipToNext = () {
      if (_surahNameFn != null) playNextSurah(_surahNameFn!);
    };
    _handler.onSkipToPrevious = () {
      if (_surahNameFn != null) playPrevSurah(_surahNameFn!);
    };

    _initSession();

    _player.playerStateStream.listen((state) {
      final nowPlaying = state.playing;
      if (nowPlaying && _isPerAyahMode) _perAyahStarted = true;

      final rawLoading = state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering;
      final nowLoading = rawLoading && !(_isPerAyahMode && _perAyahStarted);

      bool changed = false;
      if (_isPlaying != nowPlaying) { _isPlaying = nowPlaying; changed = true; }
      if (_isLoading != nowLoading) { _isLoading = nowLoading; changed = true; }

      if (state.processingState == ProcessingState.completed) {
        _isPlaying = false;
        changed = true;
        if (_isRepeat) {
          Future.microtask(() {
            _player.seek(Duration.zero);
            _player.play();
          });
        } else if (canPlayNext && _surahNameFn != null && !_isAdvancing) {
          _isAdvancing = true;
          final fn = _surahNameFn!;
          Future.microtask(() => playNextSurah(fn));
        }
      }
      if (changed) notifyListeners();
    });

    _player.currentIndexStream.listen((index) {
      if (_isPerAyahMode && index != null) {
        if (_isRepeatAyah && _repeatAyahIndex >= 0 && index != _repeatAyahIndex) {
          _player.seek(Duration.zero, index: _repeatAyahIndex);
          return;
        }
        if (index != _currentAyahIndex) {
          _currentAyahIndex = index;
          notifyListeners();
        }
      }
    });

    _player.positionStream.listen((pos) {
      _position = pos;
      if ((pos - _lastNotifiedPosition).abs() >= const Duration(milliseconds: 200)) {
        _lastNotifiedPosition = pos;
        notifyListeners();
      }
    });

    _player.durationStream.listen((dur) {
      final newDur = dur ?? Duration.zero;
      if (newDur != _duration) {
        _duration = newDur;
        notifyListeners();
      }
    });

    _player.playbackEventStream.listen((_) {}, onError: (e, st) {
      debugPrint('Audio playback error: $e');
      _isLoading = false;
      _isPlaying = false;
      _errorMessage = 'Playback error. Tap retry.';
      notifyListeners();
    });
  }

  Future<void> _initSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (_) {}
  }

  Future<void> playSurah({
    required int surahNumber,
    required String surahName,
    required String reciterId,
    String? localPath,
    int? ayahCount,
    String Function(int)? surahNameFn,
    int? Function(int)? surahAyahCountFn,
  }) async {
    if (surahNameFn != null) _surahNameFn = surahNameFn;
    if (surahAyahCountFn != null) _surahAyahCountFn = surahAyahCountFn;
    _isAdvancing = false;
    _isLoading = true;
    _errorMessage = null;
    _isPerAyahMode = false;
    _currentAyahIndex = 0;
    _perAyahStarted = false;
    _isRepeatAyah = false;
    _repeatAyahIndex = -1;
    _currentSurahNumber = surahNumber;
    _currentSurahName = surahName;
    _position = Duration.zero;
    _lastNotifiedPosition = Duration.zero;
    _lastSurahNumber = surahNumber;
    _lastSurahName = surahName;
    _lastReciterId = reciterId;
    notifyListeners();

    try {
      final reciter = kReciters.firstWhere(
        (r) => r.id == reciterId,
        orElse: () => kReciters.first,
      );
      _currentReciter = reciter;
      _handler.updateNowPlaying(surahNumber, surahName, reciter.name);

      if (localPath != null) {
        await _player.setAudioSource(AudioSource.file(localPath));
      } else if (reciter.everyAyahPath != null && ayahCount != null && ayahCount > 0) {
        _isPerAyahMode = true;
        final children = List.generate(
          ayahCount,
          (i) => AudioSource.uri(Uri.parse(reciter.perAyahAudioUrl(surahNumber, i + 1))),
        );
        await _player.setAudioSource(ConcatenatingAudioSource(
          useLazyPreparation: true,
          children: children,
        ));
      } else {
        final url = reciter.audioUrl(surahNumber);
        debugPrint('Streaming: $url');
        await _player.setAudioSource(
          AudioSource.uri(Uri.parse(url)),
          preload: false,
        );
      }
      await _player.setSpeed(_speed);
      await _player.play();
    } catch (e) {
      debugPrint('playSurah error: $e');
      _isLoading = false;
      _isPlaying = false;
      _errorMessage = 'Failed to load audio. Tap retry.';
      notifyListeners();
    }
  }

  Future<void> playNextSurah(String Function(int) surahNameFn) async {
    if (!canPlayNext) return;
    final next = _currentSurahNumber! + 1;
    await playSurah(
      surahNumber: next,
      surahName: surahNameFn(next),
      reciterId: _lastReciterId ?? kReciters.first.id,
      ayahCount: _surahAyahCountFn?.call(next),
    );
  }

  Future<void> playPrevSurah(String Function(int) surahNameFn) async {
    if (!canPlayPrev) return;
    final prev = _currentSurahNumber! - 1;
    await playSurah(
      surahNumber: prev,
      surahName: surahNameFn(prev),
      reciterId: _lastReciterId ?? kReciters.first.id,
      ayahCount: _surahAyahCountFn?.call(prev),
    );
  }

  Future<void> retry() async {
    if (_lastSurahNumber == null) return;
    await playSurah(
      surahNumber: _lastSurahNumber!,
      surahName: _lastSurahName ?? '',
      reciterId: _lastReciterId ?? kReciters.first.id,
    );
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> playPause() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> skipForward() async {
    final target = _position + const Duration(seconds: 10);
    await _player.seek(target < _duration ? target : _duration);
  }

  Future<void> skipBackward() async {
    final target = _position - const Duration(seconds: 10);
    await _player.seek(target > Duration.zero ? target : Duration.zero);
  }

  Future<void> setSpeed(double speed) async {
    _speed = speed;
    await _player.setSpeed(speed);
    notifyListeners();
  }

  void toggleRepeat() {
    _isRepeat = !_isRepeat;
    notifyListeners();
  }

  void toggleRepeatAyah() {
    if (_isRepeatAyah) {
      _isRepeatAyah = false;
      _repeatAyahIndex = -1;
    } else {
      _isRepeatAyah = true;
      _repeatAyahIndex = _currentAyahIndex;
    }
    notifyListeners();
  }

  Future<void> stop() async {
    await _handler.stop();
    _currentSurahNumber = null;
    _currentSurahName = null;
    _isPlaying = false;
    _isLoading = false;
    _isPerAyahMode = false;
    _currentAyahIndex = 0;
    _isRepeatAyah = false;
    _repeatAyahIndex = -1;
    _errorMessage = null;
    notifyListeners();
  }

  void startSleepTimer(int minutes) {
    _isSleepTimerActive = true;
    notifyListeners();
    Future.delayed(Duration(minutes: minutes), () {
      if (_isSleepTimerActive) {
        _player.pause();
        _isSleepTimerActive = false;
        notifyListeners();
      }
    });
  }

  void cancelSleepTimer() {
    _isSleepTimerActive = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
