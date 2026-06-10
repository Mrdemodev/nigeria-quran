import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

typedef ProgressCallback = void Function(double progress);

class DownloadService {
  static final DownloadService _instance = DownloadService._();
  factory DownloadService() => _instance;
  DownloadService._();

  // Active download clients (surahNumber → client) so we can cancel
  final Map<int, HttpClient> _activeClients = {};

  Future<Directory> get _dir async {
    final base = await getApplicationDocumentsDirectory();
    final d = Directory('${base.path}/quran_audio');
    if (!await d.exists()) await d.create(recursive: true);
    return d;
  }

  String _filename(int surahNumber, String reciterId) =>
      '${surahNumber.toString().padLeft(3, '0')}_$reciterId.mp3';

  Future<String> filePath(int surahNumber, String reciterId) async {
    final d = await _dir;
    return '${d.path}/${_filename(surahNumber, reciterId)}';
  }

  Future<bool> isDownloaded(int surahNumber, String reciterId) async {
    final path = await filePath(surahNumber, reciterId);
    return File(path).exists();
  }

  Future<void> download({
    required int surahNumber,
    required String reciterId,
    required String url,
    required ProgressCallback onProgress,
    required void Function(String path) onComplete,
    required void Function(String error) onError,
  }) async {
    if (_activeClients.containsKey(surahNumber)) return;

    final client = HttpClient();
    _activeClients[surahNumber] = client;

    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final total = response.contentLength;
      final path = await filePath(surahNumber, reciterId);
      final file = File(path);
      final sink = file.openWrite();

      int received = 0;
      await for (final chunk in response) {
        sink.add(chunk);
        received += chunk.length;
        if (total > 0) onProgress(received / total);
      }
      await sink.flush();
      await sink.close();

      _activeClients.remove(surahNumber);
      onComplete(path);
    } catch (e) {
      _activeClients.remove(surahNumber);
      // Clean up partial file
      try {
        final path = await filePath(surahNumber, reciterId);
        final f = File(path);
        if (await f.exists()) await f.delete();
      } catch (_) {}
      onError(e.toString());
    } finally {
      client.close();
    }
  }

  void cancelDownload(int surahNumber) {
    _activeClients[surahNumber]?.close(force: true);
    _activeClients.remove(surahNumber);
  }

  Future<void> deleteDownload(int surahNumber, String reciterId) async {
    final path = await filePath(surahNumber, reciterId);
    final f = File(path);
    if (await f.exists()) await f.delete();
  }

  Future<int> totalDownloadedBytes() async {
    try {
      final d = await _dir;
      int total = 0;
      await for (final entity in d.list()) {
        if (entity is File) total += await entity.length();
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  Future<void> deleteAllDownloads() async {
    final d = await _dir;
    if (await d.exists()) await d.delete(recursive: true);
  }
}
