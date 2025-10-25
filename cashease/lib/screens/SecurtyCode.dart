<<<<<<< HEAD
// lib/SecurtyCode.dart

import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart'; // <-- New import

// Import file lokal
import 'home.dart';
import '../services/database_helper.dart';
=======
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../services/database_helper.dart';
import 'home.dart';
import 'dart:math';
>>>>>>> 539719d8a23c2642640c9ed5b5cd4648d69ed0c1

class SecurtyCode extends StatefulWidget {
  final String phoneNumber;

  const SecurtyCode({super.key, required this.phoneNumber});

  @override
  State<SecurtyCode> createState() => _SecurtyCodeState();
}

class _SecurtyCodeState extends State<SecurtyCode> {
  final _formKey = GlobalKey<FormState>();
  String _enteredCode = '';
  String? _generatedCode; // Kode random dari popup

  @override
  void initState() {
    super.initState();
    _showGeneratedCode(); // langsung tampilkan popup saat masuk halaman
  }

<<<<<<< HEAD
  // Fungsi untuk menyimpan sesi login
  Future<void> _saveLoginSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('loggedInPhone', widget.phoneNumber);
    print('Session saved for: ${widget.phoneNumber}');
  }

=======
>>>>>>> 539719d8a23c2642640c9ed5b5cd4648d69ed0c1
  Future<void> _showGeneratedCode() async {
    // Generate random 6 digit code
    String code = List.generate(6, (_) => Random().nextInt(10)).join();
    setState(() {
      _generatedCode = code;
    });

<<<<<<< HEAD
    await Future.delayed(
      Duration(milliseconds: 400),
    ); // jeda sedikit agar dialog tampil rapi
=======
    await Future.delayed(Duration(milliseconds: 400)); // jeda sedikit agar dialog tampil rapi
>>>>>>> 539719d8a23c2642640c9ed5b5cd4648d69ed0c1

    await showDialog(
      context: context,
      barrierDismissible: false,
<<<<<<< HEAD
      builder:
          (context) => AlertDialog(
            title: const Text('Security Code Anda'),
            content: Text(
              'Kode Anda: $code',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
=======
      builder: (context) => AlertDialog(
        title: const Text('Security Code Anda'),
        content: Text(
          'Kode Anda: $code',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
>>>>>>> 539719d8a23c2642640c9ed5b5cd4648d69ed0c1
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
        ),
        title: const Text(
          "Security Code",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Masukkan Security Code yang tampil di popup",
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Masukkan 6 digit angka yang ditampilkan sebelumnya",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  obscureText: false,
                  animationType: AnimationType.fade,
                  autoFocus: true,
                  keyboardType: TextInputType.number,
                  textStyle: const TextStyle(fontSize: 20),
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.underline,
                    fieldHeight: 50,
                    fieldWidth: 40,
                    inactiveColor: Colors.black,
                    activeColor: Colors.deepPurple,
                    selectedColor: Colors.deepPurple,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _enteredCode = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Masukkan kode terlebih dahulu';
                    }
                    if (value.length < 6) {
                      return 'Kode harus 6 digit';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        if (_enteredCode == _generatedCode) {
<<<<<<< HEAD
                          // Simpan ke database (jika ini registrasi)
                          // Note: logikanya seharusnya register sudah dilakukan di password.dart,
                          // tetapi jika ini adalah langkah terakhir, kita tetap lanjut.
                          // Asumsi: PIN sudah disimpan di database di langkah sebelumnya (password.dart).

                          await _saveLoginSession(); // <-- SIMPAN SESI DI SINI
=======
                          // Simpan ke database
                          await createAccount(_enteredCode);
>>>>>>> 539719d8a23c2642640c9ed5b5cd4648d69ed0c1

                          // Lanjut ke Home
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
<<<<<<< HEAD
                              builder:
                                  (context) =>
                                      Home(phoneNumber: widget.phoneNumber),
=======
                              builder: (context) =>
                                  Home(phoneNumber: widget.phoneNumber),
>>>>>>> 539719d8a23c2642640c9ed5b5cd4648d69ed0c1
                            ),
                          );
                        } else {
                          // Jika salah, tampilkan error
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Kode yang Anda masukkan salah'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: const Text(
                      "Submit",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: _showGeneratedCode,
                  child: const Text(
                    "Tampilkan Ulang Kode",
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> createAccount(String pin) async {
    try {
      bool result = await DatabaseHelper().registerUser(
        widget.phoneNumber,
        pin,
      );
      return result;
    } catch (e) {
      return false;
    }
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> 539719d8a23c2642640c9ed5b5cd4648d69ed0c1
