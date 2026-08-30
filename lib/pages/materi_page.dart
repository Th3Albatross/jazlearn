import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../data/materi_data.dart';
import '../services/materi_loader.dart';
import 'materi_detail_page.dart';

class MateriPage extends StatefulWidget {
  const MateriPage({super.key});

  @override
  State<MateriPage> createState() => _MateriPageState();
}

class _MateriPageState extends State<MateriPage> {
  late Future<List<MateriData>> _materiFuture;
  Timer? _searchDebounce;
  final TextEditingController _searchController =
      TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _materiFuture = MateriLoader.load();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      final query = _searchController.text.trim().toLowerCase();
      if (query == _searchQuery) return;
      setState(() => _searchQuery = query);
    });
  }

  List<MateriData> _filterMateri(List<MateriData> data) {
    if (_searchQuery.isEmpty) {
      return data;
    }

    return data.where((item) {
      return item.title.toLowerCase().contains(_searchQuery) ||
          item.description.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  Future<void> _openMateri(MateriData materi) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MateriDetailPage(materi: materi),
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
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
                  'Belajar teori dan tata bahasa jawa',
                  style: TextStyle(
                    color: AppTheme.muted,
                    fontFamily: 'Arial',
                  ),
                ),
                const SizedBox(height: 25),
                TextField(
                  controller: _searchController,
                  style: const TextStyle(
                    color: AppTheme.text,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Cari materi...',
                    hintStyle: const TextStyle(
                      color: AppTheme.muted,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppTheme.muted,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: _clearSearch,
                            icon: const Icon(Icons.close_rounded),
                          )
                        : null,
                    filled: true,
                    fillColor: AppTheme.paper,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: AppTheme.gold.withOpacity(.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 35),
                FutureBuilder<List<MateriData>>(
                  future: _materiFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const SizedBox(
                        height: 240,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return _ErrorBox(
                        error: snapshot.error.toString(),
                        onRetry: () {
                          setState(() {
                            _materiFuture = MateriLoader.load(forceReload: true);
                          });
                        },
                      );
                    }

                    final allMateri = snapshot.data ?? [];
                    final filteredMateri = _filterMateri(allMateri);

                    if (allMateri.isEmpty) {
                      return const _EmptyState(
                        message: 'Durung ana materi.',
                      );
                    }

                    if (filteredMateri.isEmpty) {
                      return const _EmptyState(
                        message: 'Materi ora ditemokake.',
                      );
                    }

                    return Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${filteredMateri.length} materi ditemokake',
                            style: const TextStyle(
                              color: AppTheme.muted,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        _MateriGrid(
                          items: filteredMateri,
                          onTap: _openMateri,
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

class _MateriGrid extends StatelessWidget {
  final List<MateriData> items;
  final ValueChanged<MateriData> onTap;

  const _MateriGrid({
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 1050
            ? 3
            : width >= 700
                ? 2
                : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            childAspectRatio: width < 700 ? 2.1 : 1.45,
          ),
          itemBuilder: (context, index) {
            final materi = items[index];
            return _MateriCard(
              index: index,
              materi: materi,
              onTap: () => onTap(materi),
            );
          },
        );
      },
    );
  }
}

class _MateriCard extends StatefulWidget {
  final int index;
  final MateriData materi;
  final VoidCallback onTap;

  const _MateriCard({
    required this.index,
    required this.materi,
    required this.onTap,
  });

  @override
  State<_MateriCard> createState() => _MateriCardState();
}

class _MateriCardState extends State<_MateriCard> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          transform: Matrix4.translationValues(
            0,
            hover ? -5 : 0,
            0,
          ),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppTheme.paper,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.gold.withOpacity(.18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  hover ? .10 : .04,
                ),
                blurRadius: hover ? 22 : 12,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.green.withOpacity(.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.play_lesson_rounded,
                      color: AppTheme.green,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withOpacity(.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'MATERI ${widget.index + 1}',
                      style: const TextStyle(
                        color: AppTheme.gold,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Text(
                widget.materi.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.text,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  widget.materi.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.muted,
                    fontSize: 13,
                    height: 1.5,
                    fontFamily: 'Arial',
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(
                    Icons.play_circle_outline_rounded,
                    color: AppTheme.green,
                    size: 17,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Video & Rangkuman',
                    style: TextStyle(
                      color: AppTheme.muted,
                      fontSize: 11,
                      fontFamily: 'Arial',
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppTheme.green,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.menu_book_rounded,
            color: AppTheme.gold,
            size: 42,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(
              color: AppTheme.muted,
              fontFamily: 'Arial',
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorBox({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.red.withOpacity(.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gagal memuat materi',
            style: TextStyle(
              color: Colors.red,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(
              color: AppTheme.muted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Coba maneh'),
          ),
        ],
      ),
    );
  }
}
