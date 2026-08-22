import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/course_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(45),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1200,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _topBar(),
                const SizedBox(height: 30),
                _hero(),
                const SizedBox(height: 45),
                _sectionTitle(),
                const SizedBox(height: 20),
                _courses(context),
                const SizedBox(height: 30),
                _progress(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Sugeng Rawuh 👋',
                style: TextStyle(
                  color: AppTheme.muted,
                  fontSize: 14,
                  fontFamily: 'Arial',
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Sinau Basa Jawa',
                style: TextStyle(
                  color: AppTheme.text,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 300,
          height: 44,
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
          ),
          decoration: BoxDecoration(
            color: AppTheme.paper,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: AppTheme.muted,
              ),
              SizedBox(width: 10),
              Text(
                'Cari materi...',
                style: TextStyle(
                  color: AppTheme.muted,
                  fontSize: 13,
                  fontFamily: 'Arial',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _hero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppTheme.gold.withOpacity(.18),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color:
                        AppTheme.green.withOpacity(.1),
                    borderRadius:
                        BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'ꦱꦸꦒꦼꦁ ꦫꦮꦸꦃ',
                    style: TextStyle(
                      color: AppTheme.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Sinau Basa Jawa\nkanthi nyenengake.',
                  style: TextStyle(
                    color: AppTheme.text,
                    fontSize: 42,
                    height: 1.08,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Pelajari kosakata, Aksara Jawa, dan unggah-ungguh '
                  'dengan cara yang sederhana dan menyenangkan.',
                  style: TextStyle(
                    color: AppTheme.muted,
                    fontSize: 15,
                    height: 1.6,
                    fontFamily: 'Arial',
                  ),
                ),
                const SizedBox(height: 25),
                FilledButton.icon(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                  icon: const Icon(
                    Icons.play_arrow_rounded,
                  ),
                  label: const Text(
                    'Mulai Belajar',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: AppTheme.green,
              borderRadius: BorderRadius.circular(38),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x332C241C),
                  blurRadius: 25,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'ꦧꦱ\nꦗꦮ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.gold,
                  fontSize: 48,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle() {
    return const Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'Mulai Perjalananmu',
          style: TextStyle(
            color: AppTheme.text,
            fontSize: 25,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Pilih materi yang ingin kamu pelajari.',
          style: TextStyle(
            color: AppTheme.muted,
            fontSize: 13,
            fontFamily: 'Arial',
          ),
        ),
      ],
    );
  }

  Widget _courses(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          CourseCard(
            title: 'Tembung',
            subtitle: 'Kosakata Bahasa Jawa',
            count: '12 Materi',
            icon: Icons.menu_book_rounded,
            color: AppTheme.green,
            onTap: () {
              Navigator.pushReplacementNamed(
                context,
                '/tembung',
              );
            },
          ),
          CourseCard(
            title: 'Aksara Jawa',
            subtitle: 'Maca lan nulis aksara',
            count: '8 Materi',
            icon: Icons.edit_rounded,
            color: AppTheme.brown,
            onTap: () {
              Navigator.pushReplacementNamed(
                context,
                '/aksara',
              );
            },
          ),
          CourseCard(
            title: 'Unggah-Ungguh',
            subtitle: 'Belajar tingkat tutur',
            count: '10 Materi',
            icon: Icons.record_voice_over_rounded,
            color: const Color(0xFF8A6332),
            onTap: () {},
          ),
        ];

        if (constraints.maxWidth < 750) {
          return Column(
            children: cards
                .map(
                  (card) => Padding(
                    padding:
                        const EdgeInsets.only(bottom: 15),
                    child: card,
                  ),
                )
                .toList(),
          );
        }

        return Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: cards
              .map(
                (card) => Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(right: 15),
                    child: card,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _progress() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color:
                  AppTheme.gold.withOpacity(.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_graph_rounded,
              color: Color(0xFF70502D),
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Progress Belajar',
                  style: TextStyle(
                    color: AppTheme.text,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Kamu sudah menyelesaikan 35% materi.',
                  style: TextStyle(
                    color: AppTheme.muted,
                    fontSize: 12,
                    fontFamily: 'Arial',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 150,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: const LinearProgressIndicator(
                value: .35,
                minHeight: 8,
                backgroundColor:
                    Color(0xFFE1D4BE),
                color: AppTheme.green,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            '35%',
            style: TextStyle(
              color: AppTheme.green,
              fontWeight: FontWeight.w800,
              fontFamily: 'Arial',
            ),
          ),
        ],
      ),
    );
  }
}

