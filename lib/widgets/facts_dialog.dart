import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class FactsDialog extends StatefulWidget {
  final List<String> facts;
  final List<String> factsTranslated;

  const FactsDialog({
    super.key,
    required this.facts,
    required this.factsTranslated,
  });

  @override
  State<FactsDialog> createState() => _FactsDialogState();
}

class _FactsDialogState extends State<FactsDialog> {
  bool _isRussian = false;
  final FlutterTts _flutterTts = FlutterTts();
  int? _playingIndex;
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
          _playingIndex = null;
          _isPaused = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  List<String> get currentFacts {
    return _isRussian ? widget.factsTranslated : widget.facts;
  }

  Future<void> _togglePlayPause(int index) async {
    if (_playingIndex == index && !_isPaused) {
      // Pause
      await _flutterTts.pause();
      setState(() {
        _isPaused = true;
      });
    } else if (_playingIndex == index && _isPaused) {
      // Resume
      await _flutterTts.speak(currentFacts[index]);
      setState(() {
        _isPaused = false;
      });
    } else {
      // Stop previous and start new
      if (_playingIndex != null) {
        await _flutterTts.stop();
      }
      await _flutterTts.setLanguage(_isRussian ? 'ru-RU' : 'de-DE');
      await _flutterTts.speak(currentFacts[index]);
      setState(() {
        _playingIndex = index;
        _isPaused = false;
      });
    }
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isRussian ? 'Интересные' : 'Interessante',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _isRussian ? 'факты' : 'Fakten',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.translate),
                  color: Colors.blue,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () async {
                    if (_playingIndex != null) {
                      await _flutterTts.stop();
                    }
                    setState(() {
                      _isRussian = !_isRussian;
                      _playingIndex = null;
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
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: currentFacts.length,
                itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              IconButton(
                                icon: Icon(
                                  _playingIndex == index && !_isPaused
                                      ? Icons.pause
                                      : Icons.volume_up,
                                  size: 20,
                                  color: Colors.blue,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => _togglePlayPause(index),
                                tooltip: _playingIndex == index && !_isPaused
                                    ? 'Pause'
                                    : 'Vorlesen',
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              currentFacts[index],
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                },
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(_isRussian ? 'Закрыть' : 'Schließen'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

