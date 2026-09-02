import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../data/tembung_data.dart';
import '../repository/tembung_repository.dart';
import '../data/aksara_data.dart';

enum QuizType {
  tebakArti,
  tebakTembung,
  ngokoKrama,
  tebakAksara,
}

enum QuizDifficulty {
  easy,
  medium,
  hard,
}

class QuizQuestion {
  final String prompt;
  final String answer;
  final List<String> options;
  final String? contextLabel;

  const QuizQuestion({
    required this.prompt,
    required this.answer,
    required this.options,
    this.contextLabel,
  });
}

class QuizResultItem {
  final QuizQuestion question;
  final String? selectedAnswer;

  const QuizResultItem({
    required this.question,
    required this.selectedAnswer,
  });

  bool get isCorrect => selectedAnswer == question.answer;
}

class LatihanPage extends StatefulWidget {
  const LatihanPage({super.key});

  @override
  State<LatihanPage> createState() => _LatihanPageState();
}

class _LatihanPageState extends State<LatihanPage> {
  final Random _random = Random();

  late Future<List<TembungData>> _dictionaryFuture;

  QuizType? _selectedQuizType;
  QuizDifficulty _selectedDifficulty = QuizDifficulty.medium;
  List<QuizQuestion> _questions = [];
  List<QuizResultItem> _results = [];
  int _currentQuestion = 0;
  String? _selectedAnswer;
  bool _submitted = false;
  bool _finished = false;
  bool _quizStarted = false;

  @override
  void initState() {
    super.initState();
    _dictionaryFuture = TembungRepository.instance.getAll();
  }

  int _questionCount(QuizDifficulty difficulty) {
    switch (difficulty) {
      case QuizDifficulty.easy:
        return 5;
      case QuizDifficulty.medium:
        return 10;
      case QuizDifficulty.hard:
        return 20;
    }
  }

  void _startQuiz(
    QuizType type,
    List<TembungData> data, {
    QuizDifficulty? difficulty,
  }) {
    final activeDifficulty = difficulty ?? _selectedDifficulty;
    final questions = _buildQuestions(
      type,
      data,
      count: _questionCount(activeDifficulty),
    );

    if (questions.isEmpty) {
      return;
    }

    setState(() {
      _selectedQuizType = type;
      _selectedDifficulty = activeDifficulty;
      _questions = questions;
      _results = [];
      _currentQuestion = 0;
      _selectedAnswer = null;
      _submitted = false;
      _finished = false;
      _quizStarted = true;
    });
  }

  List<TembungData> _takeRandomItems(
    List<TembungData> data,
    int count,
  ) {
    final target = min(count, data.length);
    final indexes = <int>{};

    while (indexes.length < target) {
      indexes.add(_random.nextInt(data.length));
    }

    return indexes.map((index) => data[index]).toList(growable: false);
  }

