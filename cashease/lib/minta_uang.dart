// lib/minta_uang.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BagiUangPage extends StatefulWidget {
  const BagiUangPage({Key? key}) : super(key: key);

  @override
  State<BagiUangPage> createState() => _BagiUangPageState();
}

class _BagiUangPageState extends State<BagiUangPage> {
  final List<Map<String, String>> contacts = [
    {'name': 'Mike Tyson', 'img': 'asset/elogo1.png'},
    {'name': 'Billie Eilish', 'img': 'asset/elogo1.png'},
    {'name': 'Jackson Wang', 'img': 'asset/elogo2.png'},
    {'name': 'Taylor Swift', 'img': 'asset/elogo4.png'},
    {'name': 'Olivia Rodrigo', 'img': 'asset/elogo1.png'},
    {'name': 'Keshi', 'img': 'asset/elogo4.png'},
    {'name': 'Shawn Mendes', 'img': 'asset/elogo3.png'},
    {'name': 'Niki Zefanya', 'img': 'asset/elogo1.png'},
  ];

  // Simple in-memory store for active requests
  final List<Map<String, dynamic>> _activeRequests = [];

  final TextEditingController _searchController = TextEditingController();

  List<Map<String, String>> get _filteredContacts {
    final q = _searchController.text.toLowerCase();
    if (q.isEmpty) return contacts;
    return contacts.where((c) => c['name']!.toLowerCase().contains(q)).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showRequestDialog(String contactName) {
    final _amountController = TextEditingController();
    final _noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Minta uang ke $contactName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nominal (Rp)',
                  hintText: 'contoh: 50000',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Catatan (opsional)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final amountText = _amountController.text.trim();
                if (amountText.isEmpty || int.tryParse(amountText) == null) {
                  // simple validation
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Masukkan nominal yang valid'),
                    ),
                  );
                  return;
                }

                setState(() {
                  _activeRequests.add({
                    'name': contactName,
                    'amount': int.parse(amountText),
                    'note': _noteController.text.trim(),
                    'status': 'Pending',
                    'createdAt': DateTime.now(),
                  });
                });

                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Permintaan terkirim (simulasi).'),
                  ),
                );
              },
              child: const Text('Minta'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        decoration: const InputDecoration(
          hintText: "cari no hp / rekening bank / nama",
          border: InputBorder.none,
          icon: Icon(Icons.search),
        ),
      ),
    );
  }

  Widget _buildContactsSection() {
    final list = _filteredContacts;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Kontak",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children:
                list.map((item) {
                  return GestureDetector(
                    onTap: () => _showRequestDialog(item['name']!),
                    child: SizedBox(
                      width: 80,
                      child: Column(
                        children: [
                          ClipOval(
                            child: Image.asset(
                              item['img']!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item['name']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _metodelainnya() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Metode Lainnya",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(FontAwesomeIcons.link),
                  label: const Text("Link"),
                  onPressed: () {
                    // TODO: generate shareable link
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fitur Link (simulasi)')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(FontAwesomeIcons.qrcode),
                  label: const Text("Kode QR"),
                  onPressed: () {
                    // TODO: show QR code generator
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fitur QR (simulasi)')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _permintaanAktif() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Permintaan Aktif",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              OutlinedButton(
                onPressed: () {
                  // TODO: navigate to history page if exists
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Buka riwayat (simulasi)')),
                  );
                },
                child: const Text(
                  "RIWAYAT",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  foregroundColor: Color(0xFF3A7BD5),
                  side: const BorderSide(color: Color(0xFF3A7BD5)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_activeRequests.isEmpty)
            Column(
              children: const [
                Text(
                  "Masih Kosong nih..",
                  style: TextStyle(fontSize: 12, color: Color(0xFFB7B7B7)),
                ),
                SizedBox(height: 4),
                Text(
                  "Coba buat baru daftar permintaanmu",
                  style: TextStyle(fontSize: 12, color: Color(0xFFB7B7B7)),
                ),
              ],
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _activeRequests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final r = _activeRequests[index];
                return Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: CircleAvatar(child: Text(r['name'][0] ?? '?')),
                    title: Text(r['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rp ${_formatNumber(r['amount'] as int)}'),
                        if ((r['note'] as String).isNotEmpty)
                          Text(r['note'] as String),
                        Text(r['status'], style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: Colors.redAccent),
                      onPressed: () {
                        setState(() {
                          _activeRequests.removeAt(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Permintaan dibatalkan (simulasi)'),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  String _formatNumber(int value) {
    // simple thousand separator
    final s = value.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      buffer.write(s[i]);
      count++;
      if (count == 3 && i != 0) {
        buffer.write('.');
        count = 0;
      }
    }
    return buffer.toString().split('').reversed.join();
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
            const SizedBox(width: 8),
            const Text(
              "Minta Uang",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildSearchField(),
              const SizedBox(height: 20),
              _buildContactsSection(),
              const SizedBox(height: 20),
              _metodelainnya(),
              const SizedBox(height: 20),
              _permintaanAktif(),
            ],
          ),
        ),
      ),
    );
  }
}
