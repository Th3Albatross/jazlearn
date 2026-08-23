import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../data/materi_data.dart';
import '../services/materi_loader.dart';
import '../widgets/materi_video_player.dart';

enum MateriView { video, summary }

class MateriPage extends StatefulWidget {
  const MateriPage({super.key});

  @override
  State<MateriPage> createState() => _MateriPageState();
}

class _MateriPageState extends State<MateriPage> {
  late Future<List<MateriData>> _materiFuture;

  int _selectedIndex = 0;
  MateriView _view = MateriView.video;
  Duration _currentVideoPosition = Duration.zero;
  String? _summary;

  List<MateriData> _materiList = [];

  MateriData? get _selectedMateri {
    if (_materiList.isEmpty || _selectedIndex >= _materiList.length) {
      return null;
    }

    return _materiList[_selectedIndex];
  }

  @override
  void initState() {
    super.initState();
    _materiFuture = _loadMateri();
  }

  Future<List<MateriData>> _loadMateri() async {
    final data = await MateriLoader.load();

    _materiList = data;

    if (data.isNotEmpty) {
      await _loadSummary(data[0]);
    }

    return data;
  }

  Future<void> _loadSummary(MateriData materi) async {
    if (mounted) {
      setState(() {
        _summary = null;
      });
    }

    final summary = await rootBundle.loadString(materi.summaryAsset);

    if (!mounted) {
      return;
    }

    setState(() {
      _summary = summary;
    });
  }

  Future<void> _selectMateri(int index) async {
    if (index < 0 || index >= _materiList.length) {
      return;
    }

    final materi = _materiList[index];

    setState(() {
      _selectedIndex = index;
      _view = MateriView.video;
      _summary = null;
    });

    await _loadSummary(materi);
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(45),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Materi',
                  style: TextStyle(
                    color: AppTheme.text,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sinau teori lan tata basa Jawa.',
                  style: TextStyle(color: AppTheme.muted, fontFamily: 'Arial'),
                ),
                const SizedBox(height: 30),
                FutureBuilder<List<MateriData>>(
                  future: _materiFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (snapshot.hasError) {
                      return _ErrorView(
                        error: snapshot.error.toString(),
                        onRetry: () {
                          setState(() {
                            _selectedIndex = 0;
                            _summary = null;
                            _materiFuture = _loadMateri();
                          });
                        },
                      );
                    }

                    final materiList = snapshot.data ?? [];

                    if (materiList.isEmpty) {
                      return const SizedBox(
                        height: 200,
                        child: Center(
                          child: Text(
                            'Durung ana materi.',
                            style: TextStyle(color: AppTheme.muted),
                          ),
                        ),
                      );
                    }

                    final materi = _selectedMateri!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _MateriSelector(
                          items: materiList,
                          selectedIndex: _selectedIndex,
                          onSelected: _selectMateri,
                        ),
                        const SizedBox(height: 30),
                        Text(
                          materi.title,
                          style: const TextStyle(
                            color: AppTheme.text,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          materi.description,
                          style: const TextStyle(
                            color: AppTheme.muted,
                            fontFamily: 'Arial',
                          ),
                        ),
                        const SizedBox(height: 25),
                        _ViewSelector(
                          view: _view,
                          onChanged: (view) {
                            setState(() {
                              _view = view;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: _view == MateriView.video
                              ? MateriVideoPlayer(
                                  key: ValueKey('video_${materi.uid}'),
                                  videoId: materi.uid,
                                  asset: materi.videoAsset,
                                  onPositionChanged: (position) {
                                    _currentVideoPosition = position;
                                  },
                                )
                              : _SummaryView(
                                  key: ValueKey('summary_${materi.uid}'),
                                  summary: _summary,
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MateriSelector extends StatelessWidget {
  final List<MateriData> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _MateriSelector({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      width: double.infinity,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          final selected = index == selectedIndex;

          return Material(
            color: selected ? AppTheme.green : AppTheme.paper,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () => onSelected(index),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 230,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected
                        ? AppTheme.green
                        : AppTheme.gold.withOpacity(.15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Materi ${index + 1}',
                      style: TextStyle(
                        color: selected ? Colors.white70 : AppTheme.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? Colors.white : AppTheme.text,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ViewSelector extends StatelessWidget {
  final MateriView view;
  final ValueChanged<MateriView> onChanged;

  const _ViewSelector({required this.view, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gold.withOpacity(.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Button(
            label: 'Video',
            icon: Icons.play_circle_outline_rounded,
            selected: view == MateriView.video,
            onTap: () {
              onChanged(MateriView.video);
            },
          ),
          _Button(
            label: 'Rangkuman',
            icon: Icons.menu_book_rounded,
            selected: view == MateriView.summary,
            onTap: () {
              onChanged(MateriView.summary);
            },
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 17,
                color: selected ? Colors.white : AppTheme.muted,
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : AppTheme.muted,
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

  const _SummaryView({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    if (summary == null) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.gold.withOpacity(.15)),
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
          listBullet: const TextStyle(color: AppTheme.gold),
          blockquote: const TextStyle(
            color: AppTheme.muted,
            fontStyle: FontStyle.italic,
            fontSize: 15,
            height: 1.6,
          ),
          blockquoteDecoration: BoxDecoration(
            color: AppTheme.gold.withOpacity(.06),
            border: const Border(
              left: BorderSide(color: AppTheme.gold, width: 3),
            ),
          ),
          blockquotePadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 40),
          const SizedBox(height: 10),
          const Text(
            'Gagal memuat materi',
            style: TextStyle(
              color: AppTheme.text,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.muted, fontSize: 13),
          ),
          const SizedBox(height: 15),
          ElevatedButton(onPressed: onRetry, child: const Text('Coba maneh')),
        ],
      ),
    );
  }
}
