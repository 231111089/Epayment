// lib/main.dart

import 'package:flutter/material.dart';
import 'screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// import 'home.dart';
void main() {
  // PENTING: Memastikan Flutter binding terinisialisasi.
  // Ini harus dipanggil sebelum memanggil metode native apa pun (seperti sqfliteFfiInit()).
  WidgetsFlutterBinding.ensureInitialized();

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
