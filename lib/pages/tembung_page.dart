import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../data/tembung_data.dart';
import '../services/tembung_loader.dart';
import '../services/sound_service.dart';

enum LanguageMode {
  ngoko,
  krama,
}

class TembungPage extends StatefulWidget {
  const TembungPage({super.key});

  @override
  State<TembungPage> createState() => _TembungPageState();
}

class _TembungPageState extends State<TembungPage> {
  static const int pageSize = 9;

  late Future<List<TembungData>> _dictionaryFuture;

  final TextEditingController _searchController =
      TextEditingController();

  int _currentPage = 0;
  String _searchQuery = '';
  LanguageMode _languageMode = LanguageMode.ngoko;

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

  void _changeLanguageMode(LanguageMode mode) {
    setState(() {
      _languageMode = mode;
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
        child: Align(
          alignment: Alignment.topCenter,
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
                  'Cari kosakata dalam bahasa jawa',
                  style: TextStyle(
                    color: AppTheme.muted,
                    fontFamily: 'Arial',
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(
                          color: AppTheme.text,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Cari kosakata...',
                          hintStyle: const TextStyle(
                            color: AppTheme.muted,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: AppTheme.muted,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                  icon: const Icon(
                                    Icons.close_rounded,
                                  ),
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
                    const SizedBox(width: 18),
                    _LanguageSelector(
                      mode: _languageMode,
                      onChanged: _changeLanguageMode,
                    ),
                  ],
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
                      return _ErrorBox(
                        error: snapshot.error.toString(),
                        onRetry: () {
                          setState(() {
                            _currentPage = 0;
                            _dictionaryFuture =
                                TembungLoader.loadDictionary();
                          });
                        },
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
                            style: TextStyle(
                              color: AppTheme.muted,
                            ),
                          ),
                        ),
                      );
                    }

                    final totalPages =
                        _totalPages(filteredData.length);

                    if (_currentPage >= totalPages) {
                      _currentPage = totalPages - 1;
                    }

                    final currentData =
                        _getCurrentPage(filteredData);

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
                            return VocabularyCard(
                              data: item,
                              mode: _languageMode,
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
  final LanguageMode mode;

  const VocabularyCard({
    super.key,
    required this.data,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNgoko = mode == LanguageMode.ngoko;

    final String word =
        isNgoko ? data.ngoko : data.kramaAlus;

    return Container(
      width: 350,
      height: 150,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.gold.withOpacity(.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  word,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.green,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: AppTheme.green.withOpacity(.1),
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    if (isNgoko) {
                      SoundService.instance
                          .playNgoko(data.uid);
                    } else {
                      SoundService.instance
                          .playKrama(data.uid);
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.volume_up_rounded,
                      color: AppTheme.green,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            data.indonesia,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.text,
              fontWeight: FontWeight.w700,
              fontFamily: 'Arial',
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: AppTheme.gold.withOpacity(.1),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              isNgoko ? 'NGOKO' : 'KRAMA',
              style: const TextStyle(
                color: AppTheme.gold,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  final LanguageMode mode;
  final ValueChanged<LanguageMode> onChanged;

  const _LanguageSelector({
    required this.mode,
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
          color: AppTheme.gold.withOpacity(.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LanguageButton(
            label: 'Ngoko',
            selected: mode == LanguageMode.ngoko,
            onTap: () {
              onChanged(LanguageMode.ngoko);
            },
          ),
          _LanguageButton(
            label: 'Krama',
            selected: mode == LanguageMode.krama,
            onTap: () {
              onChanged(LanguageMode.krama);
            },
          ),
        ],
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppTheme.green
          : Colors.transparent,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 9,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? Colors.white
                  : AppTheme.muted,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
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
            'Gagal memuat tembung',
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

