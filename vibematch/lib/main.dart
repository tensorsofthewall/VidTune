import 'package:flutter/material.dart';
import 'package:vibematch/firebase_options.dart';
import 'screens/authentication.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  WidgetsBinding widgetsbinding = WidgetsFlutterBinding.ensureInitialized();
  await initializeApp(widgetsbinding);
  runApp(const MainApp());
}

// Splash screen initialization, run additional initialization methods inside before removing splash screen
Future<void> initializeApp(WidgetsBinding widgetsbinding) async {
  // Initialize splash screen 
  FlutterNativeSplash.preserve(widgetsBinding: widgetsbinding);
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Other initialization stuff
  await Future.delayed(const Duration(seconds: 2));

  // Remove splash screen
  FlutterNativeSplash.remove();
}

// Main App
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VibeMatch',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark
        ),
        textTheme: TextTheme(
          displayLarge: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
          ),
          // ···
          titleLarge: GoogleFonts.oswald(
            fontSize: 30,
            fontStyle: FontStyle.italic,
          ),
          bodyMedium: GoogleFonts.merriweather(),
          displaySmall: GoogleFonts.pacifico(),
        ),
      ),
      // home: const OverviewPage(),
      home: const AuthenticationPage(),
    );
  }
}