import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'offline_piper_tts.dart';

/// Which TTS engine is currently active.
enum TtsEngine { offlinePiper, serverApi, systemVoice }

/// Singleton TTS service with platform-aware fallback chain.
///
/// Priority on Android/iOS:
///   1. Offline Piper neural voice (de_DE-dii-high, fully offline after download)
///   2. System voice via flutter_tts
///
/// Priority on Web:
///   1. Vercel serverless function at [same-origin]/api/tts
///      → Microsoft de-DE-KatjaNeural
///   2. Web Speech API via flutter_tts (browser/OS built-in voice)
class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();

  static const _prefVoiceName = 'tts.voice_name';
  static const _prefVoiceLocale = 'tts.voice_locale';
  static const _prefSpeechRate = 'tts.speech_rate';
  static const _prefPitch = 'tts.pitch';
  static const _prefUseOfflinePiper = 'tts.use_offline_piper';

  final FlutterTts _systemTts = FlutterTts();
  final AudioPlayer _player = AudioPlayer();

  bool _initialized = false;
  Map<String, String>? _activeSystemVoice;
  static const defaultSpeechRate = 0.68;

  double _speechRate = defaultSpeechRate;
  double _pitch = 1.0;
  bool _useOfflinePiper = true;

  bool? _apiAvailable;
  DateTime? _lastPingTime;
  TtsEngine _lastEngine = TtsEngine.systemVoice;

  void Function()? _completionHandler;

  Map<String, String>? get activeWebVoice => _activeSystemVoice;
  double get speechRate => _speechRate;
  double get pitch => _pitch;
  bool? get apiAvailable => _apiAvailable;
  TtsEngine get lastEngine => _lastEngine;
  bool get useOfflinePiper => _useOfflinePiper;
  bool get offlinePiperSupported => OfflinePiperTts.instance.isSupported;
  bool get offlinePiperReady => OfflinePiperTts.instance.isReady;
  bool get offlinePiperDownloading => OfflinePiperTts.instance.isDownloading;
  double? get offlinePiperDownloadProgress =>
      OfflinePiperTts.instance.downloadProgress;
  String? get offlinePiperStatus => OfflinePiperTts.instance.statusMessage;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    final prefs = await SharedPreferences.getInstance();
    _speechRate = prefs.getDouble(_prefSpeechRate) ?? defaultSpeechRate;
    _pitch = prefs.getDouble(_prefPitch) ?? 1.0;
    _useOfflinePiper = prefs.getBool(_prefUseOfflinePiper) ??
        OfflinePiperTts.instance.isSupported;

    await _systemTts.setLanguage('de-DE');
    await _systemTts.setSpeechRate(_speechRate);
    await _systemTts.setPitch(_pitch);
    await _systemTts.setVolume(1.0);
    _systemTts.setCompletionHandler(() => _completionHandler?.call());

    _player.onPlayerComplete.listen((_) {
      if (_lastEngine == TtsEngine.serverApi) _completionHandler?.call();
    });

    OfflinePiperTts.instance.setCompletionHandler(() {
      _completionHandler?.call();
    });

    final savedName = prefs.getString(_prefVoiceName);
    final savedLocale = prefs.getString(_prefVoiceLocale);
    if (savedName != null && savedLocale != null) {
      unawaited(_applySystemVoice({'name': savedName, 'locale': savedLocale}));
    } else {
      unawaited(_autoSelectBestVoice());
    }

    if (kIsWeb) {
      unawaited(pingApi());
    } else if (_useOfflinePiper && OfflinePiperTts.instance.isSupported) {
      unawaited(OfflinePiperTts.instance.ensureReady());
    }
  }

  Future<void> speak(String text) async {
    await _ensureInit();
    await stop();

    if (!kIsWeb && _useOfflinePiper) {
      final ok = await OfflinePiperTts.instance.speak(
        text,
        speed: _mapRateToPiperSpeed(_speechRate),
      );
      if (ok) {
        _lastEngine = TtsEngine.offlinePiper;
        return;
      }
    }

    if (kIsWeb && await _tryServerApi(text)) return;

    _lastEngine = TtsEngine.systemVoice;
    await _systemTts.speak(text);
  }

  Future<void> speakWithWebVoice(String text) async {
    await _ensureInit();
    await stop();
    _lastEngine = TtsEngine.systemVoice;
    await _systemTts.speak(text);
  }

  Future<void> speakWithOfflinePiper(String text) async {
    await _ensureInit();
    await stop();
    final ok = await OfflinePiperTts.instance.speak(
      text,
      speed: _mapRateToPiperSpeed(_speechRate),
    );
    if (ok) _lastEngine = TtsEngine.offlinePiper;
  }

  Future<void> ensureOfflinePiperReady({
    void Function(double progress)? onProgress,
  }) async {
    await _ensureInit();
    await OfflinePiperTts.instance.ensureReady(onProgress: onProgress);
  }

  Future<void> setUseOfflinePiper(bool value) async {
    _useOfflinePiper = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefUseOfflinePiper, value);
    if (value && OfflinePiperTts.instance.isSupported) {
      unawaited(OfflinePiperTts.instance.ensureReady());
    }
  }

  Future<void> stop() async {
    await _systemTts.stop();
    await _player.stop();
    await OfflinePiperTts.instance.stop();
  }

  Future<void> pause() async {
    if (_lastEngine == TtsEngine.serverApi) {
      await _player.pause();
    } else if (_lastEngine == TtsEngine.offlinePiper) {
      await OfflinePiperTts.instance.pause();
    } else {
      await _systemTts.pause();
    }
  }

  void setCompletionHandler(void Function() handler) {
    _completionHandler = handler;
  }

  Future<bool> pingApi() async {
    if (!kIsWeb) {
      _apiAvailable = false;
      return false;
    }
    try {
      final resp = await http
          .get(_apiUri())
          .timeout(const Duration(milliseconds: 1500));
      _apiAvailable = resp.statusCode == 200;
    } catch (_) {
      _apiAvailable = false;
    }
    _lastPingTime = DateTime.now();
    return _apiAvailable!;
  }

  Future<List<Map<String, String>>> getGermanVoices() async {
    await _ensureInit();
    try {
      final all = await _systemTts.getVoices as List<dynamic>;
      final de = all
          .cast<Map>()
          .where((v) =>
              (v['locale'] ?? '').toString().toLowerCase().startsWith('de'))
          .map((v) => {
                'name': v['name']?.toString() ?? '',
                'locale': v['locale']?.toString() ?? 'de-DE',
              })
          .where((v) => v['name']!.isNotEmpty)
          .toList();
      de.sort((a, b) => _voiceScore(b['name']!) - _voiceScore(a['name']!));
      return de;
    } catch (_) {
      return [];
    }
  }

  Future<void> setWebVoice(Map<String, String> voice) async {
    await _applySystemVoice(voice);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefVoiceName, voice['name']!);
    await prefs.setString(_prefVoiceLocale, voice['locale'] ?? 'de-DE');
  }

  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate;
    await _systemTts.setSpeechRate(rate);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefSpeechRate, rate);
  }

  Future<void> setPitch(double p) async {
    _pitch = p;
    await _systemTts.setPitch(p);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefPitch, p);
  }

  Future<void> _ensureInit() async {
    if (!_initialized) await initialize();
  }

  Uri _apiUri({Map<String, String>? queryParameters}) {
    final b = Uri.base;
    return Uri(
      scheme: b.scheme,
      host: b.host,
      port: b.hasPort ? b.port : null,
      path: '/api/tts',
      queryParameters: queryParameters,
    );
  }

  Future<bool> _tryServerApi(String text) async {
    if (_apiAvailable == false && _lastPingTime != null) {
      if (DateTime.now().difference(_lastPingTime!) <
          const Duration(seconds: 30)) {
        return false;
      }
    }

    if (_apiAvailable != true) {
      final ok = await pingApi();
      if (!ok) return false;
    }

    try {
      final uri = _apiUri(queryParameters: {
        'text': text,
        'voice': 'de-DE-KatjaNeural',
      });
      await _player.play(UrlSource(uri.toString()));
      _lastEngine = TtsEngine.serverApi;
      return true;
    } catch (e) {
      debugPrint('TtsService: /api/tts error: $e');
      _apiAvailable = false;
      _lastPingTime = DateTime.now();
      return false;
    }
  }

  Future<void> _autoSelectBestVoice() async {
    List<Map<String, String>> voices = [];
    for (var i = 0; i < 3; i++) {
      voices = await getGermanVoices();
      if (voices.isNotEmpty) break;
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    if (voices.isNotEmpty) {
      await _applySystemVoice(voices.first);
      debugPrint('TtsService: system voice → "${voices.first['name']}"');
    }
  }

  Future<void> _applySystemVoice(Map<String, String> voice) async {
    try {
      await _systemTts.setVoice(voice);
      _activeSystemVoice = voice;
    } catch (e) {
      debugPrint('TtsService: setVoice failed: $e');
    }
  }

  double _mapRateToPiperSpeed(double rate) {
    // flutter_tts [defaultSpeechRate] ≈ normal; Piper uses 1.0 as normal.
    return (rate / defaultSpeechRate).clamp(0.35, 2.0);
  }

  int _voiceScore(String name) {
    final n = name.toLowerCase();
    if (n.contains('natural')) return 100;
    if (n.contains('online') && (n.contains('katja') || n.contains('conrad'))) {
      return 80;
    }
    if (n.contains('online')) return 60;
    if (n == 'anna' || n.startsWith('anna ')) return 75;
    if (n == 'markus' || n.startsWith('markus ')) return 55;
    if (n == 'yannick' || n.startsWith('yannick ')) return 50;
    if (n == 'helena' || n.startsWith('helena ')) return 45;
    if (n.contains('google')) return 40;
    if (n.contains('katja') || n.contains('conrad')) return 30;
    return 10;
  }
}

void unawaited(Future<void> future) => future.ignore();
