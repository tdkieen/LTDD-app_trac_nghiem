import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/cau_hoi.dart';

class ListeningAudioPlayer extends StatefulWidget {
  final CauHoi question;

  const ListeningAudioPlayer({
    super.key,
    required this.question,
  });

  @override
  State<ListeningAudioPlayer> createState() => _ListeningAudioPlayerState();
}

class _ListeningAudioPlayerState extends State<ListeningAudioPlayer> {
  // Audio Player
  late final AudioPlayer _audioPlayer;
  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  StreamSubscription? _stateSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _positionSub;

  // TTS Engine
  late final FlutterTts _flutterTts;
  bool _isTtsPlaying = false;
  bool _isUsingTts = false;

  // Playback settings
  double _playbackRate = 1.0;
  String? _errorMessage;

  // Reliable sample audio URLs
  static const String _defaultSampleUrl =
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3';

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
    _initTts();
  }

  void _initAudioPlayer() {
    _audioPlayer = AudioPlayer();
    _stateSub = _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _playerState = state;
        });
      }
    });

    _durationSub = _audioPlayer.onDurationChanged.listen((dur) {
      if (mounted) {
        setState(() {
          _duration = dur;
        });
      }
    });

    _positionSub = _audioPlayer.onPositionChanged.listen((pos) {
      if (mounted) {
        setState(() {
          _position = pos;
        });
      }
    });
  }

  void _initTts() {
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage('en-US');
    _flutterTts.setSpeechRate(0.48);
    _flutterTts.setVolume(1.0);
    _flutterTts.setPitch(1.0);

    _flutterTts.setStartHandler(() {
      if (mounted) {
        setState(() {
          _isTtsPlaying = true;
          _isUsingTts = true;
        });
      }
    });

    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isTtsPlaying = false;
        });
      }
    });

    _flutterTts.setCancelHandler(() {
      if (mounted) {
        setState(() {
          _isTtsPlaying = false;
        });
      }
    });

    _flutterTts.setErrorHandler((msg) {
      if (mounted) {
        setState(() {
          _isTtsPlaying = false;
          _errorMessage = 'Lỗi phát giọng nói: $msg';
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant ListeningAudioPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.maCauHoi != widget.question.maCauHoi) {
      _stopAll();
    }
  }

  Future<void> _stopAll() async {
    try {
      await _audioPlayer.stop();
    } catch (_) {}
    try {
      await _flutterTts.stop();
    } catch (_) {}
    if (mounted) {
      setState(() {
        _isTtsPlaying = false;
        _position = Duration.zero;
        _errorMessage = null;
      });
    }
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _durationSub?.cancel();
    _positionSub?.cancel();
    _audioPlayer.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _buildListeningScript() {
    // Extract clean dialogue from question
    String text = widget.question.noiDung;
    if (text.contains('"')) {
      final parts = text.split('"');
      if (parts.length >= 2) {
        text = parts[1];
      }
    } else {
      text = text.replaceAll('[Audio Question]', '').trim();
    }

    final buffer = StringBuffer();
    buffer.writeln(text);
    buffer.writeln('Option A: ${widget.question.phuongAnA}');
    buffer.writeln('Option B: ${widget.question.phuongAnB}');
    buffer.writeln('Option C: ${widget.question.phuongAnC}');
    buffer.writeln('Option D: ${widget.question.phuongAnD}');
    return buffer.toString();
  }

  Future<void> _toggleAudioPlay() async {
    if (_isTtsPlaying) {
      await _flutterTts.stop();
      _isTtsPlaying = false;
    }

    if (_playerState == PlayerState.playing) {
      await _audioPlayer.pause();
    } else {
      setState(() {
        _errorMessage = null;
        _isUsingTts = false;
      });

      try {
        final path = widget.question.audioPath;
        Source source;
        if (path != null && (path.startsWith('http://') || path.startsWith('https://'))) {
          source = UrlSource(path);
        } else {
          // Use reliable default audio link if local file isn't present
          source = UrlSource(_defaultSampleUrl);
        }

        await _audioPlayer.setPlaybackRate(_playbackRate);
        await _audioPlayer.play(source);
      } catch (e) {
        // Fallback to TTS if network or audio player fails
        if (kDebugMode) {
          print('AudioPlayer error: $e, falling back to TTS');
        }
        await _speakTts();
      }
    }
  }

  Future<void> _speakTts() async {
    if (_playerState == PlayerState.playing) {
      await _audioPlayer.stop();
    }

    if (_isTtsPlaying) {
      await _flutterTts.stop();
      setState(() {
        _isTtsPlaying = false;
      });
    } else {
      setState(() {
        _errorMessage = null;
        _isUsingTts = true;
      });
      final script = _buildListeningScript();
      await _flutterTts.speak(script);
    }
  }

  void _cycleSpeed() {
    double nextSpeed = 1.0;
    if (_playbackRate == 1.0) {
      nextSpeed = 1.25;
    } else if (_playbackRate == 1.25) {
      nextSpeed = 0.75;
    } else {
      nextSpeed = 1.0;
    }

    setState(() {
      _playbackRate = nextSpeed;
    });
    _audioPlayer.setPlaybackRate(nextSpeed);
    _flutterTts.setSpeechRate(nextSpeed * 0.48);
  }

  @override
  Widget build(BuildContext context) {
    final isAudioPlaying = _playerState == PlayerState.playing;
    final isCurrentlyActive = isAudioPlaying || _isTtsPlaying;

    final maxMs = _duration.inMilliseconds.toDouble();
    final curMs = _position.inMilliseconds.toDouble().clamp(0.0, maxMs > 0 ? maxMs : 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentlyActive ? AppColors.primary : AppColors.border,
          width: isCurrentlyActive ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isCurrentlyActive
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with Audio icon & badges
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.headphones_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Phần nghe (TOEIC Listening)',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      _isUsingTts
                          ? 'Đang phát bằng giọng đọc AI (Native English)'
                          : 'File audio bài thi trắc nghiệm',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Playback Speed Button
              ActionChip(
                label: Text(
                  '${_playbackRate}x',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                backgroundColor: AppColors.primarySoft,
                side: const BorderSide(color: AppColors.border),
                onPressed: _cycleSpeed,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress Bar / Waveform indicator
          if (_isUsingTts && _isTtsPlaying) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: const LinearProgressIndicator(
                backgroundColor: AppColors.border,
                color: AppColors.primary,
                minHeight: 6,
              ),
            ),
          ] else ...[
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.border,
                thumbColor: AppColors.primary,
              ),
              child: Slider(
                value: curMs,
                min: 0.0,
                max: maxMs > 0 ? maxMs : 1.0,
                onChanged: (val) {
                  final newPos = Duration(milliseconds: val.toInt());
                  _audioPlayer.seek(newPos);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(_position), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  Text(
                    _duration.inSeconds > 0 ? _formatDuration(_duration) : '00:30',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Control Buttons Row
          Wrap(
            spacing: 10,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Main Audio Play Button
              ElevatedButton.icon(
                onPressed: _toggleAudioPlay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAudioPlaying ? AppColors.warning : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: Icon(isAudioPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 20),
                label: Text(
                  isAudioPlaying ? 'Tạm dừng audio' : 'Phát file Audio',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),

              // TTS Voice Button
              OutlinedButton.icon(
                onPressed: _speakTts,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _isTtsPlaying ? AppColors.danger : AppColors.primary,
                  side: BorderSide(
                    color: _isTtsPlaying ? AppColors.danger : AppColors.primary,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: Icon(_isTtsPlaying ? Icons.stop_rounded : Icons.record_voice_over_rounded, size: 18),
                label: Text(
                  _isTtsPlaying ? 'Dừng đọc AI' : 'Đọc giọng tiếng Anh (AI)',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),

              // Stop All Button
              if (isCurrentlyActive)
                IconButton(
                  tooltip: 'Dừng hoàn toàn',
                  icon: const Icon(Icons.stop_circle_outlined, color: AppColors.danger),
                  onPressed: _stopAll,
                ),
            ],
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.danger, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}
