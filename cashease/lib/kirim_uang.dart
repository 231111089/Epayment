import 'package:flutter/material.dart';
import 'database_helper.dart';

class KirimUangPage extends StatefulWidget {
  final String? phoneNumber;
  const KirimUangPage({super.key, this.phoneNumber});
  @override
  State<KirimUangPage> createState() => _KirimUangPageState();
}

class _KirimUangPageState extends State<KirimUangPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isLoading = false;

  // Asumsi _searchController dideklarasikan di sini dan perlu dibuang.
  // Anda tidak menyertakan deklarasi properti di State class, tetapi saya asumsikan:
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> contacts = [
    {'name': 'Mike Tyson', 'img': 'asset/elogo1.png', 'phone': '081234567891'},
    {
      'name': 'Billie Eilish',
      'img': 'asset/elogo1.png',
      'phone': '081234567892',
    },
    {
      'name': 'Jackson Wang',
      'img': 'asset/elogo2.png',
      'phone': '081234567893',
    },
    {
      'name': 'Taylor Swift',
      'img': 'asset/elogo4.png',
      'phone': '081234567894',
    },
    {
      'name': 'Olivia Rodrigo',
      'img': 'asset/elogo1.png',
      'phone': '081234567895',
    },
    {'name': 'Keshi', 'img': 'asset/elogo4.png', 'phone': '081234567896'},
    {
      'name': 'Shawn Mendes',
      'img': 'asset/elogo3.png',
      'phone': '081234567897',
    },
    {
      'name': 'Niki Zefanya',
      'img': 'asset/elogo1.png',
      'phone': '081234567898',
    },
  ];
  final List<Map<String, String>> actions = [
    {'label': 'send to grup', 'img': 'asset/ilogo1.png', 'action': 'group'},
    {'label': 'send to friend', 'img': 'asset/ilogo2.png', 'action': 'friend'},
    {'label': 'send to bank', 'img': 'asset/ilogo3.png', 'action': 'bank'},
    {
      'label': 'send to e-wallet',
      'img': 'asset/ilogo4.png',
      'action': 'ewallet',
    },
    {
      'label': 'send cash code',
      'img': 'asset/ilogo5.png',
      'action': 'cashcode',
    },
    {'label': 'cash pull', 'img': 'asset/ilogo6.png', 'action': 'cashpull'},
    {'label': 'send to email', 'img': 'asset/ilogo7.png', 'action': 'email'},
    {'label': 'scan code QR', 'img': 'asset/ilogo8.png', 'action': 'qr'},
    {'label': 'send to chat', 'img': 'asset/ilogo5.png', 'action': 'chat'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // PERBAIKAN: Mengganti nama menjadi showMessage (publik)
  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleActionTap(String action) {
    showMessage('Fitur $action akan segera hadir');
  }

  Future<void> _sendMoney({
    required String recipientName,
    required String recipientPhone,
    // Parameter recipientBank dihapus untuk mengatasi warning
  }) async {
    if (widget.phoneNumber == null || widget.phoneNumber!.isEmpty) {
      showMessage('Silakan login terlebih dahulu untuk melakukan transfer');
      return;
    }
    final currentBalance = await _dbHelper.getUserBalance(widget.phoneNumber!);
    final amount = await _showAmountDialog(recipientName, currentBalance);
    if (amount == null || amount <= 0) return;
    if (amount > currentBalance) {
      showMessage('Saldo tidak mencukup!');
      return;
    }
    final confirmed = await _showConfirmationDialog(
      recipientName: recipientName,
      recipientPhone: recipientPhone,
      amount: amount,
      currentBalance: currentBalance,
    );
    if (confirmed != true) return;
    setState(() => _isLoading = true);
    try {
      final success = await _dbHelper.subtractBalance(
        widget.phoneNumber!,
        amount,
        description: 'Transfer to $recipientName',
      );
      if (success) {
        await _dbHelper.addTransaction(
          userPhone: widget.phoneNumber!,
          type: 'transfer',
          amount: amount,
          description: 'Transfer to $recipientName',
          recipientPhone: recipientPhone,
          recipientName: recipientName,
        );
        setState(() => _isLoading = false);
        final shouldReturn = await _showSuccessDialog(recipientName, amount);
        if (mounted && shouldReturn == true) {
          Navigator.pop(context, true);
        }
      } else {
        setState(() => _isLoading = false);
        showMessage('Transfer gagal. Saldo tidak mencukup.');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      showMessage('Terjadi kesalahan: $e');
    }
  }

  Future<int?> _showAmountDialog(
    String recipientName,
    int currentBalance,
  ) async {
    final TextEditingController amountController = TextEditingController();

    // Formatter agar saat user mengetik langsung muncul titik ribuan
    void formatInput(String value) {
      // Logic ini sebenarnya memanggil dirinya sendiri dari onChanged,
      // tetapi untuk memastikan kode Anda dapat berjalan, saya akan biarkan seperti ini
      // dengan asumsi Anda akan menyetel listener format yang benar nanti.
      if (value.isEmpty) return;
      String digitsOnly = value.replaceAll('.', '');
      if (digitsOnly.isEmpty) return;
      final number = int.tryParse(digitsOnly);
      if (number != null) {
        final formatted = number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
        amountController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    }

    return showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Kirim Uang ke $recipientName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Saldo Anda: Rp ${_formatNumber(currentBalance)}'),
              const SizedBox(height: 20),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
                onChanged: formatInput, // aktifkan auto-format
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              child: const Text(
                'Lanjut',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                final rawText = amountController.text.replaceAll('.', '');
                final amount = int.tryParse(rawText);
                Navigator.pop(context, amount);
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showConfirmationDialog({
    required String recipientName,
    required String recipientPhone,
    required int amount,
    required int currentBalance,
  }) {
    final newBalance = currentBalance - amount;
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Konfirmasi Transfer'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRow('Penerima', recipientName),
                _buildRow('No. HP', recipientPhone),
                const Divider(),
                _buildRow('Jumlah', 'Rp ${_formatNumber(amount)}'),
                _buildRow(
                  'Saldo Saat Ini',
                  'Rp ${_formatNumber(currentBalance)}',
                ),
                _buildRow(
                  'Saldo Setelah Transfer',
                  'Rp ${_formatNumber(newBalance)}',
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
                child: const Text(
                  'Konfirmasi',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );
  }

  Future<bool?> _showSuccessDialog(String recipientName, int amount) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && Navigator.canPop(context)) {
            Navigator.pop(context, true);
          }
        });
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 16),
              const Text(
                'Transfer Berhasil!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Rp ${_formatNumber(amount)} telah dikirim ke $recipientName',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow(String label, String value, {TextStyle? style}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: style ?? const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 10),
            const Text(
              "Kirim Uang",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: "cari no hp/rekening bank",
                        border: InputBorder.none,
                        icon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSection("contacts", contacts, isContact: true),
                  const SizedBox(height: 20),
                  _buildSection("actions", actions),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<Map<String, String>> items, {
    bool isContact = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        children:
            items.map((item) {
              return GestureDetector(
                onTap: () {
                  if (isContact) {
                    _sendMoney(
                      recipientName: item['name']!,
                      recipientPhone: item['phone']!,
                    );
                  } else {
                    _handleActionTap(item['action']!);
                  }
                },
                child: SizedBox(
                  width: 80,
                  child: Column(
                    children: [
                      ClipOval(
                        child: Image.asset(item['img']!, width: 50, height: 50),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item[isContact ? 'name' : 'label']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
