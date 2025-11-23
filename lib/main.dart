import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import './providers/transaction_provider.dart';
import './screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  // Setup Windows/Linux/Mac (Database FFI)
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Mengatur warna status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Definisi Warna
    const primaryColor = Color(0xFF009688); // Teal
    const secondaryColor = Color(0xFFFFA000); // Amber

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => TransactionProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'DompetCare',

        // --- TEMA APLIKASI ---
        theme: ThemeData(
          useMaterial3: true,

          // 1. Skema Warna
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryColor,
            primary: primaryColor,
            secondary: secondaryColor,
            surface: const Color(0xFFF8F9FA),
            brightness: Brightness.light,
          ),

          // 2. Tipografi (Font Modern: Poppins)
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),

          // 3. AppBar Styling
          appBarTheme: AppBarTheme(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),

          // BAGIAN CARD THEME SAYA HAPUS DULU AGAR TIDAK ERROR
          // Nanti kita styling manual saja di widgetnya.

          // 4. Input Decoration (Form Styling)
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryColor, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),

          // 5. Button Styling
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),

          // Floating Action Button
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: secondaryColor,
            foregroundColor: Colors.white,
            elevation: 4,
          ),
        ),

        home: const HomeScreen(),
      ),
    );
  }
}
