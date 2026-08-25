import 'package:flutter/material.dart';
import 'package:video_player_media_kit/video_player_media_kit.dart';
import 'pages/home_page.dart';
import 'pages/materi_page.dart';
import 'pages/tembung_page.dart';
import 'pages/aksara_page.dart';
import 'pages/latihan_page.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  VideoPlayerMediaKit.ensureInitialized(linux: true);

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
        '/materi': (context) => const MateriPage(),
        '/tembung': (context) => const TembungPage(),
        '/aksara': (context) => const AksaraPage(),
        '/latihan': (context) => const LatihanPage(),
      }
    );
  }
}
