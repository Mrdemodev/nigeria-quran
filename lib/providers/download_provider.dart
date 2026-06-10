import 'package:flutter/material.dart';
import '../services/download_service.dart';
import '../data/reciters_data.dart';

class DownloadProvider extends ChangeNotifier {
  final _service = DownloadService();

  // Keys: "${surahNumber}_$reciterId"
  final Map<String, bool> _downloaded = {};
  final Map<int, double> _progress = {}; // surahNumber → 0..1 (in-flight)
  String _currentReciterId = 'alafasy';

  Map<int, double> get progress => Map.unmodifiable(_progress);
  bool isDownloading(int surahNumber) => _progress.containsKey(surahNumber);
  bool isDownloaded(int surahNumber, String reciterId) =>
      _downloaded['${surahNumber}_$reciterId'] ?? false;
  String get currentReciterId => _currentReciterId;

  Future<void> init(String reciterId) async {
    _currentReciterId = reciterId;
    await _refreshStatus(reciterId);
  }

  /// Call after switching reciters so the UI reflects the new reciter's downloads.
  Future<void> switchReciter(String reciterId) async {
    if (_currentReciterId == reciterId) return;
    _currentReciterId = reciterId;
    await _refreshStatus(reciterId);
  }

  Future<void> _refreshStatus(String reciterId) async {
    for (int i = 1; i <= 114; i++) {
      final key = '${i}_$reciterId';
      _downloaded[key] = await _service.isDownloaded(i, reciterId);
    }
    notifyListeners();
  }

  Future<void> download(int surahNumber, String reciterId, String url) async {
    if (_progress.containsKey(surahNumber)) return;
    final key = '${surahNumber}_$reciterId';
    _progress[surahNumber] = 0.0;
    _downloaded[key] = false;
    notifyListeners();

    await _service.download(
      surahNumber: surahNumber,
      reciterId: reciterId,
      url: url,
      onProgress: (p) {
        _progress[surahNumber] = p;
        notifyListeners();
      },
      onComplete: (_) {
        _progress.remove(surahNumber);
        _downloaded[key] = true;
        notifyListeners();
      },
      onError: (_) {
        _progress.remove(surahNumber);
        _downloaded[key] = false;
        notifyListeners();
      },
    );
  }

  void cancelDownload(int surahNumber) {
    _service.cancelDownload(surahNumber);
    _progress.remove(surahNumber);
    notifyListeners();
  }

  Future<void> deleteDownload(int surahNumber, String reciterId) async {
    await _service.deleteDownload(surahNumber, reciterId);
    _downloaded['${surahNumber}_$reciterId'] = false;
    notifyListeners();
  }

  Future<String?> localPath(int surahNumber, String reciterId) async {
    if (!isDownloaded(surahNumber, reciterId)) return null;
    return _service.filePath(surahNumber, reciterId);
  }

  Future<String> formattedStorageUsed() async {
    final bytes = await _service.totalDownloadedBytes();
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> deleteAll(String reciterId) async {
    await _service.deleteAllDownloads();
    _downloaded.removeWhere((k, _) => k.endsWith('_$reciterId'));
    notifyListeners();
  }

  bool get isBulkDownloading => _progress.isNotEmpty;

  Future<void> downloadAll(String reciterId) async {
    final reciter = kReciters.firstWhere(
      (r) => r.id == reciterId,
      orElse: () => kReciters.first,
    );
    for (int i = 1; i <= 114; i++) {
      if (!isDownloaded(i, reciterId) && !isDownloading(i)) {
        final url = reciter.audioUrl(i);
        download(i, reciterId, url);
        // Small stagger to avoid hammering the server
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }
  }

  void cancelAll() {
    final keys = List<int>.from(_progress.keys);
    for (final surahNum in keys) {
      _service.cancelDownload(surahNum);
    }
    _progress.clear();
    notifyListeners();
  }
}
