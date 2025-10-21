// password.dart

import 'package:flutter/material.dart';
import 'SecurtyCode.dart';
import 'forgotpin.dart';
import 'database_helper.dart';

class Password extends StatelessWidget {
  final String phoneNumber;
  final bool isNewUser;

  const Password({Key? key, required this.phoneNumber, required this.isNewUser})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PasswordComponen(phoneNumber: phoneNumber, isNewUser: isNewUser);
  }
}

class PasswordComponen extends StatefulWidget {
  final String phoneNumber;
  final bool isNewUser;

  const PasswordComponen({
    Key? key,
    required this.phoneNumber,
    required this.isNewUser,
  }) : super(key: key);

  @override
  State<PasswordComponen> createState() => _PasswordComponenState();
}

class _PasswordComponenState extends State<PasswordComponen> {
  final List<TextEditingController> _pinControllers = List.generate(
    5,
    (_) => TextEditingController(),
  );
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isLoading = false;

  void _handleKeypadInput(String value) {
    for (final controller in _pinControllers) {
      if (controller.text.isEmpty) {
        setState(() {
          controller.text = value;
        });
        break;
      }
    }
  }

  void _handleDelete() {
    for (int i = _pinControllers.length - 1; i >= 0; i--) {
      if (_pinControllers[i].text.isNotEmpty) {
        setState(() {
          _pinControllers[i].clear();
        });
        break;
      }
    }
  }

  bool _isPinComplete() {
    return _pinControllers.every((controller) => controller.text.isNotEmpty);
  }

  String _getPin() {
    return _pinControllers.map((c) => c.text).join();
  }

  Future<void> _handleContinue() async {
    if (!_isPinComplete()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Masukkan PIN lengkap terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final pin = _getPin();

    if (widget.isNewUser) {
      // Registrasi user baru
      final success = await _dbHelper.registerUser(widget.phoneNumber, pin);

      setState(() {
        _isLoading = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Akun berhasil dibuat!'),
            backgroundColor: Colors.green,
          ),
        );
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SecurtyCode(phoneNumber: widget.phoneNumber),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat akun. Silakan coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Login user yang sudah terdaftar
      final isValid = await _dbHelper.validateLogin(widget.phoneNumber, pin);

      setState(() {
        _isLoading = false;
      });

      if (isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login berhasil!'),
            backgroundColor: Colors.green,
          ),
        );
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SecurtyCode(phoneNumber: widget.phoneNumber),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PIN salah! Silakan coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
        // Clear PIN fields
        for (var controller in _pinControllers) {
          controller.clear();
        }
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _pinControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.isNewUser ? 'Buat PIN Anda' : 'Masukkan PIN Anda',
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
            SizedBox(height: 10),
            Text(
              widget.phoneNumber,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  _pinControllers
                      .map(
                        (controller) => Container(
                          width: 50,
                          height: 50,
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          child: TextField(
                            controller: controller,
                            maxLength: 1,
                            readOnly: true,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, color: Colors.white),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              counterText: '',
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
            SizedBox(height: 20),
            if (!widget.isNewUser)
              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              ForgotPinPage(phoneNumber: widget.phoneNumber),
                    ),
                  );
                },
                child: Text('Lupa PIN?', style: TextStyle(color: Colors.white)),
              ),
            SizedBox(height: 20),
            _buildKeypad(),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                minimumSize: Size(200, 50),
              ),
              onPressed: _isLoading ? null : _handleContinue,
              child:
                  _isLoading
                      ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.deepPurple,
                          strokeWidth: 2,
                        ),
                      )
                      : Text(widget.isNewUser ? 'Daftar' : 'Masuk'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    final buttons = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫'];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      padding: EdgeInsets.symmetric(horizontal: 60),
      children:
          buttons.map((text) {
            if (text == '') {
              return SizedBox.shrink();
            } else if (text == '⌫') {
              return _keypadButton(text, _handleDelete);
            } else {
              return _keypadButton(text, () => _handleKeypadInput(text));
            }
          }).toList(),
    );
  }

  Widget _keypadButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: CircleBorder(),
        padding: EdgeInsets.all(0),
        minimumSize: Size(60, 60),
      ),
      onPressed: onPressed,
      child: Text(text, style: TextStyle(fontSize: 24)),
    );
  }
}
