import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/tts_service.dart';

class ExplanationDialog extends StatefulWidget {
  final String explanation;
  final String explanationTranslated;

  const ExplanationDialog({
    super.key,
    required this.explanation,
    required this.explanationTranslated,
  });

  @override
  State<ExplanationDialog> createState() => _ExplanationDialogState();
}

class _ExplanationDialogState extends State<ExplanationDialog> {
  static const _autoReadPrefKey = 'quiz.auto_read_dialogs';

  final ScrollController _scrollController = ScrollController();
  bool _isPlaying = false;
  bool _isPaused = false;
  bool _autoReadEnabled = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadAutoReadPreference();
  }

  Future<void> _initTts() async {
    await TtsService.instance.initialize();
    TtsService.instance.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _isPaused = false;
        });
      }
    });
  }

  Future<void> _loadAutoReadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getBool(_autoReadPrefKey) ?? false;
    if (!mounted) return;
    setState(() => _autoReadEnabled = value);
    if (value) await _startPlayback();
  }

  Future<void> _setAutoReadEnabled(bool enabled) async {
    setState(() => _autoReadEnabled = enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoReadPrefKey, enabled);
    if (enabled) await _startPlayback();
  }

  Future<void> _startPlayback() async {
    await TtsService.instance.stop();
    try {
      await TtsService.instance.speak(widget.explanation);
      if (!mounted) return;
      setState(() {
        _isPlaying = true;
        _isPaused = false;
      });
    } catch (_) {
      // Safari may block autoplay without a user gesture – silently ignore.
    }
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying && !_isPaused) {
      await TtsService.instance.pause();
      setState(() => _isPaused = true);
    } else if (_isPlaying && _isPaused) {
      await _startPlayback();
      setState(() => _isPaused = false);
    } else {
      await _startPlayback();
    }
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);
    final maxW = math.min(480.0, size.width - 16);
    final maxH = math.min(520.0, size.height * 0.72);

    return Dialog(
      insetPadding: EdgeInsets.fromLTRB(8, 12, 8, math.max(8, pad.bottom + 4)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW, maxHeight: maxH),
        child: SafeArea(
          minimum: const EdgeInsets.all(2),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Text(
                        'Erklärung',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        _isPlaying && !_isPaused
                            ? Icons.pause_circle_filled
                            : Icons.volume_up,
                        size: 28,
                        color: Colors.blue,
                      ),
                      onPressed: _togglePlayPause,
                      tooltip: _isPlaying && !_isPaused ? 'Pause' : 'Vorlesen',
                    ),
                    const SizedBox(width: 4),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Automatisch vorlesen',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Switch(
                          value: _autoReadEnabled,
                          onChanged: _setAutoReadEnabled,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(right: 4, bottom: 2),
                      child: Text(
                        widget.explanation,
                        style: const TextStyle(fontSize: 15, height: 1.35),
                        softWrap: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(42),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Schließen'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
