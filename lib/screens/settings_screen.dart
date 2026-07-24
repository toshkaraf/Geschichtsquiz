import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/quiz_question.dart';
import '../services/question_service.dart';
import '../services/tts_service.dart';

class SettingsScreen extends StatefulWidget {
  final List<QuizQuestion> allQuestions;
  final Function(List<QuizQuestion>) onFiltersChanged;

  const SettingsScreen({
    super.key,
    required this.allQuestions,
    required this.onFiltersChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _selectedCategory;
  String? _selectedPeriod;
  String? _selectedDifficulty;
  List<QuizQuestion> _filteredQuestions = [];

  // TTS voice state
  List<Map<String, String>> _availableVoices = [];
  Map<String, String>? _selectedVoice;
  bool _loadingVoices = false;
  double _speechRate = TtsService.defaultSpeechRate;
  double _pitch = 1.0;

  // /api/tts status (web only)
  bool? _edgeTtsAvailable;
  bool _edgeTtsPinging = false;

  // Offline Piper TTS (mobile)
  bool _useOfflinePiper = true;
  bool _offlinePiperDownloading = false;
  double? _offlinePiperProgress;
  String? _offlinePiperStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyFilters();
      _loadTtsState();
    });
  }

  Future<void> _loadTtsState() async {
    await TtsService.instance.initialize();
    if (!mounted) return;
    setState(() {
      _selectedVoice    = TtsService.instance.activeWebVoice;
      _speechRate       = TtsService.instance.speechRate;
      _pitch            = TtsService.instance.pitch;
      _edgeTtsAvailable = TtsService.instance.apiAvailable;
      _useOfflinePiper  = TtsService.instance.useOfflinePiper;
      _offlinePiperDownloading = TtsService.instance.offlinePiperDownloading;
      _offlinePiperProgress    = TtsService.instance.offlinePiperDownloadProgress;
      _offlinePiperStatus      = TtsService.instance.offlinePiperStatus;
    });
    await _refreshVoices();
  }

  Future<void> _downloadOfflinePiper() async {
    if (_offlinePiperDownloading) return;
    setState(() {
      _offlinePiperDownloading = true;
      _offlinePiperProgress = 0;
    });
    await TtsService.instance.ensureOfflinePiperReady(
      onProgress: (p) {
        if (!mounted) return;
        setState(() => _offlinePiperProgress = p);
      },
    );
    if (!mounted) return;
    setState(() {
      _offlinePiperDownloading = TtsService.instance.offlinePiperDownloading;
      _offlinePiperProgress    = TtsService.instance.offlinePiperDownloadProgress;
      _offlinePiperStatus      = TtsService.instance.offlinePiperStatus;
    });
  }

  Future<void> _previewOfflinePiper() async {
    await TtsService.instance.speakWithOfflinePiper(
      'Hallo! Dies ist die offline Neural-Stimme für Deutsch.',
    );
  }

  Future<void> _pingEdgeTts() async {
    if (_edgeTtsPinging) return;
    setState(() {
      _edgeTtsPinging   = true;
      _edgeTtsAvailable = null;
    });
    final ok = await TtsService.instance.pingApi();
    if (!mounted) return;
    setState(() {
      _edgeTtsAvailable = ok;
      _edgeTtsPinging   = false;
    });
  }

  Future<void> _previewEdgeTts() async {
    await TtsService.instance.speak(
      'Hallo! Dies ist die Microsoft-Stimme Katja, direkt vom Server.',
    );
  }

  Future<void> _refreshVoices() async {
    if (!mounted) return;
    setState(() => _loadingVoices = true);
    final voices = await TtsService.instance.getGermanVoices();
    if (!mounted) return;
    setState(() {
      _availableVoices = voices;
      _loadingVoices = false;
      // Keep selection in sync
      if (_selectedVoice == null && voices.isNotEmpty) {
        _selectedVoice = voices.first;
      }
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredQuestions = QuestionService.filterQuestions(
        widget.allQuestions,
        selectedCategory: _selectedCategory,
        selectedPeriod: _selectedPeriod,
        selectedDifficulty: _selectedDifficulty,
      );
    });
    widget.onFiltersChanged(_filteredQuestions);
  }

  @override
  Widget build(BuildContext context) {
    final categories = QuestionService.getUniqueCategories(widget.allQuestions);
    final periods = QuestionService.getUniquePeriods(widget.allQuestions);
    final difficulties = QuestionService.getUniqueDifficulties(widget.allQuestions);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.blue.shade100],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width < 400 ? 12 : 16),
          children: [
            // ── Filter-Karte ───────────────────────────────────────────────
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(
                    MediaQuery.of(context).size.width < 400 ? 12 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filter',
                      style: TextStyle(
                        fontSize:
                            MediaQuery.of(context).size.width < 400 ? 20 : 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                        height:
                            MediaQuery.of(context).size.width < 400 ? 16 : 24),
                    Text(
                      'Land/Kategorie:',
                      style: TextStyle(
                        fontSize:
                            MediaQuery.of(context).size.width < 400 ? 16 : 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                        height:
                            MediaQuery.of(context).size.width < 400 ? 6 : 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      hint: const Text('Alle Länder'),
                      items: [
                        const DropdownMenuItem<String>(
                            value: null, child: Text('Alle Länder')),
                        ...categories.map((c) =>
                            DropdownMenuItem<String>(value: c, child: Text(c))),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedCategory = value);
                        _applyFilters();
                      },
                    ),
                    SizedBox(
                        height:
                            MediaQuery.of(context).size.width < 400 ? 16 : 24),
                    Text(
                      'Epoche:',
                      style: TextStyle(
                        fontSize:
                            MediaQuery.of(context).size.width < 400 ? 16 : 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                        height:
                            MediaQuery.of(context).size.width < 400 ? 6 : 8),
                    DropdownButtonFormField<String>(
                      value: _selectedPeriod,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      hint: const Text('Alle Epochen'),
                      items: [
                        const DropdownMenuItem<String>(
                            value: null, child: Text('Alle Epochen')),
                        ...periods.map((p) =>
                            DropdownMenuItem<String>(value: p, child: Text(p))),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedPeriod = value);
                        _applyFilters();
                      },
                    ),
                    SizedBox(
                        height:
                            MediaQuery.of(context).size.width < 400 ? 16 : 24),
                    Text(
                      'Schwierigkeitsgrad:',
                      style: TextStyle(
                        fontSize:
                            MediaQuery.of(context).size.width < 400 ? 16 : 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                        height:
                            MediaQuery.of(context).size.width < 400 ? 6 : 8),
                    DropdownButtonFormField<String>(
                      value: _selectedDifficulty,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      hint: const Text('Alle Schwierigkeitsgrade'),
                      items: [
                        const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Alle Schwierigkeitsgrade')),
                        ...difficulties.map((d) => DropdownMenuItem<String>(
                            value: d,
                            child: Text(_getDifficultyDisplayName(d)))),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedDifficulty = value);
                        _applyFilters();
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
                height: MediaQuery.of(context).size.width < 400 ? 12 : 16),

            // ── Statistik-Karte ────────────────────────────────────────────
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(
                    MediaQuery.of(context).size.width < 400 ? 12 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistik',
                      style: TextStyle(
                        fontSize:
                            MediaQuery.of(context).size.width < 400 ? 20 : 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                        height:
                            MediaQuery.of(context).size.width < 400 ? 12 : 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('Gesamt',
                            widget.allQuestions.length.toString(), Icons.quiz, Colors.blue),
                        _buildStatItem('Gefiltert',
                            _filteredQuestions.length.toString(), Icons.filter_list, Colors.green),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
                height: MediaQuery.of(context).size.width < 400 ? 12 : 16),

            // ── TTS ────────────────────────────────────────────────────────
            if (!kIsWeb && TtsService.instance.offlinePiperSupported) ...[
              _buildOfflinePiperCard(context),
              SizedBox(height: MediaQuery.of(context).size.width < 400 ? 12 : 16),
            ],
            if (kIsWeb) ...[
              _buildEdgeTtsCard(context),
              SizedBox(height: MediaQuery.of(context).size.width < 400 ? 12 : 16),
            ],

            // ── System/Browser voice (Fallback) ───────────────────────────
            _buildVoiceCard(context),

            SizedBox(
                height: MediaQuery.of(context).size.width < 400 ? 16 : 24),

            // ── Start-Button ───────────────────────────────────────────────
            ElevatedButton(
              onPressed: _filteredQuestions.isEmpty
                  ? null
                  : () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
              child: Text(
                'Quiz starten',
                style: TextStyle(
                  fontSize:
                      MediaQuery.of(context).size.width < 400 ? 18 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflinePiperCard(BuildContext context) {
    final ready = TtsService.instance.offlinePiperReady;
    final downloading = _offlinePiperDownloading;
    final progress = _offlinePiperProgress;

    Widget statusWidget;
    if (downloading) {
      statusWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _offlinePiperStatus ?? 'Sprachmodell wird geladen …',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: progress),
          if (progress != null)
            Text(
              '${(progress * 100).round()} %',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
        ],
      );
    } else if (ready) {
      statusWidget = Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              _offlinePiperStatus ?? 'Bereit – Piper Neural (deutsch)',
              style: TextStyle(
                fontSize: 13,
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: _previewOfflinePiper,
            icon: const Icon(Icons.play_arrow, size: 16),
            label: const Text('Test'),
          ),
        ],
      );
    } else {
      statusWidget = Text(
        _offlinePiperStatus ??
            'Noch nicht installiert (~20 MB, einmaliger Download)',
        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.offline_bolt, color: Colors.deepPurple),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Offline Neural-Stimme (empfohlen)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                if (ready && _useOfflinePiper)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'AKTIV',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Piper Neural TTS – deutlich natürlicher als die Standard-Android-Stimme.\n'
              'Funktioniert komplett offline nach dem Download.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            statusWidget,
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Offline-Stimme verwenden'),
              subtitle: const Text('Bevorzugt vor der System-Stimme'),
              value: _useOfflinePiper,
              onChanged: (v) async {
                await TtsService.instance.setUseOfflinePiper(v);
                if (!mounted) return;
                setState(() => _useOfflinePiper = v);
              },
            ),
            if (!ready)
              ElevatedButton.icon(
                onPressed: downloading ? null : _downloadOfflinePiper,
                icon: downloading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.download, size: 16),
                label: Text(downloading ? 'Wird heruntergeladen …' : 'Sprachmodell laden'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEdgeTtsCard(BuildContext context) {
    final Widget statusWidget;
    if (_edgeTtsPinging) {
      statusWidget = Row(
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 6),
          Text('Verbindung wird getestet …',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        ],
      );
    } else if (_edgeTtsAvailable == true) {
      statusWidget = Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Verbunden – de-DE-KatjaNeural aktiv',
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600),
            ),
          ),
          TextButton.icon(
            onPressed: _previewEdgeTts,
            icon: const Icon(Icons.play_arrow, size: 16),
            label: const Text('Test'),
          ),
        ],
      );
    } else if (_edgeTtsAvailable == false) {
      statusWidget = Row(
        children: [
          const Icon(Icons.cancel, color: Colors.orange, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Nicht erreichbar – Browser-Stimme als Fallback',
              style: TextStyle(fontSize: 13, color: Colors.orange.shade800),
            ),
          ),
        ],
      );
    } else {
      statusWidget = Text(
        'Status unbekannt',
        style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.wifi, color: Colors.blue),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'edge-tts Server (beste Qualität)',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                if (_edgeTtsAvailable == true)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('AKTIV',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Microsoft Katja Neural – gleicher Klang auf jedem Gerät und Browser.\n'
              'Läuft automatisch auf Vercel (/api/tts).',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            // Status row
            statusWidget,
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _edgeTtsPinging ? null : _pingEdgeTts,
              icon: _edgeTtsPinging
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.refresh, size: 16),
              label: const Text('Verbindung prüfen'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceCard(BuildContext context) {
    final activeName = _selectedVoice?['name'] ?? '—';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.record_voice_over, color: Colors.blueGrey),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    kIsWeb ? 'Browser-Stimme (Fallback)' : 'System-Stimme (Fallback)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.play_circle_outline,
                      color: Colors.blueGrey),
                  tooltip: 'Vorschau',
                  onPressed: () async {
                    await TtsService.instance.speakWithWebVoice(
                      'Hallo! Dies ist die Browser-Stimme als Fallback.',
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              kIsWeb
                  ? 'Aktiv wenn Server nicht verfügbar: $activeName'
                  : 'Fallback wenn Offline-Stimme nicht verfügbar: $activeName',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),

            // Voice dropdown
            if (_loadingVoices)
              const Center(child: CircularProgressIndicator())
            else if (_availableVoices.isEmpty)
              Text(
                'Keine deutschen Stimmen im Browser gefunden.\n'
                'Tipp: Chrome/Edge auf Windows hat Microsoft-Stimmen (Katja, Conrad).',
                style: TextStyle(fontSize: 13, color: Colors.orange.shade800),
              )
            else
              Builder(builder: (context) {
                final currentName = _selectedVoice?['name'];
                final voiceValue = _availableVoices.any(
                        (v) => v['name'] == currentName)
                    ? currentName
                    : _availableVoices.first['name'];
                return DropdownButtonFormField<String>(
                value: voiceValue,
                decoration: InputDecoration(
                  labelText: 'Stimme wählen',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                isExpanded: true,
                items: _availableVoices
                    .map((v) => DropdownMenuItem<String>(
                          value: v['name'],
                          child: Text(
                            v['name']!,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                onChanged: (name) async {
                  final voice = _availableVoices.firstWhere(
                    (v) => v['name'] == name,
                    orElse: () => _availableVoices.first,
                  );
                  await TtsService.instance.setWebVoice(voice);
                  if (!mounted) return;
                  setState(() => _selectedVoice = voice);
                },
              );
              }),

            const SizedBox(height: 16),

            // Speech rate
            Row(
              children: [
                const Icon(Icons.speed, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                const Text('Geschwindigkeit', style: TextStyle(fontSize: 14)),
                const Spacer(),
                Text(
                  _speechRate == TtsService.defaultSpeechRate
                      ? 'Normal'
                      : _speechRate < TtsService.defaultSpeechRate
                          ? 'Langsam'
                          : 'Schnell',
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            Slider(
              value: _speechRate,
              min: 0.25,
              max: 1.4,
              divisions: 10,
              label: _speechRate.toStringAsFixed(2),
              onChanged: (v) => setState(() => _speechRate = v),
              onChangeEnd: (v) => TtsService.instance.setSpeechRate(v),
            ),

            // Pitch
            Row(
              children: [
                const Icon(Icons.music_note, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                const Text('Tonhöhe', style: TextStyle(fontSize: 14)),
                const Spacer(),
                Text(
                  _pitch == 1.0
                      ? 'Normal'
                      : _pitch < 1.0
                          ? 'Tief'
                          : 'Hoch',
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            Slider(
              value: _pitch,
              min: 0.5,
              max: 2.0,
              divisions: 15,
              label: _pitch.toStringAsFixed(2),
              onChanged: (v) => setState(() => _pitch = v),
              onChangeEnd: (v) => TtsService.instance.setPitch(v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width < 400 ? 24 : 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  String _getDifficultyDisplayName(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 'Einfach';
      case 'medium':
        return 'Mittel';
      case 'hard':
        return 'Schwer';
      default:
        return difficulty;
    }
  }
}
