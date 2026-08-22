import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';

class LatihanPage extends StatefulWidget {
  const LatihanPage({super.key});

  @override
  State<LatihanPage> createState() => _LatihanPageState();
}

class _LatihanPageState extends State<LatihanPage> {
  int selected = -1;
  bool submitted = false;

  final answers = [
    'Makan',
    'Tidur',
    'Minum',
    'Berjalan',
  ];

  void submit() {
    setState(() {
      submitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(45),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 900,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
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
                  'Uji pemahamanmu mengenai Bahasa Jawa.',
                  style: TextStyle(
                    color: AppTheme.muted,
                    fontFamily: 'Arial',
                  ),
                ),
                const SizedBox(height: 35),
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: AppTheme.paper,
                    borderRadius:
                        BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pertanyaan 01',
                        style: TextStyle(
                          color: AppTheme.green,
                          fontWeight:
                              FontWeight.w800,
                          fontFamily: 'Arial',
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Apa arti dari kata "Mangan"?',
                        style: TextStyle(
                          color: AppTheme.text,
                          fontSize: 24,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 25),
                      ...List.generate(
                        answers.length,
                        (index) {
                          final active =
                              selected == index;

                          return Padding(
                            padding:
                                const EdgeInsets.only(
                              bottom: 10,
                            ),
                            child: InkWell(
                              borderRadius:
                                  BorderRadius.circular(13),
                              onTap: () {
                                setState(() {
                                  selected = index;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(
                                  milliseconds: 150,
                                ),
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.all(
                                  17,
                                ),
                                decoration: BoxDecoration(
                                  color: active
                                      ? AppTheme.green
                                      : Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(
                                    13,
                                  ),
                                ),
                                child: Text(
                                  answers[index],
                                  style: TextStyle(
                                    color: active
                                        ? Colors.white
                                        : AppTheme.text,
                                    fontWeight:
                                        FontWeight.w600,
                                    fontFamily: 'Arial',
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 15),
                      FilledButton(
                        onPressed:
                            selected == -1 ? null : submit,
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              AppTheme.green,
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 15,
                          ),
                        ),
                        child: const Text(
                          'Periksa Jawaban',
                        ),
                      ),
                      if (submitted)
                        Padding(
                          padding:
                              const EdgeInsets.only(
                            top: 20,
                          ),
                          child: Text(
                            selected == 0
                                ? '✓ Jawaban benar!'
                                : 'Coba lagi, jawaban yang benar adalah Makan.',
                            style: TextStyle(
                              color: selected == 0
                                  ? AppTheme.green
                                  : AppTheme.brown,
                              fontWeight:
                                  FontWeight.w700,
                              fontFamily: 'Arial',
                            ),
                          ),
                        ),
                    ],
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

