import 'package:audioroom/screens/home_screen.dart';
import 'package:audioroom/utils/auth_gate.dart';
import 'package:audioroom/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:audioroom/firebase_options.dart';
// import 'package:audioroom/utils/auth_gate.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AudioRoom Ninja',
      home: const AuthGate(),
      theme: ThemeData.dark().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white, // Ninja white accent
          brightness: Brightness.dark,
        ).copyWith(
          primary: Colors.white, // Ninja white
          secondary: Colors.grey.shade300, // Light grey accent
          tertiary: Colors.grey.shade700, // Dark grey
          surface: Color(0xFF0A0A0A), // Pure black surface
          background: Color(0xFF000000), // Pure black background
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onSurface: Colors.white,
          onBackground: Colors.white,
        ),
        scaffoldBackgroundColor: Color(0xFF000000), // Pure black
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: GoogleFonts.orbitron(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
          iconTheme: IconThemeData(
            color: Colors.white,
            size: 24,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.grey.shade300),
          hintStyle: TextStyle(color: Colors.grey.shade500),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade700, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade600, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white, width: 2),
          ),
          filled: true,
          fillColor: Color(0xFF111111),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 8,
            shadowColor: Colors.white.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.orbitron(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            padding: MaterialStateProperty.all<EdgeInsets>(
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            textStyle: MaterialStateProperty.all(
              GoogleFonts.orbitron(
                fontSize: 16, 
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
            backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            side: MaterialStateProperty.all<BorderSide>(
              BorderSide(color: Colors.white, width: 1.5),
            ),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        textTheme: TextTheme(
          headlineLarge: GoogleFonts.orbitron(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 2.0,
          ),
          headlineMedium: GoogleFonts.orbitron(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
          titleLarge: GoogleFonts.orbitron(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
          titleMedium: GoogleFonts.rajdhani(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.8,
          ),
          bodyLarge: GoogleFonts.rajdhani(
            fontSize: 16,
            color: Colors.grey.shade300,
            letterSpacing: 0.5,
          ),
          bodyMedium: GoogleFonts.rajdhani(
            fontSize: 14,
            color: Colors.grey.shade400,
            letterSpacing: 0.3,
          ),
          labelLarge: GoogleFonts.orbitron(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 1.0,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 12,
          highlightElevation: 16,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        cardTheme: CardTheme(
          color: Color(0xFF111111),
          elevation: 8,
          shadowColor: Colors.white.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade800, width: 1),
          ),
        ),
        dividerTheme: DividerThemeData(
          color: Colors.grey.shade700,
          thickness: 1,
        ),
      )
    );
  }
}

