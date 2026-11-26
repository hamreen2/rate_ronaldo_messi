import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';
import 'send_page.dart';
import 'wall_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseAnonKey);
  runApp(const RateApp());
}

class RateApp extends StatelessWidget {
  const RateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ronaldo or Messi?',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        // Used when Roboto has no glyph: emoji, then Arabic / Kurdish letters.
        fontFamilyFallback: const ['NotoEmoji', 'NotoSansArabic'],
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0E7C6B)),
      ),
      // Two screens. On the web the part after # selects the screen:
      //   .../#/      -> Rate form (phones)
      //   .../#/wall  -> Live results (projector)
      initialRoute: '/',
      routes: {
        '/': (_) => const SendPage(),
        '/wall': (_) => const WallPage(),
      },
    );
  }
}
