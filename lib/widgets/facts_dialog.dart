import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Ein einzelner Fakt; «Weiter» als breite FilledButton-Leiste unten (kein Text-Link).
class FactsDialog extends StatefulWidget {
  final String fact;

  const FactsDialog({super.key, required this.fact});

  @override
  State<FactsDialog> createState() => _FactsDialogState();
}

class _FactsDialogState extends State<FactsDialog> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('de-DE');
    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isPlaying = false;
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

  Future<void> _togglePlayPause() async {
    final text = widget.fact;
    if (_isPlaying && !_isPaused) {
      await _flutterTts.pause();
      setState(() {
        _isPaused = true;
      });
    } else if (_isPlaying && _isPaused) {
      await _flutterTts.speak(text);
      setState(() {
        _isPaused = false;
      });
    } else {
      await _flutterTts.setLanguage('de-DE');
      await _flutterTts.speak(text);
      setState(() {
        _isPlaying = true;
        _isPaused = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);
    final maxW = math.min(520.0, size.width - 24);
    final maxH = math.min(520.0, size.height * 0.78);

    return Dialog(
      insetPadding: EdgeInsets.fromLTRB(12, 16, 12, math.max(16, pad.bottom + 8)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW, maxHeight: maxH),
        child: SafeArea(
          minimum: const EdgeInsets.all(4),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Interessant, dass …',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    IconButton(
                      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        _isPlaying && !_isPaused
                            ? Icons.pause_circle_filled
                            : Icons.volume_up,
                        size: 30,
                        color: Colors.blue,
                      ),
                      onPressed: _togglePlayPause,
                      tooltip:
                          _isPlaying && !_isPaused ? 'Pause' : 'Vorlesen',
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(right: 6, bottom: 4),
                      child: Text(
                        widget.fact,
                        style: const TextStyle(
                          fontSize: 17,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