  List<QuizQuestion> _buildQuestions(
    QuizType type,
    List<TembungData> data, {
    int count = 10,
  }) {
    if (type == QuizType.tebakAksara) {
      if (aksaraData.length < 4) {
        return [];
      }

      final selectedItems = _takeRandomAksaraItems(count);
      final aksaraPool = _uniqueNonEmpty(aksaraData.map((e) => e.aksara));

      return selectedItems.map((item) {
        return QuizQuestion(
          contextLabel: 'TEBAK AKSARA JAWA',
          prompt: 'Apa aksara dari kata "${item.pelafalan}"?',
          answer: item.aksara,
          options: _buildOptions(
            correct: item.aksara,
            pool: aksaraPool,
          ),
        );
      }).toList(growable: false);
    }

    if (data.length < 4) {
      return [];
    }

    final selectedItems = _takeRandomItems(data, count);

    final indonesiaPool = _uniqueNonEmpty(data.map((e) => e.indonesia));
    final ngokoPool = _uniqueNonEmpty(data.map((e) => e.ngoko));
    final kramaPool = _uniqueNonEmpty(data.map((e) => e.kramaAlus));

    return selectedItems.map((item) {
      switch (type) {
        case QuizType.tebakArti:
          return QuizQuestion(
            contextLabel: 'TEBAK ARTI',
            prompt: 'Apa arti dari kata "${item.ngoko}"?',
            answer: item.indonesia,
            options: _buildOptions(
              correct: item.indonesia,
              pool: indonesiaPool,
            ),
          );
        case QuizType.tebakTembung:
          return QuizQuestion(
            contextLabel: 'TEBAK TEMBUNG',
            prompt: 'Bahasa Jawa dari "${item.indonesia}" adalah...',
            answer: item.ngoko,
            options: _buildOptions(
              correct: item.ngoko,
              pool: ngokoPool,
            ),
          );
        case QuizType.ngokoKrama:
          return QuizQuestion(
            contextLabel: 'NGOKO → KRAMA',
            prompt: 'Bentuk Krama Alus dari "${item.ngoko}" adalah...',
            answer: item.kramaAlus,
            options: _buildOptions(
              correct: item.kramaAlus,
              pool: kramaPool,
            ),
          );
        case QuizType.tebakAksara:
          throw StateError('Tebak Aksara Jawa ditangani sebelum data tembung.');
      }
    }).toList(growable: false);
  }

  List<AksaraData> _takeRandomAksaraItems(int count) {
    final target = min(count, aksaraData.length);
    final items = [...aksaraData]..shuffle(_random);
    return items.take(target).toList(growable: false);
  }

  List<String> _uniqueNonEmpty(Iterable<String> values) {
    return values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList(growable: false);
  }

  List<String> _buildOptions({
    required String correct,
    required List<String> pool,
  }) {
    if (pool.isEmpty) {
      return <String>[correct];
    }

    final target = min(3, pool.length - (pool.contains(correct) ? 1 : 0));
    final selected = <String>{correct};

    while (selected.length - 1 < target) {
      selected.add(pool[_random.nextInt(pool.length)]);
    }

    final options = selected.toList()..shuffle(_random);
    return options;
  }

  void _selectAnswer(String answer) {
    if (_submitted) {
      return;
    }

    setState(() {
      _selectedAnswer = answer;
    });
  }

  void _submitAnswer() {
    if (_selectedAnswer == null || _submitted) {
      return;
    }

    final question = _questions[_currentQuestion];

    setState(() {
      _submitted = true;
      _results.add(
        QuizResultItem(
          question: question,
          selectedAnswer: _selectedAnswer,
        ),
      );
    });
  }

  void _nextQuestion() {
    if (!_submitted) {
      return;
    }

    if (_currentQuestion >= _questions.length - 1) {
      setState(() {
        _finished = true;
      });
      return;
    }

    setState(() {
      _currentQuestion++;
      _selectedAnswer = null;
      _submitted = false;
    });
  }

  void _restartQuiz() {
    final type = _selectedQuizType;

    if (type == null) {
      return;
    }

    _dictionaryFuture.then((data) {
      if (mounted) {
        _startQuiz(
          type,
          data,
          difficulty: _selectedDifficulty,
        );
      }
    });
  }

  void _backToQuizSelection() {
    setState(() {
      _selectedQuizType = null;
      _selectedDifficulty = QuizDifficulty.medium;
      _questions = [];
      _results = [];
      _currentQuestion = 0;
      _selectedAnswer = null;
      _submitted = false;
      _finished = false;
      _quizStarted = false;
    });
  }

  int get _correctCount =>
      _results.where((result) => result.isCorrect).length;

  int get _wrongCount => _results.length - _correctCount;

