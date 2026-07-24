import 'dart:io';

import 'package:archive/archive.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa_onnx;

/// Offline neural German TTS using Piper (sherpa-onnx).
///
/// Model: de_DE-dii-high-int8 (~20 MB, downloaded once).
class OfflinePiperTts {
  OfflinePiperTts._();
  static final OfflinePiperTts instance = OfflinePiperTts._();

  static const _modelArchiveName = 'vits-piper-de_DE-dii-high-int8.tar.bz2';
  static const _modelDirName = 'vits-piper-de_DE-dii-high-int8';
  static const _modelOnnxName = 'de_DE-dii-high-int8.onnx';
  static const _modelUrl =
      'https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/$_modelArchiveName';

  final AudioPlayer _player = AudioPlayer();

  sherpa_onnx.OfflineTts? _tts;
  bool _bindingsReady = false;
  bool _isDownloading = false;
  double? _downloadProgress;
  String? _statusMessage;
  void Function()? _completionHandler;
  String? _currentWavePath;
  bool _playerListenerAttached = false;

  bool get isSupported => Platform.isAndroid || Platform.isIOS;
  bool get isReady => _tts != null;
  bool get isDownloading => _isDownloading;
  double? get downloadProgress => _downloadProgress;
  String? get statusMessage => _statusMessage;

  Future<Directory> _supportDir() async => getApplicationSupportDirectory();

  Future<String> _modelRoot() async {
    final dir = await _supportDir();
    return p.join(dir.path, _modelDirName);
  }

  Future<bool> _modelFilesExist() async {
    final root = await _modelRoot();
    final onnx = File(p.join(root, _modelOnnxName));
    final tokens = File(p.join(root, 'tokens.txt'));
    final dataDir = Directory(p.join(root, 'espeak-ng-data'));
    return onnx.existsSync() && tokens.existsSync() && dataDir.existsSync();
  }

  Future<void> ensureReady({void Function(double progress)? onProgress}) async {
    if (!isSupported) return;
    if (_tts != null) return;

    if (!await _modelFilesExist()) {
      await _downloadAndExtract(onProgress: onProgress);
    }

    await _initEngine();
  }

  Future<void> _downloadAndExtract({
    void Function(double progress)? onProgress,
  }) async {
    if (_isDownloading) return;
    _isDownloading = true;
    _downloadProgress = 0;
    _statusMessage = 'Sprachmodell wird heruntergeladen …';

    try {
      final support = await _supportDir();
      final archivePath = p.join(support.path, _modelArchiveName);
      final archiveFile = File(archivePath);

      if (!archiveFile.existsSync()) {
        final request = http.Request('GET', Uri.parse(_modelUrl));
        final response = await request.send().timeout(const Duration(minutes: 10));
        if (response.statusCode != 200) {
          throw HttpException('Download fehlgeschlagen (${response.statusCode})');
        }

        final total = response.contentLength ?? 0;
        var received = 0;
        final sink = archiveFile.openWrite();
        await for (final chunk in response.stream) {
          received += chunk.length;
          sink.add(chunk);
          final progress = total > 0 ? received / total : 0.0;
          _downloadProgress = progress.toDouble();
          onProgress?.call(progress.toDouble());
        }
        await sink.close();
      } else {
        _downloadProgress = 1;
        onProgress?.call(1);
      }

      _statusMessage = 'Sprachmodell wird entpackt …';
      final compressed = await archiveFile.readAsBytes();
      final tarBytes = BZip2Decoder().decodeBytes(compressed);
      final archive = TarDecoder().decodeBytes(tarBytes);

      for (final entry in archive) {
        if (!entry.isFile) continue;
        final outPath = p.join(support.path, entry.name);
        final outFile = File(outPath);
        await outFile.parent.create(recursive: true);
        await outFile.writeAsBytes(entry.content as List<int>);
      }

      _statusMessage = 'Sprachmodell bereit';
      _downloadProgress = 1;
    } finally {
      _isDownloading = false;
    }
  }

  Future<void> _initEngine() async {
    if (_tts != null) return;

    if (!_bindingsReady) {
      sherpa_onnx.initBindings();
      _bindingsReady = true;
    }

    final root = await _modelRoot();
    final modelPath = p.join(root, _modelOnnxName);
    final tokensPath = p.join(root, 'tokens.txt');
    final dataDir = p.join(root, 'espeak-ng-data');

    final config = sherpa_onnx.OfflineTtsConfig(
      model: sherpa_onnx.OfflineTtsModelConfig(
        vits: sherpa_onnx.OfflineTtsVitsModelConfig(
          model: modelPath,
          tokens: tokensPath,
          dataDir: dataDir,
        ),
        numThreads: 2,
        debug: false,
        provider: 'cpu',
      ),
      maxNumSenetences: 1,
    );

    _tts = sherpa_onnx.OfflineTts(config);
    _statusMessage = 'Offline-Stimme aktiv (Piper Neural)';
    debugPrint('OfflinePiperTts: engine ready');
  }

  Future<bool> speak(String text, {double speed = 1.0}) async {
    if (!isSupported || text.trim().isEmpty) return false;

    try {
      await ensureReady();
      final tts = _tts;
      if (tts == null) return false;

      await stop();

      final audio = tts.generateWithConfig(
        text: text,
        config: sherpa_onnx.OfflineTtsGenerationConfig(
          sid: 0,
          speed: speed.clamp(0.5, 2.0),
          silenceScale: 0.2,
        ),
      );

      final wavePath = p.join(
        (await _supportDir()).path,
        'tts-${DateTime.now().millisecondsSinceEpoch}.wav',
      );

      final ok = sherpa_onnx.writeWave(
        filename: wavePath,
        samples: audio.samples,
        sampleRate: audio.sampleRate,
      );
      if (!ok) return false;

      _currentWavePath = wavePath;
      await _player.play(DeviceFileSource(wavePath));
      return true;
    } catch (e) {
      debugPrint('OfflinePiperTts.speak error: $e');
      _statusMessage = 'Offline-Stimme nicht verfügbar';
      return false;
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _deleteTempWave();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  void setCompletionHandler(void Function()? handler) {
    _completionHandler = handler;
    if (_playerListenerAttached) return;
    _playerListenerAttached = true;
    _player.onPlayerComplete.listen((_) {
      _deleteTempWave();
      _completionHandler?.call();
    });
  }

  void _deleteTempWave() {
    final path = _currentWavePath;
    if (path == null) return;
    try {
      final file = File(path);
      if (file.existsSync()) file.deleteSync();
    } catch (_) {}
    _currentWavePath = null;
  }

  void dispose() {
    _tts?.free();
    _tts = null;
    _player.dispose();
  }
}
