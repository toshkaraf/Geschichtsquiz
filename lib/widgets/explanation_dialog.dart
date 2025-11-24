import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

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
  bool _isRussian = false;
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage(_isRussian ? 'ru-RU' : 'de-DE');
    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _isPaused = false;
        });
      }
    });
  }

  String get currentExplanation {
    return _isRussian ? widget.explanationTranslated : widget.explanation;
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying && !_isPaused) {
      // Pause
      await _flutterTts.pause();
      setState(() {
        _isPaused = true;
      });
    } else if (_isPlaying && _isPaused) {
      // Resume
      await _flutterTts.speak(currentExplanation);
      setState(() {
        _isPaused = false;
      });
    } else {
      // Start
      await _flutterTts.setLanguage(_isRussian ? 'ru-RU' : 'de-DE');
      await _flutterTts.speak(currentExplanation);
      setState(() {
        _isPlaying = true;
        _isPaused = false;
      });
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _isRussian ? 'Объяснение' : 'Erklärung',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.translate),
                  color: Colors.blue,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () async {
                    if (_isPlaying) {
                      await _flutterTts.stop();
                    }
                    setState(() {
                      _isRussian = !_isRussian;
                      _isPlaying = false;
                      _isPaused = false;
                    });
                    await _initTts();
                  },
                  tooltip: _isRussian ? 'На немецкий' : 'На русский',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  currentExplanation,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    _isPlaying && !_isPaused
                        ? Icons.pause
                        : Icons.volume_up,
                    size: 32,
                    color: Colors.blue,
                  ),
                  onPressed: _togglePlayPause,
                  tooltip: _isPlaying && !_isPaused
                      ? 'Pause'
                      : 'Vorlesen',
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(_isRussian ? 'Закрыть' : 'Schließen'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

