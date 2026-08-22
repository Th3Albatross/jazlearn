import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';

class TembungPage extends StatelessWidget {
  const TembungPage({super.key});

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
                const SizedBox(height: 35),
                Wrap(
                  spacing: 18,
                  runSpacing: 18,
                  children: const [
                    VocabularyCard(
                      word: 'Mangan',
                      meaning: 'Makan',
                      example: 'Aku lagi mangan.',
                    ),
                    VocabularyCard(
                      word: 'Ngombe',
                      meaning: 'Minum',
                      example: 'Aku arep ngombe.',
                    ),
                    VocabularyCard(
                      word: 'Turu',
                      meaning: 'Tidur',
                      example: 'Aku arep turu.',
                    ),
                    VocabularyCard(
                      word: 'Mlaku',
                      meaning: 'Berjalan',
                      example: 'Aku mlaku menyang pasar.',
                    ),
                    VocabularyCard(
                      word: 'Maca',
                      meaning: 'Membaca',
                      example: 'Aku seneng maca buku.',
                    ),
                    VocabularyCard(
                      word: 'Nulis',
                      meaning: 'Menulis',
                      example: 'Aku lagi nulis.',
                    ),
                  ],
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
  final String word;
  final String meaning;
  final String example;

  const VocabularyCard({
    super.key,
    required this.word,
    required this.meaning,
    required this.example,
  });

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
                word,
                style: const TextStyle(
                  color: AppTheme.green,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                meaning,
                style: const TextStyle(
                  color: AppTheme.text,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Arial',
                ),
              ),
              const SizedBox(height: 15),
              Text(
                example,
                style: const TextStyle(
                  color: AppTheme.muted,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'Arial',
                ),
              ),
            ],
          ),
          Positioned(
	  right: 0,
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.spatial_audio_off_rounded),
            ),
          ),
        ],
      ),
    );
  }
}
