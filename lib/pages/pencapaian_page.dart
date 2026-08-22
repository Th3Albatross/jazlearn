import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';

class PencapaianPage extends StatelessWidget {
  const PencapaianPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(45),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1100,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pencapaian',
                  style: TextStyle(
                    color: AppTheme.text,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Lihat perkembangan belajar Bahasa Jawamu.',
                  style: TextStyle(
                    color: AppTheme.muted,
                    fontFamily: 'Arial',
                  ),
                ),
                const SizedBox(height: 35),
                Row(
                  children: [
                    Expanded(
                      child: _stat(
                        '35%',
                        'Progress',
                        Icons.auto_graph_rounded,
                        AppTheme.green,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: _stat(
                        '30',
                        'Materi',
                        Icons.menu_book_rounded,
                        AppTheme.brown,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: _stat(
                        '12',
                        'Latihan',
                        Icons.quiz_rounded,
                        const Color(0xFF8A6332),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppTheme.paper,
                    borderRadius:
                        BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lencana yang Didapat',
                        style: TextStyle(
                          color: AppTheme.text,
                          fontSize: 20,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Wrap(
                        spacing: 25,
                        runSpacing: 25,
                        children: const [
                          Achievement(
                            icon: Icons.star_rounded,
                            title: 'Pemula',
                            description:
                                'Menyelesaikan materi pertama',
                          ),
                          Achievement(
                            icon:
                                Icons.menu_book_rounded,
                            title: 'Rajin Maca',
                            description:
                                'Menyelesaikan 10 materi',
                          ),
                          Achievement(
                            icon:
                                Icons.local_fire_department_rounded,
                            title: 'Semangat',
                            description:
                                'Belajar selama 7 hari',
                          ),
                        ],
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

  Widget _stat(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 30,
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color:
                      Colors.white.withOpacity(.7),
                  fontSize: 12,
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

class Achievement extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const Achievement({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color:
                  AppTheme.gold.withOpacity(.25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppTheme.brown,
              size: 27,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppTheme.muted,
                    fontSize: 11,
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

