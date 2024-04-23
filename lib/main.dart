import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordle/controller.dart';
import 'package:wordle/firebase_options.dart';
import 'package:wordle/pages/Giris_ekrani.dart';
import 'package:wordle/pages/Oyun_ekrani.dart';
import 'package:wordle/providers/authentication_provider.dart';
import 'package:wordle/providers/game_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => Controller()),
      ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
      ChangeNotifierProvider(create: (_) => GameProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wordle',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Giris_ekrani(),
    );
  }
}