// lib/main.dart - Perlu di-update
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Pastikan file ini ada
import 'screens/screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io' show Platform;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  if (kIsWeb) {
    // Web: Firebase berjalan normal
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    // Desktop/Mobile
    try {
      // Pengecualian untuk Desktop (jika Anda tidak ingin Firebase berjalan di sana)
      if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } else {
        // Logika untuk environment desktop/non-supported Firebase
        print('Firebase initialization intentionally skipped on Desktop.');
      }
    } catch (e) {
      // Jika gagal di Mobile/Non-Web, ini adalah error yang perlu diperhatikan.
      print('Firebase initialization failed: $e');
    }

    // Inisialisasi sqflite_ffi HANYA untuk platform Desktop
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Splash Screen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Screen(),
    );
  }
}
