// cashease/lib/main.dart

import 'package:flutter/material.dart';
import 'screens/screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Import yang dibutuhkan untuk Firebase Core
import 'package:firebase_core/firebase_core.dart';
// Import file konfigurasi yang baru dibuat oleh flutterfire configure
import 'firebase_options.dart';

// import 'home.dart';
void main() async {
  // PENTING: Memastikan Flutter binding terinisialisasi.
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase Core
  try {
    // Menggunakan konfigurasi yang dihasilkan oleh flutterfire configure
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // print("Gagal inisialisasi Firebase: $e");
  }

  // Inisialisasi databaseFactory untuk desktop/Windows
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

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
