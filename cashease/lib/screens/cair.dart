import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Ditambahkan untuk input format
import 'package:intl/intl.dart';
// Menggunakan path relatif yang benar ke services/
import '../services/database_helper.dart';

class CairPage extends StatefulWidget {
  final String bankName;
  // Tambahkan phoneNumber untuk otentikasi dan transaksi
  final String phoneNumber;

  const CairPage({
    super.key,
    required this.bankName,
    required this.phoneNumber,
  });

  @override
  State<CairPage> createState() => _CairPageState();
}

class _CairPageState extends State<CairPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final NumberFormat _currencyFormat = NumberFormat.decimalPattern('id');
  final DatabaseHelper _dbHelper = DatabaseHelper();
  static const int adminFee = 2000;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_formatCurrency);
  }

  void _formatCurrency() {
    // Memformat input dengan pemisah ribuan
    final value = _amountController.text.replaceAll(RegExp(r'[^\d]'), '');
    if (value.isNotEmpty) {
      final formatted = _currencyFormat.format(int.parse(value));
      // Menggunakan replaceFirst untuk menghilangkan format di sisi Dart
      _amountController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  Future<void> _submitWithdrawal() async {
    // Bersihkan input dari format mata uang
    final rawAmountText = _amountController.text.replaceAll(
      RegExp(r'[^\d]'),
      '',
    );
    final pin = _pinController.text.trim();

    if (rawAmountText.isEmpty || pin.isEmpty) {
      _showSnackBar('Harap isi nominal dan PIN terlebih dahulu', Colors.red);
      return;
    }

    final int withdrawalAmount = int.tryParse(rawAmountText) ?? 0;
    final totalDeduction = withdrawalAmount + adminFee;

    if (pin.length != 5) {
      _showSnackBar('PIN harus 5 digit', Colors.red);
      return;
    }

    if (withdrawalAmount <= 0) {
      _showSnackBar('Nominal penarikan harus lebih dari Rp 0', Colors.red);
      return;
    }

    setState(() => _isProcessing = true);

    // 1. Validasi PIN
    final isPinValid = await _dbHelper.validateLogin(widget.phoneNumber, pin);

    if (!isPinValid) {
      setState(() => _isProcessing = false);
      _showSnackBar('PIN yang Anda masukkan salah', Colors.red);
      _pinController.clear();
      return;
    }

    // 2. Cek Saldo
    final currentBalance = await _dbHelper.getUserBalance(widget.phoneNumber);

    if (currentBalance < totalDeduction) {
      // Catat transaksi GAGAL (Dana tidak cukup)
      await _dbHelper.addTransaction(
        userPhone: widget.phoneNumber,
        type: 'withdraw',
        amount: withdrawalAmount,
        description:
            'Penarikan ke ${widget.bankName} (Gagal: Saldo tidak cukup)',
        status: 'failed',
      );

      setState(() => _isProcessing = false);
      _showSnackBar(
        'Penarikan gagal: Saldo tidak mencukupi (Perlu Rp ${_formatNumber(totalDeduction)} termasuk biaya admin)',
        Colors.red,
      );
      return;
    }

    // 3. Proses Penarikan (Kurangi Saldo)
    final subtractionSuccess = await _dbHelper.subtractBalance(
      widget.phoneNumber,
      totalDeduction,
      description: 'Withdrawal to ${widget.bankName}',
    );

    setState(() => _isProcessing = false);

    if (subtractionSuccess) {
      // Catat transaksi SUKSES
      await _dbHelper.addTransaction(
        userPhone: widget.phoneNumber,
        type: 'withdraw',
        amount: withdrawalAmount,
        description: 'Penarikan ke ${widget.bankName} (Biaya admin Rp 2.000)',
        status: 'success',
      );

      // Tampilkan notifikasi sukses
      await _showSuccessDialog(withdrawalAmount);

      // Kembali ke Home/WithdrawPage dan trigger refresh
      Navigator.pop(context, true);
    } else {
      // Ini hanya terjadi jika ada error database setelah cek saldo
      await _dbHelper.addTransaction(
        userPhone: widget.phoneNumber,
        type: 'withdraw',
        amount: withdrawalAmount,
        description:
            'Penarikan ke ${widget.bankName} (Gagal: Kesalahan Sistem)',
        status: 'failed',
      );
      _showSnackBar('Penarikan gagal karena masalah sistem.', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(backgroundColor: color, content: Text(message)));
  }

  Future<void> _showSuccessDialog(int amount) async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Penarikan Berhasil'),
            content: Text(
              'Dana sebesar Rp ${_formatNumber(amount)} berhasil ditarik ke ${widget.bankName}. Biaya admin: Rp ${_formatNumber(adminFee)}.',
              style: const TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  String _formatNumber(int number) {
    final formatter = NumberFormat('#,##0', 'id_ID');
    return formatter.format(number);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          'Form Penarikan',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Metode: ${widget.bankName}',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text(
                'Nominal Penarikan (Min. Rp 10.000)',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                // Menggunakan FilteringTextInputFormatter.digitsOnly untuk menghilangkan format saat input
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Contoh: 100000',
                  hintStyle: TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.deepPurple.shade400,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixText: 'Rp ',
                  prefixStyle: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Biaya Admin: Rp ${_formatNumber(adminFee)}',
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 20),
              const Text(
                'Masukkan PIN',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 5,
                inputFormatters: [LengthLimitingTextInputFormatter(5)],
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '•••••',
                  hintStyle: TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.deepPurple.shade400,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.deepPurple,
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: _isProcessing ? null : _submitWithdrawal,
                  child:
                      _isProcessing
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.deepPurple,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text('Tarik Dana'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.removeListener(_formatCurrency);
    _amountController.dispose();
    _pinController.dispose();
    super.dispose();
  }
}
