import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/mantra_model.dart';

class MantraJapamPlayerScreen extends StatefulWidget {
  final MantraModel mantra;
  final int initialTarget;

  const MantraJapamPlayerScreen({
    super.key,
    required this.mantra,
    this.initialTarget = 108,
  });

  @override
  State<MantraJapamPlayerScreen> createState() => _MantraJapamPlayerScreenState();
}

class _MantraJapamPlayerScreenState extends State<MantraJapamPlayerScreen>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  late int _targetCount;
  int _currentCount = 0;
  bool _isPlaying = false;
  bool _isAutoLoop = true;
  bool _vibrationEnabled = true;
  StreamSubscription? _playerCompleteSub;
  StreamSubscription? _playerStateSub;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _targetCount = widget.initialTarget > 0 ? widget.initialTarget : widget.mantra.defaultTargetCount;
    _audioPlayer = AudioPlayer();

    // High performance mode for zero latency / seamless loop
    _audioPlayer.setReleaseMode(ReleaseMode.stop);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Auto increment when each mantra recitation audio completes
    _playerCompleteSub = _audioPlayer.onPlayerComplete.listen((_) {
      _onAudioRecitationComplete();
    });

    _playerStateSub = _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = (state == PlayerState.playing);
        });
        if (_isPlaying) {
          _pulseController.repeat(reverse: true);
        } else {
          _pulseController.stop();
          _pulseController.value = 0.0;
        }
      }
    });

    // Auto-start chanting immediately on entering player screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startOrResumeChanting();
    });
  }

  void _onAudioRecitationComplete() async {
    if (!mounted) return;

    if (_vibrationEnabled) {
      HapticFeedback.lightImpact();
    }

    setState(() {
      _currentCount++;
    });

    // Check if goal completed
    if (_currentCount >= _targetCount) {
      _celebrateCompletion();
      return;
    }

    // Zero delay seamless continuation if auto loop enabled
    if (_isAutoLoop && _isPlaying) {
      if (widget.mantra.loopDelayMs > 0) {
        await Future.delayed(Duration(milliseconds: widget.mantra.loopDelayMs));
      }
      if (mounted && _isPlaying && _currentCount < _targetCount) {
        _playAudio();
      }
    }
  }

  Future<void> _playAudio() async {
    try {
      final url = widget.mantra.audioUrl.trim();
      if (url.isNotEmpty) {
        await _audioPlayer.play(UrlSource(url));
      }
    } catch (e) {
      debugPrint("Audio play error: $e");
    }
  }

  void _startOrResumeChanting() async {
    setState(() => _isPlaying = true);
    await _playAudio();
  }

  void _pauseChanting() async {
    setState(() => _isPlaying = false);
    await _audioPlayer.pause();
  }

  void _manualTapCount() {
    if (_vibrationEnabled) {
      HapticFeedback.mediumImpact();
    }
    setState(() {
      _currentCount++;
    });
    if (_currentCount >= _targetCount) {
      _celebrateCompletion();
    }
  }

  void _celebrateCompletion() {
    _pauseChanting();
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFFFFBF4),
        title: const Row(
          children: [
            Icon(Icons.workspace_premium_rounded, color: Color(0xFFD4AF37), size: 32),
            SizedBox(width: 10),
            Text(
              "జపం పూర్తయింది! 🙏",
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "మీరు '${widget.mantra.name}' జపాన్ని విజయవంతంగా $_targetCount సార్లు పూర్తి చేశారు.",
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFDEFD9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.mantra.meaning,
                style: const TextStyle(fontSize: 13, color: Color(0xFF6A1B29)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _currentCount = 0;
              });
              _startOrResumeChanting();
            },
            child: const Text("మళ్ళీ ప్రారంభించు", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B29)),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("ముగించు", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _resetCounter() {
    _pauseChanting();
    setState(() {
      _currentCount = 0;
    });
  }

  void _changeTargetCount(int target) {
    setState(() {
      _targetCount = target;
    });
  }

  @override
  void dispose() {
    _playerCompleteSub?.cancel();
    _playerStateSub?.cancel();
    _audioPlayer.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _targetCount > 0 ? (_currentCount / _targetCount).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B29),
        title: Text(
          widget.mantra.name,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(_vibrationEnabled ? Icons.vibration : Icons.smartphone, color: Colors.white),
            tooltip: _vibrationEnabled ? "వైబ్రేషన్ ఆన్" : "వైబ్రేషన్ ఆఫ్",
            onPressed: () {
              setState(() => _vibrationEnabled = !_vibrationEnabled);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: "రీసెట్ (Reset)",
            onPressed: _resetCounter,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Target selector pills (11, 21, 54, 108, 1008)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [11, 21, 54, 108, 1008].map((cnt) {
                final isSelected = _targetCount == cnt;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text("$cnt"),
                    selected: isSelected,
                    selectedColor: const Color(0xFF6A1B29),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF6A1B29),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    backgroundColor: const Color(0xFFFDEFD9),
                    onSelected: (val) {
                      if (val) _changeTargetCount(cnt);
                    },
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Big Om / Mala Circle with Glow Pulsing
            GestureDetector(
              onTap: _manualTapCount,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isPlaying ? _pulseAnimation.value : 1.0,
                    child: Container(
                      width: 230,
                      height: 230,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFFCE4D6),
                            const Color(0xFFF9D2B5),
                            const Color(0xFF6A1B29).withValues(alpha: 0.12),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8A1E2B).withValues(alpha: _isPlaying ? 0.35 : 0.15),
                            blurRadius: _isPlaying ? 28 : 14,
                            spreadRadius: _isPlaying ? 4 : 1,
                          ),
                        ],
                        border: Border.all(
                          color: const Color(0xFFF0C28A),
                          width: 3,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Circular Progress Ring
                          SizedBox(
                            width: 210,
                            height: 210,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 6,
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8A1E2B)),
                              backgroundColor: const Color(0xFFEBD4B2),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Om symbol
                              const Text(
                                "ॐ",
                                style: TextStyle(
                                  fontSize: 64,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF8A1E2B),
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "$_currentCount / $_targetCount",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C1810),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _isPlaying ? "జపం సాగుతోంది..." : "ట్యాప్ చేయండి",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _isPlaying ? const Color(0xFFE65100) : Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Mantra Title & Deity
            Text(
              widget.mantra.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A1B29),
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "దేవత: ${widget.mantra.deity}",
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFB71C1C),
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 20),

            // Counter Adjustment Row (- Count +)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Minus button
                InkWell(
                  onTap: () {
                    if (_currentCount > 0) {
                      if (_vibrationEnabled) HapticFeedback.lightImpact();
                      setState(() => _currentCount--);
                    }
                  },
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFADBD8),
                      border: Border.all(color: const Color(0xFFF1948A)),
                    ),
                    child: const Icon(Icons.remove, color: Color(0xFF78281F), size: 28),
                  ),
                ),

                const SizedBox(width: 32),

                // Manual tap count + button (Matching user screenshot red circle)
                InkWell(
                  onTap: _manualTapCount,
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF8A1E2B), Color(0xFF5A0E18)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x408A1E2B),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 30),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Big Start / Pause Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isPlaying ? const Color(0xFFB71C1C) : const Color(0xFF6A1B29),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                  elevation: 4,
                ),
                onPressed: () {
                  if (_isPlaying) {
                    _pauseChanting();
                  } else {
                    _startOrResumeChanting();
                  }
                },
                icon: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 26),
                label: Text(
                  _isPlaying ? "జపం పాజ్ చేయండి" : "జపం ప్రారంభించండి",
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Continuous Auto-Loop Switch
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF1E4CE)),
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  "నిరంతర జపం (Continuous Audio Loop)",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF6A1B29)),
                ),
                subtitle: const Text(
                  "ఆడియో ఆటోమేటిక్‌గా లూప్ అవుతూ కౌంటర్ పెరుగుతుంది",
                  style: TextStyle(fontSize: 12),
                ),
                value: _isAutoLoop,
                activeThumbColor: const Color(0xFF8A1E2B),
                onChanged: (val) {
                  setState(() => _isAutoLoop = val);
                },
              ),
            ),

            const SizedBox(height: 14),

            // Meaning Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1E4CE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_stories, color: Color(0xFFD4AF37), size: 20),
                      SizedBox(width: 8),
                      Text(
                        "మంత్ర మహత్యం & భావం",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.mantra.meaning,
                    style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF424242)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
