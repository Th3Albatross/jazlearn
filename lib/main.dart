import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/tembung_page.dart';
import 'pages/aksara_page.dart';
import 'pages/latihan_page.dart';
import 'pages/pencapaian_page.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const JazLearnApp());
}

class JazLearnApp extends StatelessWidget {
  const JazLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JazLearn',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/tembung': (context) => const TembungPage(),
        '/aksara': (context) => const AksaraPage(),
        '/latihan': (context) => const LatihanPage(),
        '/pencapaian': (context) => const PencapaianPage(),
      },
    );
  }
}

