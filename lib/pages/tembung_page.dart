import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../data/tembung_data.dart';
import '../loader/tembung_loader.dart';

class TembungPage extends StatefulWidget {
  const TembungPage({super.key});

  @override
  State<TembungPage> createState() => _TembungPageState();
}

class _TembungPageState extends State<TembungPage> {
  static const int pageSize = 9;

  late Future<List<TembungData>> _dictionaryFuture;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _dictionaryFuture = TembungLoader.loadDictionary();
  }

  int _totalPages(int totalItems) {
    return (totalItems / pageSize).ceil();
  }

  List<TembungData> _getCurrentPage(List<TembungData> data) {
    final start = _currentPage * pageSize;
    final end = (start + pageSize).clamp(0, data.length);

    if (start >= data.length) {
      return [];
    }

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
                  style: TextStyle(
                    color: AppTheme.muted,
                    fontFamily: 'Arial',
                  ),
                ),
                const SizedBox(height: 35),
                FutureBuilder<List<TembungData>>(
                  future: _dictionaryFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
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
                          border: Border.all(
                            color: Colors.red.withOpacity(.2),
                          ),
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
                              style: const TextStyle(
                                color: AppTheme.muted,
                              ),
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

                    if (data.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Text(
                            'Durung ana data tembung.',
                            style: TextStyle(
                              color: AppTheme.muted,
                            ),
                          ),
                        ),
                      );
                    }

                    final totalPages = _totalPages(data.length);
                    final currentData = _getCurrentPage(data);

                    return Column(
                      children: [
                        Wrap(
                          spacing: 18,
                          runSpacing: 18,
                          children: currentData.map((item) {
                            return VocabularyCard(
                              data: item,
                            );
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
                              icon: const Icon(
                                Icons.chevron_left_rounded,
                              ),
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
                              onPressed:
                                  _currentPage < totalPages - 1
                                      ? () => _nextPage(totalPages)
                                      : null,
                              icon: const Icon(
                                Icons.chevron_right_rounded,
                              ),
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

  const VocabularyCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.gold.withOpacity(.2),
        ),
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
              onPressed: () {},
              icon: const Icon(
                Icons.volume_up_rounded,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

