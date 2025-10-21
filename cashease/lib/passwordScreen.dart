//passwordScreen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'forgotpin.dart';
import 'database_helper.dart';

class PasswordScreen extends StatelessWidget {
  final String phoneNumber;

  const PasswordScreen({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: PasswordComponent(phoneNumber: phoneNumber),
    );
  }
}

class PasswordComponent extends StatefulWidget {
  final String phoneNumber;

  const PasswordComponent({super.key, required this.phoneNumber});

  @override
  State<PasswordComponent> createState() => _PasswordComponentState();
}

class _PasswordComponentState extends State<PasswordComponent> {
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
    return _pinControllers.map((controller) => controller.text).join();
  }

  Future<void> _verifyPin() async {
    if (!_isPinComplete()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan PIN Anda terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final pin = _getPin();
    final isValid = await _dbHelper.verifyPin(widget.phoneNumber, pin);

    setState(() {
      _isLoading = false;
    });

    if (isValid) {
      Navigator.pop(context, true); // Verifikasi berhasil
    } else {
      // Clear PIN fields
      for (final controller in _pinControllers) {
        controller.clear();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN salah. Silakan coba lagi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _pinControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Masukkan PIN Anda',
            style: TextStyle(color: Colors.white, fontSize: 22),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                _pinControllers.map((controller) {
                  return Container(
                    width: 50,
                    height: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: TextField(
                      controller: controller,
                      maxLength: 1,
                      textAlign: TextAlign.center,
                      obscureText: true,
                      readOnly: true,
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        counterText: '',
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => ForgotPinPage(phoneNumber: widget.phoneNumber),
                ),
              );
            },
            child: const Text(
              'Lupa PIN?',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildKeypad(),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              minimumSize: const Size(200, 50),
            ),
            onPressed: _isLoading ? null : _verifyPin,
            child:
                _isLoading
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.deepPurple,
                        strokeWidth: 2,
                      ),
                    )
                    : const Text('Continue'),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 60),
      children:
          buttons.map((text) {
            if (text == '') {
              return const SizedBox.shrink();
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
        shape: const CircleBorder(),
        minimumSize: const Size(60, 60),
      ),
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(fontSize: 24)),
    );
  }
}
