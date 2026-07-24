/// Web/desktop stub: offline neural TTS is not available on this platform.
class OfflinePiperTts {
  OfflinePiperTts._();
  static final OfflinePiperTts instance = OfflinePiperTts._();

  bool get isSupported => false;
  bool get isReady => false;
  bool get isDownloading => false;
  double? get downloadProgress => null;
  String? get statusMessage => 'Nur auf Android/iOS verfügbar';

  Future<void> ensureReady({void Function(double progress)? onProgress}) async {}

  Future<bool> speak(String text, {double speed = 1.0}) async => false;

  Future<void> stop() async {}

  Future<void> pause() async {}

  void setCompletionHandler(void Function()? handler) {}

  void dispose() {}
}
