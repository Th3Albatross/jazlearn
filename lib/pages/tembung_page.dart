import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../data/tembung_data.dart';
import '../services/tembung_loader.dart';
import '../services/sound_service.dart';

class TembungPage extends StatefulWidget {
  const TembungPage({super.key});

  @override
  State<TembungPage> createState() => _TembungPageState();
}

class _TembungPageState extends State<TembungPage> {
  static const int pageSize = 9;

  late Future<List<TembungData>> _dictionaryFuture;

  final TextEditingController _searchController = TextEditingController();

  int _currentPage = 0;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _dictionaryFuture = TembungLoader.loadDictionary();

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
      _currentPage = 0;
    });
  }

  List<TembungData> _filterData(List<TembungData> data) {
    if (_searchQuery.isEmpty) {
      return data;
    }

    return data.where((item) {
      return item.ngoko.toLowerCase().contains(_searchQuery) ||
          item.indonesia.toLowerCase().contains(_searchQuery) ||
          item.kramaAlus.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  int _totalPages(int totalItems) {
    return (totalItems / pageSize).ceil();
  }

  List<TembungData> _getCurrentPage(List<TembungData> data) {
    final start = _currentPage * pageSize;

    if (start >= data.length) {
      return [];
    }

    final end = (start + pageSize).clamp(0, data.length);

    return data.sublist(start, end);
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  void _nextPage(int totalPages) {
    if (_currentPage < totalPages - 1) {
      setState(() {
        _currentPage++;
      });
    }
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
                  'Tembung',
                  style: TextStyle(
                    color: AppTheme.text,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sinau kosakata Bahasa Jawa saka dasar.',
                  style: TextStyle(color: AppTheme.muted, fontFamily: 'Arial'),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: 500,
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: AppTheme.text),
                    decoration: InputDecoration(
                      hintText: 'Goleki tembung...',
                      hintStyle: const TextStyle(color: AppTheme.muted),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppTheme.muted,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                              },
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
                ),
                const SizedBox(height: 35),
                FutureBuilder<List<TembungData>>(
                  future: _dictionaryFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.paper,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.red.withOpacity(.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Gagal memuat tembung',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              snapshot.error.toString(),
                              style: const TextStyle(color: AppTheme.muted),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _currentPage = 0;
                                  _dictionaryFuture =
                                      TembungLoader.loadDictionary();
                                });
                              },
                              child: const Text('Coba maneh'),
                            ),
                          ],
                        ),
                      );
                    }

                    final data = snapshot.data ?? [];
                    final filteredData = _filterData(data);

                    if (filteredData.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Text(
                            'Tembung ora ditemokake.',
                            style: TextStyle(color: AppTheme.muted),
                          ),
                        ),
                      );
                    }

                    final totalPages = _totalPages(filteredData.length);

                    if (_currentPage >= totalPages) {
                      _currentPage = totalPages - 1;
                    }

                    final currentData = _getCurrentPage(filteredData);

                    return Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${filteredData.length} tembung ditemokake',
                            style: const TextStyle(
                              color: AppTheme.muted,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Wrap(
                          spacing: 18,
                          runSpacing: 18,
                          children: currentData.map((item) {
                            return VocabularyCard(data: item);
                          }).toList(),
                        ),
                        const SizedBox(height: 35),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: _currentPage > 0
                                  ? _previousPage
                                  : null,
                              icon: const Icon(Icons.chevron_left_rounded),
                            ),
                            const SizedBox(width: 15),
                            Text(
                              '${_currentPage + 1} / $totalPages',
                              style: const TextStyle(
                                color: AppTheme.text,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 15),
                            IconButton(
                              onPressed: _currentPage < totalPages - 1
                                  ? () => _nextPage(totalPages)
                                  : null,
                              icon: const Icon(Icons.chevron_right_rounded),
                            ),
                          ],
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

class VocabularyCard extends StatelessWidget {
  final TembungData data;

  const VocabularyCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.gold.withOpacity(.2)),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.ngoko,
                style: const TextStyle(
                  color: AppTheme.green,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                data.indonesia,
                style: const TextStyle(
                  color: AppTheme.text,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Arial',
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'Krama: ${data.kramaAlus}',
                style: const TextStyle(
                  color: AppTheme.muted,
                  fontSize: 13,
                  fontFamily: 'Arial',
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            child: IconButton(
              onPressed: () {
                SoundService.instance.playNgoko(data.uid);
              },
              icon: const Icon(Icons.volume_up_rounded),
            ),
          ),
        ],
      ),
    );
  }
}
