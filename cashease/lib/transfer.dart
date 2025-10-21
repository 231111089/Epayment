//transfer.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart'; // PENTING untuk perbaikan Exception
import 'passwordScreen.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'currency_service.dart';
import 'database_helper.dart'; // Import Database Helper

class Transfer {
  String name;
  String bankName;
  String accountNumber;
  String logoAssetPath;
  String alias;

  Transfer({
    required this.name,
    required this.bankName,
    required this.accountNumber,
    required this.logoAssetPath,
    this.alias = '',
  });
}

class TransferPage extends StatefulWidget {
  final String phoneNumber;

  const TransferPage({super.key, required this.phoneNumber});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper(); // Inisialisasi DB Helper

  // Tambahkan list mata uang yang didukung
  final List<String> _supportedCurrencies = [
    'IDR', // Default untuk transfer biasa
    'JPY',
    'AUD',
    'CNY',
    'USD',
    'EUR',
  ];

  // Map untuk menyimpan simbol mata uang
  final Map<String, String> _currencySymbols = const {
    'IDR': 'Rp ',
    'JPY': '¥ ',
    'AUD': 'A\$ ',
    'CNY': 'CN¥ ',
    'USD': '\$ ',
    'EUR': '€ ',
  };

  // Helper untuk format IDR (untuk display akhir)
  String _formatCurrency(int number) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return 'Rp ${formatter.format(number)}';
  }

  // Helper untuk format mata uang asing (untuk display nilai konversi)
  String _formatForeignCurrency(double number, String currencyCode) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '${_currencySymbols[currencyCode] ?? ''}${formatter.format(number)}';
  }

  final List<Transfer> _beneficiaries = [
    Transfer(
      name: 'John Doe',
      bankName: 'Bank BCA',
      accountNumber: '1234567890',
      logoAssetPath: 'asset/elogo1.png',
      alias: 'Ayah',
    ),
    Transfer(
      name: 'Jane Smith',
      bankName: 'Bank Mandiri',
      accountNumber: '0987654321',
      logoAssetPath: 'asset/elogo2.png',
      alias: 'Ibu',
    ),
    Transfer(
      name: 'Michael Johnson',
      bankName: 'Bank BNI',
      accountNumber: '1122334455',
      logoAssetPath: 'asset/elogo5.png',
      alias: 'Toko Kelontong',
    ),
    Transfer(
      name: 'Emily Davis',
      bankName: 'Dana',
      accountNumber: '08123456789',
      logoAssetPath: 'asset/elogo3.png',
    ),
  ];

  List<Transfer> _filteredBeneficiaries = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredBeneficiaries = _beneficiaries;
    _searchController.addListener(_filterBeneficiaries);
  }

  void _filterBeneficiaries() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBeneficiaries =
          _beneficiaries.where((b) {
            return b.name.toLowerCase().contains(query) ||
                b.accountNumber.contains(query) ||
                b.alias.toLowerCase().contains(query);
          }).toList();
    });
  }

  void _showTransferDialog(Transfer transfer) {
    final TextEditingController amountController = TextEditingController();
    final ValueNotifier<String> formattedAmount = ValueNotifier('');
    final ValueNotifier<String> selectedCurrency = ValueNotifier(
      _supportedCurrencies.first,
    );
    final formKey = GlobalKey<FormState>();
    final rootContext = context;

    // Fungsi untuk mengupdate tampilan jumlah dan memberi format ribuan
    void updateFormattedAmount(String value, String currency) {
      String cleanText = value.replaceAll(RegExp(r'[^\d\.]'), '');
      if (cleanText.isEmpty) {
        formattedAmount.value = '';
        return;
      }

      if (currency != 'IDR') {
        double? amount = double.tryParse(cleanText);
        if (amount != null) {
          formattedAmount.value = _formatForeignCurrency(amount, currency);
        } else {
          formattedAmount.value = '';
        }
      } else {
        int? amount = int.tryParse(cleanText.split('.')[0]);
        if (amount != null) {
          formattedAmount.value = _formatCurrency(amount);
        } else {
          formattedAmount.value = '';
        }
      }
    }

    // Input Formatter
    final List<TextInputFormatter> inputFormatters = [
      FilteringTextInputFormatter.allow(RegExp(r'^\d*[\.\,]?\d*')),
    ];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text('Transfer Uang ke ${transfer.name}'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tampilkan saldo saat ini
                  FutureBuilder<int>(
                    future: _dbHelper.getUserBalance(widget.phoneNumber),
                    builder: (context, snapshot) {
                      final balance = snapshot.data ?? 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Saldo Anda: ${_formatCurrency(balance)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.deepPurple,
                          ),
                        ),
                      );
                    },
                  ),
                  Row(
                    children: [
                      // Dropdown Mata Uang
                      ValueListenableBuilder<String>(
                        valueListenable: selectedCurrency,
                        builder: (context, currentCurrency, child) {
                          return DropdownButton<String>(
                            value: currentCurrency,
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                selectedCurrency.value = newValue;
                                updateFormattedAmount(
                                  amountController.text,
                                  newValue,
                                );
                              }
                            },
                            items:
                                _supportedCurrencies.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      // Input Jumlah
                      Expanded(
                        child: ValueListenableBuilder<String>(
                          valueListenable: selectedCurrency,
                          builder: (context, currentCurrency, child) {
                            return TextFormField(
                              controller: amountController,
                              keyboardType: TextInputType.number,
                              inputFormatters: inputFormatters,
                              decoration: InputDecoration(
                                labelText: 'Jumlah',
                                prefixText:
                                    _currencySymbols[currentCurrency] ?? '',
                              ),
                              onChanged:
                                  (value) => updateFormattedAmount(
                                    value,
                                    currentCurrency,
                                  ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Wajib diisi';
                                }
                                if (double.tryParse(
                                      value.replaceAll(',', '.'),
                                    ) ==
                                    null) {
                                  return 'Jumlah tidak valid';
                                }
                                return null;
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<String>(
                    valueListenable: formattedAmount,
                    builder: (_, value, __) {
                      return Text(
                        value.isNotEmpty ? 'Konversi IDR: $value' : '',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final amountText = amountController.text.replaceAll(
                      ',',
                      '.',
                    );
                    final double foreignAmount = double.parse(amountText);
                    final String currency = selectedCurrency.value;
                    int finalAmountIDR = 0;

                    Navigator.pop(context);

                    // 1. Proses Konversi
                    if (currency != 'IDR') {
                      final rate = await CurrencyService().getExchangeRate(
                        currency,
                        'IDR',
                      );

                      if (rate == null) {
                        if (!mounted) return;
                        _showTransferErrorBanner(
                          rootContext,
                          'Gagal mengambil nilai tukar $currency.',
                        );
                        return;
                      }

                      finalAmountIDR = (foreignAmount * rate).round();
                    } else {
                      finalAmountIDR = foreignAmount.round();
                    }

                    // 2. Cek Saldo (VALIDASI)
                    final currentBalance = await _dbHelper.getUserBalance(
                      widget.phoneNumber,
                    );

                    if (finalAmountIDR > currentBalance) {
                      if (!mounted) return;
                      _showTransferErrorBanner(
                        rootContext,
                        'Saldo tidak cukup (${_formatCurrency(currentBalance)}) untuk transfer ${_formatCurrency(finalAmountIDR)}.',
                      );
                      return;
                    }

                    // 3. Tampilkan Konfirmasi
                    final confirmed = await _showConversionConfirmation(
                      rootContext,
                      transfer,
                      foreignAmount,
                      currency,
                      finalAmountIDR,
                    );

                    if (confirmed == true) {
                      // 4. Verifikasi PIN
                      final verified = await Navigator.push<bool>(
                        rootContext,
                        MaterialPageRoute(
                          builder:
                              (_) => PasswordScreen(
                                phoneNumber: widget.phoneNumber,
                              ),
                        ),
                      );

                      if (verified == true) {
                        if (!mounted) return;

                        // 5. LAKUKAN PENGURANGAN SALDO (EKSEKUSI TRANSAKSI)
                        final success = await _dbHelper.subtractBalance(
                          widget.phoneNumber,
                          finalAmountIDR,
                          description:
                              'Transfer of ${currency} ${foreignAmount} to ${transfer.name}',
                        );

                        if (success) {
                          // Catat transaksi penerima (sebagai pengeluaran)
                          await _dbHelper.addTransaction(
                            userPhone: widget.phoneNumber,
                            type: 'transfer',
                            amount: -finalAmountIDR,
                            description: 'Transfer to ${transfer.name}',
                            recipientName: transfer.name,
                          );

                          // 6. Tampilkan Sukses
                          if (!mounted) return;
                          _showTransferSuccessBanner(
                            rootContext,
                            finalAmountIDR,
                            transfer.name,
                            foreignAmount,
                            currency,
                          );
                        } else {
                          // Fallback jika database gagal mengurangi saldo (seharusnya tidak terjadi karena sudah dicek di atas)
                          if (!mounted) return;
                          _showTransferErrorBanner(
                            rootContext,
                            'Transfer gagal karena masalah database.',
                          );
                        }
                      }
                    }
                  }
                },
                child: const Text('Transfer'),
              ),
            ],
          ),
    );
  }

  // Dialog konfirmasi baru untuk menampilkan konversi
  Future<bool?> _showConversionConfirmation(
    BuildContext context,
    Transfer transfer,
    double foreignAmount,
    String currency,
    int finalAmountIDR,
  ) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Konfirmasi Transfer'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Penerima: ${transfer.name}'),
                Text('Rekening: ${transfer.accountNumber}'),
                const Divider(),
                Text(
                  currency == 'IDR'
                      ? 'Jumlah Transfer: ${_formatCurrency(finalAmountIDR)}'
                      : 'Jumlah Dikonversi:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (currency != 'IDR')
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dari: ${_formatForeignCurrency(foreignAmount, currency)}',
                        ),
                        Text(
                          'Ke: ${_formatCurrency(finalAmountIDR)}',
                          style: const TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Catatan: Nilai tukar adalah simulasi (ditarik dari API).',
                          style: TextStyle(fontSize: 12, color: Colors.red),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    _formatCurrency(finalAmountIDR),
                  ), // Jika IDR, tampilkan IDR saja
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Konfirmasi'),
              ),
            ],
          ),
    );
  }

  // PERBAIKAN UTAMA: Menggunakan SchedulerBinding untuk mengatasi FlutterError
  void _showTransferSuccessBanner(
    BuildContext context,
    int amountIDR,
    String name,
    double foreignAmount,
    String currency,
  ) {
    // Tidak perlu clearMaterialBanners di sini

    final String message;
    if (currency != 'IDR') {
      final formattedForeignAmount = NumberFormat(
        '#,##0.00',
        'en_US',
      ).format(foreignAmount);

      message =
          'Transfer ${currency} ${formattedForeignAmount} (≈ ${_formatCurrency(amountIDR)}) ke $name berhasil.';
    } else {
      message = 'Transfer ${_formatCurrency(amountIDR)} ke $name berhasil.';
    }

    final banner = MaterialBanner(
      backgroundColor: Colors.green.shade600,
      content: Text(message, style: const TextStyle(color: Colors.white)),
      leading: const Icon(Icons.check_circle, color: Colors.white),
      actions: [
        TextButton(
          onPressed: () {
            // 1. TUTUP BANNER
            ScaffoldMessenger.of(context).hideCurrentMaterialBanner();

            // 2. PERBAIKAN: Tunda Navigator.pop ke frame berikutnya
            // Ini mencegah "Looking up a deactivated widget's ancestor is unsafe"
            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.pop(
                  context,
                  true,
                ); // Kembali ke Home untuk refresh saldo
              }
            });
          },
          child: const Text('TUTUP', style: TextStyle(color: Colors.white)),
        ),
      ],
    );

    ScaffoldMessenger.of(context).showMaterialBanner(banner);
  }

  void _showTransferErrorBanner(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearMaterialBanners();
    final banner = MaterialBanner(
      backgroundColor: Colors.red.shade600,
      content: Text(
        'Gagal Transfer: $message',
        style: const TextStyle(color: Colors.white),
      ),
      leading: const Icon(Icons.error, color: Colors.white),
      actions: [
        TextButton(
          onPressed:
              () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
          child: const Text('TUTUP', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
    ScaffoldMessenger.of(context).showMaterialBanner(banner);

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
      }
    });
  }

  void _deleteTransfer(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hapus Penerima'),
            content: Text(
              'Anda yakin ingin menghapus ${_beneficiaries[index].name}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _beneficiaries.removeAt(index);
                    _filterBeneficiaries();
                  });
                  Navigator.pop(context);
                },
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _navigateToAddTransfer() async {
    final newTransfer = await Navigator.push<Transfer>(
      context,
      MaterialPageRoute(builder: (_) => const AddTransferPage()),
    );

    if (newTransfer != null) {
      setState(() {
        _beneficiaries.add(newTransfer);
        _filterBeneficiaries();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transfer',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child:
                _filteredBeneficiaries.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _filteredBeneficiaries.length,
                      itemBuilder: (context, index) {
                        final transfer = _filteredBeneficiaries[index];
                        return _buildTransferCard(transfer, index);
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTransfer,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.deepPurple,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari nama, alias, atau rekening...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildTransferCard(Transfer transfer, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.grey[200],
          backgroundImage: AssetImage(transfer.logoAssetPath),
        ),
        title: Text(
          transfer.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "${transfer.alias.isNotEmpty ? '${transfer.alias} • ' : ''}${transfer.bankName} - ${transfer.accountNumber}",
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                Icons.money,
                color: Color.fromARGB(255, 9, 215, 9),
                size: 20,
              ),
              onPressed: () => _showTransferDialog(transfer),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () => _deleteTransfer(index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'Belum Ada Penerima',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tekan tombol + untuk menambah penerima baru.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class AddTransferPage extends StatefulWidget {
  const AddTransferPage({super.key});

  @override
  State<AddTransferPage> createState() => _AddTransferPageState();
}

class _AddTransferPageState extends State<AddTransferPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _aliasController = TextEditingController();

  String? _selectedBank;
  final List<Map<String, String>> _banks = [
    {'name': 'Bank BCA', 'logo': 'asset/elogo1.png'},
    {'name': 'Bank Mandiri', 'logo': 'asset/elogo2.png'},
    {'name': 'Bank BNI', 'logo': 'asset/elogo5.png'},
    {'name': 'Permata Bank', 'logo': 'asset/elogo4.png'},
    {'name': 'Dana', 'logo': 'asset/elogo3.png'},
  ];

  String _getLogoPath(String bankName) {
    switch (bankName) {
      case 'Bank BCA':
        return 'asset/elogo1.png';
      case 'Bank Mandiri':
        return 'asset/elogo2.png';
      case 'Bank BNI':
        return 'asset/elogo5.png';
      case 'Dana':
        return 'asset/elogo3.png';
      default:
        return 'asset/elogo1.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Tambah Penerima',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _accountNumberController,
                decoration: const InputDecoration(labelText: 'Nomor Rekening'),
                keyboardType: TextInputType.number,
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama'),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Pilih Bank'),
                value: _selectedBank,
                items:
                    _banks.map((bank) {
                      return DropdownMenuItem(
                        value: bank['name'],
                        child: Row(
                          children: [
                            Image.asset(bank['logo']!, width: 24),
                            const SizedBox(width: 10),
                            Text(bank['name']!),
                          ],
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBank = value;
                  });
                },
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Pilih bank' : null,
              ),
              TextFormField(
                controller: _aliasController,
                decoration: const InputDecoration(
                  labelText: 'Alias (opsional)',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newTransfer = Transfer(
                      name: _nameController.text,
                      alias: _aliasController.text,
                      bankName: _selectedBank!,
                      accountNumber: _accountNumberController.text,
                      logoAssetPath: _getLogoPath(_selectedBank!),
                    );
                    Navigator.pop(context, newTransfer);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
                child: const Text(
                  'Simpan',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
