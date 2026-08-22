import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';

class AksaraPage extends StatelessWidget {
  const AksaraPage({super.key});

  @override
  Widget build(BuildContext context) {
    final aksara = [
      ['ꦲ', 'Ha'],
      ['ꦤ', 'Na'],
      ['ꦕ', 'Ca'],
      ['ꦫ', 'Ra'],
      ['ꦏ', 'Ka'],
      ['ꦢ', 'Da'],
      ['ꦠ', 'Ta'],
      ['ꦱ', 'Sa'],
      ['ꦮ', 'Wa'],
      ['ꦭ', 'La'],
      ['ꦥ', 'Pa'],
      ['ꦝ', 'Dha'],
      ['ꦗ', 'Ja'],
      ['ꦪ', 'Ya'],
      ['ꦚ', 'Nya'],
      ['ꦩ', 'Ma'],
      ['ꦒ', 'Ga'],
      ['ꦧ', 'Ba'],
      ['ꦛ', 'Tha'],
      ['ꦔ', 'Nga'],
    ];

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
                const Text(
                  'Aksara Jawa',
                  style: TextStyle(
                    color: AppTheme.text,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Kenali bentuk dasar Hanacaraka.',
                  style: TextStyle(
                    color: AppTheme.muted,
                    fontFamily: 'Arial',
                  ),
                ),
                const SizedBox(height: 35),
                GridView.builder(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 180,
                    mainAxisExtent: 160,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: aksara.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: AppTheme.paper,
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Text(
                            aksara[index][0],
                            style: const TextStyle(
                              fontSize: 48,
                              color: AppTheme.brown,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            aksara[index][1],
                            style: const TextStyle(
                              color: AppTheme.text,
                              fontWeight:
                                  FontWeight.w700,
                              fontFamily: 'Arial',
                            ),
                          ),
                        ],
                      ),
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

