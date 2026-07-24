import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/tts_service.dart';

/// Dialog mit scrollbarem Text, Vorlesen und optionalem Titel.
class FactsDialog extends StatefulWidget {
  final String text;
  final String title;

  /// TTS wurde schon vor dem Öffnen gestartet (Überlappung mit Antwort-Feedback).
  final bool speechAlreadyStarted;

  const FactsDialog({
    super.key,
    required this.text,
    this.title = 'Interessant, dass …',
    this.speechAlreadyStarted = false,
  });

  const FactsDialog.fact({
    super.key,
    required this.text,
    this.title = 'Interessant, dass …',
    this.speechAlreadyStarted = false,
  });

  const FactsDialog.explanation({
    super.key,
    required this.text,
    this.speechAlreadyStarted = false,
  }) : title = 'Erklärung';

  static const autoReadPrefKey = 'quiz.auto_read_dialogs';
  static bool? _cachedAutoRead;

  static Future<bool> isAutoReadEnabled() async {
    if (_cachedAutoRead != null) return _cachedAutoRead!;
    final prefs = await SharedPreferences.getInstance();
    _cachedAutoRead = prefs.getBool(autoReadPrefKey) ?? false;
    return _cachedAutoRead!;
  }

  static Future<void> setAutoReadEnabled(bool enabled) async {
    _cachedAutoRead = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(autoReadPrefKey, enabled);
  }

  @override
  State<FactsDialog> createState() => _FactsDialogState();
}

class _FactsDialogState extends State<FactsDialog> {
  final ScrollController _scrollController = ScrollController();
  bool _isPlaying = false;
  bool _isPaused = false;
  bool _autoReadEnabled = false;
  double _speechRate = TtsService.defaultSpeechRate;

  @override
  void initState() {
    super.initState();
    if (widget.speechAlreadyStarted) {
      _isPlaying = true;
      _autoReadEnabled = true;
      FactsDialog._cachedAutoRead = true;
    } else {
      _autoReadEnabled = FactsDialog._cachedAutoRead ?? false;
    }
    _speechRate = TtsService.instance.speechRate;
    _wireTts();
  }

  Future<void> _wireTts() async {
    await TtsService.instance.initialize();
    if (!mounted) return;
    setState(() => _speechRate = TtsService.instance.speechRate);
    TtsService.instance.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _isPaused = false;
        });
      }
    });

    if (widget.speechAlreadyStarted) return;

    final enabled = await FactsDialog.isAutoReadEnabled();
    if (!mounted) return;
    setState(() => _autoReadEnabled = enabled);
    if (enabled) {
      // UI sofort als „spielt“ markieren, während Piper noch synthesisiert.
      setState(() {
        _isPlaying = true;
        _isPaused = false;
      });
      await _startPlayback(restart: false);
    }
  }

  Future<void> _setAutoReadEnabled(bool enabled) async {
    setState(() => _autoReadEnabled = enabled);
    await FactsDialog.setAutoReadEnabled(enabled);
    if (enabled) {
      setState(() {
        _isPlaying = true;
        _isPaused = false;
      });
      await _startPlayback(restart: true);
    } else {
      await TtsService.instance.stop();
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _isPaused = false;
        });
      }
    }
  }

  Future<void> _startPlayback({bool restart = true}) async {
    try {
      if (restart) await TtsService.instance.stop();
      await TtsService.instance.speak(widget.text);
      if (!mounted) return;
      setState(() {
        _isPlaying = true;
        _isPaused = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _isPaused = false;
        });
      }
    }
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying && !_isPaused) {
      await TtsService.instance.pause();
      setState(() => _isPaused = true);
    } else if (_isPlaying && _isPaused) {
      setState(() => _isPaused = false);
      await _startPlayback(restart: true);
    } else {
      setState(() {
        _isPlaying = true;
        _isPaused = false;
      });
      await _startPlayback(restart: true);
    }
  }

  Future<void> _onSpeechRateChanged(double value) async {
    setState(() => _speechRate = value);
    await TtsService.instance.setSpeechRate(value);
    if (_isPlaying && !_isPaused) {
      setState(() {
        _isPlaying = true;
        _isPaused = false;
      });
      await _startPlayback(restart: true);
    }
  }

  String get _speechRateLabel {
    if (_speechRate == TtsService.defaultSpeechRate) return 'Normal';
    if (_speechRate < TtsService.defaultSpeechRate) return 'Langsam';
    return 'Schnell';
  }

  TextStyle get _bodyStyle {
    return const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      height: 1.28,
    );
  }

  Widget _buildSpeechSettingsPanel() {
    return Material(
      elevation: 1,
      color: Colors.blue.shade50,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.settings, size: 22, color: Colors.blue.shade800),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Einstellungen · Geschwindigkeit',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  _speechRateLabel,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Slider(
              value: _speechRate,
              min: 0.35,
              max: 1.4,
              divisions: 21,
              label: _speechRate.toStringAsFixed(2),
              onChanged: (v) => setState(() => _speechRate = v),
              onChangeEnd: _onSpeechRateChanged,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: ColoredBox(
        color: Colors.white,
        child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(right: 4, bottom: 2),
                    child: Text(
                      widget.text,
                      style: _bodyStyle,
                      softWrap: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                    icon: Icon(
                      _isPlaying && !_isPaused
                          ? Icons.pause_circle_filled
                          : Icons.volume_up,
                      size: 36,
                      color: Colors.blue,
                    ),
                    onPressed: _togglePlayPause,
                    tooltip: _isPlaying && !_isPaused ? 'Pause' : 'Vorlesen',
                  ),
                  Expanded(
                    child: Text(
                      'Automatisch vorlesen',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                  Switch(
                    value: _autoReadEnabled,
                    onChanged: _setAutoReadEnabled,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _buildSpeechSettingsPanel(),
              const SizedBox(height: 10),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Weiter'),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
