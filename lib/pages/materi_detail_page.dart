import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/materi_video_player.dart';
import '../services/video_progress_service.dart';
import '../data/materi_data.dart';

enum MateriView {
  video,
  summary,
}

class MateriDetailPage extends StatefulWidget {
  final MateriData materi;

  const MateriDetailPage({
    super.key,
    required this.materi,
  });

  @override
  State<MateriDetailPage> createState() => _MateriDetailPageState();
}

class _MateriDetailPageState extends State<MateriDetailPage> {
  MateriView _view = MateriView.video;
  String? _summary;
  Duration _currentVideoPosition = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    try {
      final summary = await rootBundle.loadString(
        widget.materi.summaryAsset,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _summary = summary;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _summary = 'Gagal memuat rangkuman.\n\n$e';
      });
    }
  }

  void _changeView(MateriView view) {
    if (view == MateriView.summary) {
      // Explicitly save the latest position when switching to summary.
      VideoProgressService.instance.savePosition(
        widget.materi.uid,
        _currentVideoPosition,
      );
    }

    setState(() {
      _view = view;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(45),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BackButton(
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(height: 25),
                Text(
                  widget.materi.title,
                  style: const TextStyle(
                    color: AppTheme.text,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.materi.description,
                  style: const TextStyle(
                    color: AppTheme.muted,
                    fontFamily: 'Arial',
                  ),
                ),
                const SizedBox(height: 28),
                _ViewSelector(
                  view: _view,
                  onChanged: _changeView,
                ),
                const SizedBox(height: 20),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _view == MateriView.video
                      ? MateriVideoPlayer(
                          key: ValueKey(
                            'video_${widget.materi.uid}',
                          ),
                          videoId: widget.materi.uid,
                          asset: widget.materi.videoAsset,
                          onPositionChanged: (position) {
                            _currentVideoPosition = position;
                          },
                        )
                      : _SummaryView(
                          key: ValueKey(
                            'summary_${widget.materi.uid}',
                          ),
                          summary: _summary,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.arrow_back_rounded, size: 18),
      label: const Text('Kembali ke Materi'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.text,
        side: BorderSide(
          color: AppTheme.gold.withOpacity(.25),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _ViewSelector extends StatelessWidget {
  final MateriView view;
  final ValueChanged<MateriView> onChanged;

  const _ViewSelector({
    required this.view,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.gold.withOpacity(.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Button(
            label: 'Video',
            icon: Icons.play_circle_outline_rounded,
            selected: view == MateriView.video,
            onTap: () => onChanged(MateriView.video),
          ),
          _Button(
            label: 'Rangkuman',
            icon: Icons.menu_book_rounded,
            selected: view == MateriView.summary,
            onTap: () => onChanged(MateriView.summary),
          ),
        ],
      ),
    );
  }
}

class _Button extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _Button({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppTheme.green : Colors.transparent,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 9,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 17,
                color: selected
                    ? Colors.white
                    : AppTheme.muted,
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : AppTheme.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryView extends StatelessWidget {
  final String? summary;

  const _SummaryView({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    if (summary == null) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.gold.withOpacity(.15),
        ),
      ),
      child: MarkdownBody(
        data: summary!,
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          h1: const TextStyle(
            color: AppTheme.text,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
          h2: const TextStyle(
            color: AppTheme.green,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
          h3: const TextStyle(
            color: AppTheme.green,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          p: const TextStyle(
            color: AppTheme.text,
            fontSize: 15,
            height: 1.7,
            fontFamily: 'Arial',
          ),
          listBullet: const TextStyle(
            color: AppTheme.gold,
          ),
          blockquote: const TextStyle(
            color: AppTheme.muted,
            fontStyle: FontStyle.italic,
            fontSize: 15,
            height: 1.6,
          ),
          blockquoteDecoration: BoxDecoration(
            color: AppTheme.gold.withOpacity(.06),
            border: const Border(
              left: BorderSide(
                color: AppTheme.gold,
                width: 3,
              ),
            ),
          ),
          blockquotePadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
