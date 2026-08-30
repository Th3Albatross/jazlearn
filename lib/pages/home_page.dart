import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/course_card.dart';

const _homeGuideSteps = [
  _GuideItem(
    number: '01',
    icon: Icons.menu_book_rounded,
    title: 'Pahami materi',
    description: 'Pelajari konsep dan tata bahasa melalui video serta rangkuman.',
    route: '/materi',
  ),
  _GuideItem(
    number: '02',
    icon: Icons.record_voice_over_rounded,
    title: 'Tambah kosakata',
    description: 'Cari tembung dan dengarkan pelafalan Ngoko maupun Krama.',
    route: '/tembung',
  ),
  _GuideItem(
    number: '03',
    icon: Icons.quiz_rounded,
    title: 'Uji pemahaman',
    description: 'Kerjakan latihan untuk menguji seberapa jauh kamu memahami materi.',
    route: '/latihan',
  ),
];

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _goTo(BuildContext context, String route) {
    Navigator.pushReplacementNamed(context, route);
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
                _topBar(context),
                const SizedBox(height: 30),
                _hero(context),
                const SizedBox(height: 45),
                _sectionTitle(),
                const SizedBox(height: 20),
                _courses(context),
                const SizedBox(height: 35),
                _learningGuide(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
        
      ],
    );
  }

  Widget _hero(BuildContext context) {
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 720;

          final textContent = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.green.withOpacity(.1),
                  borderRadius: BorderRadius.circular(30),
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
                'Pelajari kosakata, Aksara Jawa, materi bahasa, dan\nlatihan kuis dalam satu tempat yang sederhana.',
                style: TextStyle(
                  color: AppTheme.muted,
                  fontSize: 15,
                  height: 1.6,
                  fontFamily: 'Arial',
                ),
              ),
              const SizedBox(height: 25),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: () => _goTo(context, '/materi'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Mulai Belajar'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _goTo(context, '/latihan'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.text,
                      side: BorderSide(
                        color: AppTheme.gold.withOpacity(.35),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 15,
                      ),
                    ),
                    icon: const Icon(Icons.quiz_rounded, size: 18),
                    label: const Text('Coba Latihan'),
                  ),
                ],
              ),
            ],
          );

          final visual = Container(
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ꦧꦱ\nꦗꦮ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.gold,
                      fontSize: 48,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'JAZLEARN',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.2,
                    ),
                  ),
                ],
              ),
            ),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textContent,
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.center,
                  child: visual,
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: textContent),
              const SizedBox(width: 40),
              visual,
            ],
          );
        },
      ),
    );
  }

  Widget _sectionTitle() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mulai Belajar',
          style: TextStyle(
            color: AppTheme.text,
            fontSize: 25,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Pilih fitur yang ingin kamu gunakan.',
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
            title: 'Materi',
            subtitle: 'Teori dan tata bahasa Jawa',
            count: 'Video & rangkuman',
            icon: Icons.library_books_rounded,
            color: AppTheme.green,
            onTap: () => _goTo(context, '/materi'),
          ),
          CourseCard(
            title: 'Tembung',
            subtitle: 'Kosakata Bahasa Jawa',
            count: 'Cari & dengarkan',
            icon: Icons.menu_book_rounded,
            color: AppTheme.brown,
            onTap: () => _goTo(context, '/tembung'),
          ),
          CourseCard(
            title: 'Aksara Jawa',
            subtitle: 'Kenali bentuk Hanacaraka',
            count: '20 aksara dasar',
            icon: Icons.edit_rounded,
            color: const Color(0xFF8A6332),
            onTap: () => _goTo(context, '/aksara'),
          ),
          CourseCard(
            title: 'Latihan',
            subtitle: 'Uji pemahamanmu',
            count: '3 jenis kuis',
            icon: Icons.quiz_rounded,
            color: AppTheme.darkGreen,
            onTap: () => _goTo(context, '/latihan'),
          ),
        ];

        if (constraints.maxWidth < 760) {
          return Column(
            children: cards
                .map(
                  (card) => Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: card,
                  ),
                )
                .toList(),
          );
        }

        final columns = constraints.maxWidth >= 1050 ? 4 : 2;
        final cardWidth =
            (constraints.maxWidth - ((columns - 1) * 15)) / columns;

        return Wrap(
          spacing: 15,
          runSpacing: 15,
          children: cards
              .map(
                (card) => SizedBox(
                  width: cardWidth,
                  child: card,
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _learningGuide(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppTheme.gold.withOpacity(.14),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final steps = _homeGuideSteps;

          final compact = constraints.maxWidth < 850;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cara belajar di JazLearn',
                style: TextStyle(
                  color: AppTheme.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Mulai dari materi, tambah kosakata, lalu uji pemahamanmu.',
                style: TextStyle(
                  color: AppTheme.muted,
                  fontSize: 12,
                  fontFamily: 'Arial',
                ),
              ),
              const SizedBox(height: 20),
              if (compact)
                Column(
                  children: steps
                      .map(
                        (step) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildGuideStep(context, step),
                        ),
                      )
                      .toList(),
                )
              else
                Row(
                  children: steps
                      .map(
                        (step) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: _buildGuideStep(context, step),
                          ),
                        ),
                      )
                      .toList(),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGuideStep(BuildContext context, _GuideItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _goTo(context, item.route),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cream.withOpacity(.45),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.gold.withOpacity(.22),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  item.icon,
                  color: AppTheme.brown,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.number}  ${item.title}',
                      style: const TextStyle(
                        color: AppTheme.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.description,
                      style: const TextStyle(
                        color: AppTheme.muted,
                        fontSize: 11,
                        height: 1.5,
                        fontFamily: 'Arial',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                color: AppTheme.muted,
                size: 17,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideItem {
  final String number;
  final IconData icon;
  final String title;
  final String description;
  final String route;

  const _GuideItem({
    required this.number,
    required this.icon,
    required this.title,
    required this.description,
    required this.route,
  });
}
