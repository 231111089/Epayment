<<<<<<< HEAD
// lib/screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart'; // <-- New import

// Import file lokal
import 'login.dart'; // Asumsi login.dart ada di lib/
import 'home.dart'; // Asumsi home.dart ada di lib/
=======
import 'package:flutter/material.dart';
import 'dart:async';
import 'login.dart';
>>>>>>> 539719d8a23c2642640c9ed5b5cd4648d69ed0c1

class Screen extends StatefulWidget {
  const Screen({super.key});

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
<<<<<<< HEAD
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final String? phoneNumber = prefs.getString('loggedInPhone');

    // Tentukan halaman tujuan
    Widget destinationPage;
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      // Jika nomor telepon ditemukan, langsung ke Home
      print('User logged in: $phoneNumber');
      destinationPage = Home(phoneNumber: phoneNumber);
    } else {
      // Jika tidak ada sesi, arahkan ke Login
      print('No active session found.');
      destinationPage = Login();
    }

    // Tunggu 3 detik dan navigasi
    Timer(const Duration(seconds: 3), () {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => destinationPage));
    });
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
=======
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () async {
      await Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => Login()));
    });
>>>>>>> 539719d8a23c2642640c9ed5b5cd4648d69ed0c1
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Center(child: Image.asset('asset/logo.png')),
    );
  }
}
