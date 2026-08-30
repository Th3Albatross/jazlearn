import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../theme/app_theme.dart';
import '../services/video_progress_service.dart';

class MateriVideoPlayer extends StatefulWidget {
  final String videoId;
  final String asset;

  final ValueChanged<Duration>? onPositionChanged;

  const MateriVideoPlayer({
    super.key,
    required this.videoId,
    required this.asset,
    this.onPositionChanged,
  });

  @override
  State<MateriVideoPlayer> createState() => _MateriVideoPlayerState();
}

class _MateriVideoPlayerState extends State<MateriVideoPlayer> {
  late final VideoPlayerController _controller;

  bool _initialized = false;

  // Selama proses initialize dan restore timestamp,
  // listener tidak boleh menyimpan posisi.
  bool _readyToSavePosition = false;
  Duration _lastSavedPosition = Duration.zero;
  static const Duration _saveInterval = Duration(milliseconds: 750);

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset(widget.asset)
      ..addListener(_videoListener);

    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Pastikan saving belum aktif selama initialize.
      _readyToSavePosition = false;

      await _controller.initialize();

      // Ambil posisi lama SEBELUM listener diperbolehkan
      // menyimpan posisi baru.
      final savedPosition =
          VideoProgressService.instance.getPosition(widget.videoId);

      debugPrint(
        'Video ${widget.videoId} - saved position: $savedPosition',
      );

      // Restore posisi lama jika masih valid.
      if (savedPosition > Duration.zero &&
          savedPosition < _controller.value.duration) {
        await _controller.seekTo(savedPosition);

        debugPrint(
          'Video ${widget.videoId} - restored to: '
          '${_controller.value.position}',
        );
      }

      // Baru setelah restore selesai, izinkan listener menyimpan posisi.
      _lastSavedPosition = _controller.value.position;
      _readyToSavePosition = true;

      if (!mounted) {
        return;
      }

      setState(() {
        _initialized = true;
      });
    } catch (e, stackTrace) {
      debugPrint('Video initialization error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) {
        return;
      }

      setState(() {
        _initialized = false;
      });
    }
  }

  void _videoListener() {
    if (!_controller.value.isInitialized) {
      return;
    }

    // Jangan simpan posisi selama proses initialize / restore.
    if (!_readyToSavePosition) {
      return;
    }

    final position = _controller.value.position;
    // Parent hanya menyimpan nilai terbaru; ini murah dibanding rebuild UI.
    widget.onPositionChanged?.call(position);

    if (position >= _lastSavedPosition &&
        position - _lastSavedPosition < _saveInterval) {
      return;
    }

    _lastSavedPosition = position;
    VideoProgressService.instance.savePosition(
      widget.videoId,
      position,
    );
  }

  @override
  void dispose() {
    // Simpan posisi terakhir ketika player ditutup,
    // tapi hanya jika proses initialize sudah selesai.
    if (_controller.value.isInitialized && _readyToSavePosition) {
      final position = _controller.value.position;

      VideoProgressService.instance.savePosition(
        widget.videoId,
        position,
      );

      widget.onPositionChanged?.call(position);

      debugPrint(
        'Video ${widget.videoId} - saved on dispose: $position',
      );
    }

    _controller
      ..removeListener(_videoListener)
      ..dispose();

    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    final seconds = duration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    if (duration.inHours > 0) {
      return '${duration.inHours}:$minutes:$seconds';
    }

    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Container(
        height: 500,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: ValueListenableBuilder<VideoPlayerValue>(
        valueListenable: _controller,
        builder: (context, value, _) {
          return AspectRatio(
            aspectRatio: value.aspectRatio,
            child: Stack(
              children: [
                VideoPlayer(_controller),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(.15),
                          Colors.transparent,
                          Colors.black.withOpacity(.75),
                        ],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Material(
                    color: Colors.black.withOpacity(.55),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        if (value.isPlaying) {
                          _controller.pause();
                        } else {
                          _controller.play();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Icon(
                          value.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 18,
                  right: 18,
                  bottom: 12,
                  child: Column(
                    children: [
                      VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        padding: EdgeInsets.zero,
                        colors: const VideoProgressColors(
                          playedColor: AppTheme.gold,
                          bufferedColor: Colors.white38,
                          backgroundColor: Colors.white24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(value.position),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _formatDuration(value.duration),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
