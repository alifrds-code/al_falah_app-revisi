import 'package:al_falah_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:al_falah_app/view/auth/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Ta'lim Al Falah",
      theme: ThemeData(
        // ganti font family di sini (misal pake Google Fonts)
        // fontFamily: 'Plus Jakarta Sans',
      ),
      home: const SplashScreen(),
    );
  }
}