  int get _scorePercentage {
    if (_questions.isEmpty) {
      return 0;
    }

    return ((_correctCount / _questions.length) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(45),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: FutureBuilder<List<TembungData>>(
              future: _dictionaryFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 400,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return _ErrorView(
                    error: snapshot.error.toString(),
                    onRetry: () {
                      setState(() {
                        _dictionaryFuture =
                            TembungRepository.instance.reload();
                      });
                    },
                  );
                }

                final data = snapshot.data ?? [];

                if (data.length < 4 && _selectedQuizType != QuizType.tebakAksara) {
                  return const _EmptyDataView();
                }

                if (!_quizStarted) {
                  return _QuizSelectionView(
                    selectedQuizType: _selectedQuizType,
                    selectedDifficulty: _selectedDifficulty,
                    onQuizTypeChanged: (type) {
                      setState(() {
                        _selectedQuizType = type;
                      });
                    },
                    onDifficultyChanged: (difficulty) {
                      setState(() {
                        _selectedDifficulty = difficulty;
                      });
                    },
                    onStart: () {
                      if (_selectedQuizType == null) {
                        return;
                      }

                      _startQuiz(
                        _selectedQuizType!,
                        data,
                        difficulty: _selectedDifficulty,
                      );
                    },
                  );
                }

                if (_finished) {
                  return _QuizResultView(
                    quizType: _selectedQuizType!,
                    difficulty: _selectedDifficulty,
                    total: _questions.length,
                    correct: _correctCount,
                    wrong: _wrongCount,
                    scorePercentage: _scorePercentage,
                    results: _results,
                    onRestart: _restartQuiz,
                    onBack: _backToQuizSelection,
                  );
                }

                return _QuizQuestionView(
                  quizType: _selectedQuizType!,
                  question: _questions[_currentQuestion],
                  questionNumber: _currentQuestion + 1,
                  totalQuestions: _questions.length,
                  selectedAnswer: _selectedAnswer,
                  submitted: _submitted,
                  onSelect: _selectAnswer,
                  onSubmit: _submitAnswer,
                  onNext: _nextQuestion,
                  onBack: _backToQuizSelection,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _QuizSelectionView extends StatefulWidget {
  final QuizType? selectedQuizType;
  final QuizDifficulty selectedDifficulty;
  final ValueChanged<QuizType> onQuizTypeChanged;
  final ValueChanged<QuizDifficulty> onDifficultyChanged;
  final VoidCallback onStart;

  const _QuizSelectionView({
    required this.selectedQuizType,
    required this.selectedDifficulty,
    required this.onQuizTypeChanged,
    required this.onDifficultyChanged,
    required this.onStart,
  });

  @override
  State<_QuizSelectionView> createState() => _QuizSelectionViewState();
}

class _QuizSelectionViewState extends State<_QuizSelectionView> {
  final ScrollController _quizScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _quizScrollController.addListener(_onQuizScroll);
  }

  void _onQuizScroll() {
    if (mounted) setState(() {});
  }

  bool get _canScrollRight =>
      _quizScrollController.hasClients &&
      _quizScrollController.position.maxScrollExtent > 2 &&
      _quizScrollController.position.pixels <
          _quizScrollController.position.maxScrollExtent - 2;

  @override
  void dispose() {
    _quizScrollController.removeListener(_onQuizScroll);
    _quizScrollController.dispose();
    super.dispose();
  }

  String _difficultyTitle(QuizDifficulty difficulty) {
    switch (difficulty) {
      case QuizDifficulty.easy:
        return 'Easy';
      case QuizDifficulty.medium:
        return 'Medium';
      case QuizDifficulty.hard:
        return 'Hard';
    }
  }

  int _questionCount(QuizDifficulty difficulty) {
    switch (difficulty) {
      case QuizDifficulty.easy:
        return 5;
      case QuizDifficulty.medium:
        return 10;
      case QuizDifficulty.hard:
        return 20;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Latihan',
          style: TextStyle(
            color: AppTheme.text,
            fontSize: 34,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Pilih jenis latihan dan tingkat kesulitan yang ingin kamu mainkan.',
          style: TextStyle(
            color: AppTheme.muted,
            fontFamily: 'Arial',
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Varian Latihan',
          style: TextStyle(
            color: AppTheme.text,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final cards = [
              _QuizTypeCard(
                title: 'Tebak Arti',
                description: 'Tebak arti tembung Jawa dalam Bahasa Indonesia.',
                icon: Icons.translate_rounded,
                selected: widget.selectedQuizType == QuizType.tebakArti,
                onTap: () => widget.onQuizTypeChanged(QuizType.tebakArti),
              ),
              _QuizTypeCard(
                title: 'Tebak Tembung',
                description: 'Pilih tembung Jawa yang sesuai dengan artinya.',
                icon: Icons.menu_book_rounded,
                selected: widget.selectedQuizType == QuizType.tebakTembung,
                onTap: () => widget.onQuizTypeChanged(QuizType.tebakTembung),
              ),
              _QuizTypeCard(
                title: 'Ngoko → Krama',
                description: 'Latih pasangan kata Ngoko dan Krama Alus.',
                icon: Icons.record_voice_over_rounded,
                selected: widget.selectedQuizType == QuizType.ngokoKrama,
                onTap: () => widget.onQuizTypeChanged(QuizType.ngokoKrama),
              ),
              _QuizTypeCard(
                title: 'Tebak Aksara Jawa',
                description: 'Tebak simbol aksara Jawa dari pelafalannya.',
                icon: Icons.edit_rounded,
                selected: widget.selectedQuizType == QuizType.tebakAksara,
                onTap: () => widget.onQuizTypeChanged(QuizType.tebakAksara),
              ),
            ];

            final cardWidth = constraints.maxWidth >= 700
                ? (constraints.maxWidth - 32) / 3
                : constraints.maxWidth;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 22),
                      child: ScrollConfiguration(
                        behavior: const MaterialScrollBehavior().copyWith(
                          dragDevices: {
                            PointerDeviceKind.touch,
                            PointerDeviceKind.mouse,
                            PointerDeviceKind.trackpad,
                          },
                        ),
                        child: Scrollbar(
                          controller: _quizScrollController,
                          thumbVisibility: true,
                          trackVisibility: true,
                          thickness: 10,
                          radius: const Radius.circular(12),
                          interactive: true,
                          child: SingleChildScrollView(
                            controller: _quizScrollController,
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.only(top: 6, bottom: 42),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (int i = 0; i < cards.length; i++)
                                  Padding(
                                    padding: EdgeInsets.only(
                                      right: i == cards.length - 1 ? 0 : 16,
                                    ),
                                    child: SizedBox(
                                      width: cardWidth,
                                      child: cards[i],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      bottom: 44,
                      child: IgnorePointer(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 180),
                          opacity: _canScrollRight ? 1 : 0,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              margin: const EdgeInsets.only(right: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.paper.withOpacity(.96),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: AppTheme.green.withOpacity(.18),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(.08),
                                    blurRadius: 14,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Geser',
                                    style: TextStyle(
                                      color: AppTheme.green,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'Arial',
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppTheme.green,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: _canScrollRight ? 1 : 0,
                  child: Row(
                    children: const [
                      Icon(
                        Icons.swipe_rounded,
                        color: AppTheme.muted,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Geser ke kanan untuk melihat latihan lainnya',
                        style: TextStyle(
                          color: AppTheme.muted,
                          fontSize: 11,
                          fontFamily: 'Arial',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 30),
        const Text(
          'Tingkat Kesulitan',
          style: TextStyle(
            color: AppTheme.text,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final cards = QuizDifficulty.values.map((difficulty) {
              final selected = widget.selectedDifficulty == difficulty;

              return _DifficultyCard(
                title: _difficultyTitle(difficulty),
                count: _questionCount(difficulty),
                selected: selected,
                onTap: () => widget.onDifficultyChanged(difficulty),
              );
            }).toList();

            if (constraints.maxWidth < 700) {
              return Column(
                children: cards
                    .map(
                      (card) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SizedBox(
                          width: double.infinity,
                          child: card,
                        ),
                      ),
                    )
                    .toList(),
              );
            }

            return Row(
              children: cards
                  .map(
                    (card) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: card,
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 28),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: widget.selectedQuizType == null ? null : widget.onStart,
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.green,
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 14,
              ),
            ),
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(
              widget.selectedQuizType == null
                  ? 'Pilih Varian Latihan'
                  : 'Mulai ${_difficultyTitle(widget.selectedDifficulty)}',
            ),
          ),
        ),
      ],
    );
  }
}

class _DifficultyCard extends StatefulWidget {
  final String title;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _DifficultyCard({
    required this.title,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_DifficultyCard> createState() => _DifficultyCardState();
}

class _DifficultyCardState extends State<_DifficultyCard> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected || hover;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: widget.selected ? AppTheme.green : AppTheme.paper,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.selected
                  ? AppTheme.green
                  : AppTheme.gold.withOpacity(active ? .45 : .15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  color: widget.selected ? Colors.white : AppTheme.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${widget.count} soal',
                style: TextStyle(
                  color: widget.selected
                      ? Colors.white70
                      : AppTheme.muted,
                  fontSize: 12,
                  fontFamily: 'Arial',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizTypeCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _QuizTypeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_QuizTypeCard> createState() => _QuizTypeCardState();
}

class _QuizTypeCardState extends State<_QuizTypeCard> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected || hover;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          transform: Matrix4.translationValues(0, hover ? -5 : 0, 0),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: widget.selected
                ? AppTheme.green.withOpacity(.08)
                : AppTheme.paper,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: widget.selected
                  ? AppTheme.green
                  : AppTheme.gold.withOpacity(active ? .45 : .15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(hover ? .10 : .05),
                blurRadius: hover ? 22 : 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: widget.selected
                      ? AppTheme.green.withOpacity(.12)
                      : AppTheme.green.withOpacity(.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.quiz_rounded,
                  color: AppTheme.green,
                  size: 28,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.title,
                style: const TextStyle(
                  color: AppTheme.text,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.description,
                style: const TextStyle(
                  color: AppTheme.muted,
                  fontSize: 13,
                  height: 1.5,
                  fontFamily: 'Arial',
                ),
              ),
              const SizedBox(height: 24),
              const Row(
                children: [
                  Text(
                    'Mulai latihan',
                    style: TextStyle(
                      color: AppTheme.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Arial',
                    ),
                  ),
                  Spacer(),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: AppTheme.green,
                    size: 19,
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

class _QuizQuestionView extends StatelessWidget {
  final QuizType quizType;
  final QuizQuestion question;
  final int questionNumber;
  final int totalQuestions;
  final String? selectedAnswer;
  final bool submitted;
  final ValueChanged<String> onSelect;
  final VoidCallback onSubmit;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _QuizQuestionView({
    required this.quizType,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.selectedAnswer,
    required this.submitted,
    required this.onSelect,
    required this.onSubmit,
    required this.onNext,
    required this.onBack,
  });

  String get _title {
    switch (quizType) {
      case QuizType.tebakArti:
        return 'Tebak Arti';
      case QuizType.tebakTembung:
        return 'Tebak Tembung';
      case QuizType.ngokoKrama:
        return 'Ngoko → Krama';
      case QuizType.tebakAksara:
        return 'Tebak Aksara Jawa';
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = questionNumber / totalQuestions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded, size: 18),
          label: const Text('Kembali ke latihan'),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _title,
              style: const TextStyle(
                color: AppTheme.text,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              '$questionNumber / $totalQuestions',
              style: const TextStyle(
                color: AppTheme.green,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                fontFamily: 'Arial',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: const Color(0xFFE1D4BE),
            color: AppTheme.green,
          ),
        ),
        const SizedBox(height: 28),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: AppTheme.paper,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (question.contextLabel != null)
                Text(
                  question.contextLabel!,
                  style: const TextStyle(
                    color: AppTheme.green,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Arial',
                    letterSpacing: .5,
                  ),
                ),
              const SizedBox(height: 14),
              Text(
                question.prompt,
                style: const TextStyle(
                  color: AppTheme.text,
                  fontSize: 24,
                  height: 1.35,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 26),
              ...question.options.map(
                (option) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _AnswerOption(
                    text: option,
                    selected: selectedAnswer == option,
                    submitted: submitted,
                    correct: option == question.answer,
                    isAksara: quizType == QuizType.tebakAksara,
                    onTap: () => onSelect(option),
                  ),
                ),
              ),
              if (submitted) ...[
                const SizedBox(height: 8),
                _FeedbackBox(
                  correct: selectedAnswer == question.answer,
                  selectedAnswer: selectedAnswer,
                  correctAnswer: question.answer,
                ),
              ],
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: submitted
                      ? onNext
                      : selectedAnswer == null
                          ? null
                          : onSubmit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 14,
                    ),
                  ),
                  icon: Icon(
                    submitted
                        ? Icons.arrow_forward_rounded
                        : Icons.check_rounded,
                  ),
                  label: Text(
                    submitted ? 'Soal Berikutnya' : 'Jawab',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnswerOption extends StatelessWidget {
  final String text;
  final bool selected;
  final bool submitted;
  final bool correct;
  final bool isAksara;
  final VoidCallback onTap;

  const _AnswerOption({
    required this.text,
    required this.selected,
    required this.submitted,
    required this.correct,
    required this.isAksara,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color background = Colors.white;
    Color border = const Color(0xFFE5D8C3);
    Color textColor = AppTheme.text;

    if (submitted && correct) {
      background = AppTheme.green.withOpacity(.12);
      border = AppTheme.green;
      textColor = AppTheme.green;
    } else if (submitted && selected && !correct) {
      background = AppTheme.brown.withOpacity(.10);
      border = AppTheme.brown;
      textColor = AppTheme.brown;
    } else if (selected) {
      background = AppTheme.green;
      border = AppTheme.green;
      textColor = Colors.white;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: submitted ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  textAlign: isAksara ? TextAlign.center : TextAlign.start,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: isAksara ? 30 : 14,
                    height: isAksara ? 1.2 : null,
                    fontFamily: isAksara ? null : 'Arial',
                  ),
                ),
              ),
              if (submitted && correct)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.green,
                  size: 20,
                ),
              if (submitted && selected && !correct)
                const Icon(
                  Icons.cancel_rounded,
                  color: AppTheme.brown,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedbackBox extends StatelessWidget {
  final bool correct;
  final String? selectedAnswer;
  final String correctAnswer;

  const _FeedbackBox({
    required this.correct,
    required this.selectedAnswer,
    required this.correctAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: correct
            ? AppTheme.green.withOpacity(.08)
            : AppTheme.brown.withOpacity(.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: correct
              ? AppTheme.green.withOpacity(.2)
              : AppTheme.brown.withOpacity(.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            correct ? '✓ Jawaban benar!' : '✕ Jawaban kurang tepat.',
            style: TextStyle(
              color: correct ? AppTheme.green : AppTheme.brown,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          if (!correct && selectedAnswer != null)
            Text(
              'Jawabanmu: $selectedAnswer',
              style: const TextStyle(
                color: AppTheme.muted,
                fontSize: 12,
                fontFamily: 'Arial',
              ),
            ),
          if (!correct)
            Text(
              'Jawaban yang benar: $correctAnswer',
              style: const TextStyle(
                color: AppTheme.text,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFamily: 'Arial',
              ),
            ),
        ],
      ),
    );
  }
}

class _QuizResultView extends StatelessWidget {
  final QuizType quizType;
  final QuizDifficulty difficulty;
  final int total;
  final int correct;
  final int wrong;
  final int scorePercentage;
  final List<QuizResultItem> results;
  final VoidCallback onRestart;
  final VoidCallback onBack;

  const _QuizResultView({
    required this.quizType,
    required this.difficulty,
    required this.total,
    required this.correct,
    required this.wrong,
    required this.scorePercentage,
    required this.results,
    required this.onRestart,
    required this.onBack,
  });

  String get _title {
    switch (quizType) {
      case QuizType.tebakArti:
        return 'Tebak Arti';
      case QuizType.tebakTembung:
        return 'Tebak Tembung';
      case QuizType.ngokoKrama:
        return 'Ngoko → Krama';
      case QuizType.tebakAksara:
        return 'Tebak Aksara Jawa';
    }
  }

  String get _difficultyLabel {
    switch (difficulty) {
      case QuizDifficulty.easy:
        return 'Easy';
      case QuizDifficulty.medium:
        return 'Medium';
      case QuizDifficulty.hard:
        return 'Hard';
    }
  }

  @override
  Widget build(BuildContext context) {
    final mistakes = results.where((result) => !result.isCorrect).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded, size: 18),
          label: const Text('Kembali ke latihan'),
        ),
        const SizedBox(height: 10),
        const Text(
          'Latihan selesai 🎉',
          style: TextStyle(
            color: AppTheme.text,
            fontSize: 34,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$_title · $_difficultyLabel',
          style: const TextStyle(
            color: AppTheme.muted,
            fontFamily: 'Arial',
          ),
        ),
        const SizedBox(height: 28),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppTheme.paper,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Text(
                '$correct / $total',
                style: const TextStyle(
                  color: AppTheme.green,
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '$scorePercentage% benar',
                style: const TextStyle(
                  color: AppTheme.muted,
                  fontSize: 13,
                  fontFamily: 'Arial',
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _ResultStat(
                      value: '$correct',
                      label: 'Benar',
                      icon: Icons.check_circle_rounded,
                      color: AppTheme.green,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _ResultStat(
                      value: '$wrong',
                      label: 'Salah',
                      icon: Icons.cancel_rounded,
                      color: AppTheme.brown,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: onBack,
                    child: const Text('Pilih Latihan Lain'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: onRestart,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.green,
                    ),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Ulangi'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        if (mistakes.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.green.withOpacity(.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.green.withOpacity(.16),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.emoji_events_rounded,
                  color: AppTheme.gold,
                  size: 30,
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Mantap! Semua jawabanmu benar.',
                    style: TextStyle(
                      color: AppTheme.text,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          )
        else ...[
          const Text(
            'Letak Kesalahan',
            style: TextStyle(
              color: AppTheme.text,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          ...mistakes.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _MistakeCard(
                    number: entry.key + 1,
                    result: entry.value,
                  ),
                ),
              ),
        ],
      ],
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _ResultStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(.75),
                  fontSize: 11,
                  fontFamily: 'Arial',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MistakeCard extends StatelessWidget {
  final int number;
  final QuizResultItem result;

  const _MistakeCard({
    required this.number,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.gold.withOpacity(.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.brown.withOpacity(.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: AppTheme.brown,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.question.prompt,
                  style: const TextStyle(
                    color: AppTheme.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Jawabanmu: ${result.selectedAnswer ?? '-'}',
                  style: const TextStyle(
                    color: AppTheme.brown,
                    fontSize: 12,
                    fontFamily: 'Arial',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Seharusnya: ${result.question.answer}',
                  style: const TextStyle(
                    color: AppTheme.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Arial',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.red.withOpacity(.2),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.red,
            size: 40,
          ),
          const SizedBox(height: 10),
          const Text(
            'Gagal memuat tembung',
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
            style: const TextStyle(
              color: AppTheme.muted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Coba maneh'),
          ),
        ],
      ),
    );
  }
}

class _EmptyDataView extends StatelessWidget {
  const _EmptyDataView();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 300,
      child: Center(
        child: Text(
          'Durung cukup data tembung kanggo latihan.',
          style: TextStyle(
            color: AppTheme.muted,
          ),
        ),
      ),
    );
  }
}

