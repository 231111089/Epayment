<<<<<<< HEAD
// lib/screens/withdraw.dart

import 'package:flutter/material.dart';
// FIX PATH: Menggunakan path relatif (asumsi cair.dart ada di lib/screens/ juga)
=======
import 'package:flutter/material.dart';
>>>>>>> 539719d8a23c2642640c9ed5b5cd4648d69ed0c1
import 'cair.dart';

class WithdrawOption {
  final String name;
  final String adminFee;
  final String logoAssetPath;

  const WithdrawOption({
    required this.name,
    required this.adminFee,
    required this.logoAssetPath,
  });
}

class WithdrawPage extends StatefulWidget {
<<<<<<< HEAD
  final String phoneNumber;

  const WithdrawPage({super.key, required this.phoneNumber});
=======
  const WithdrawPage({super.key});
>>>>>>> 539719d8a23c2642640c9ed5b5cd4648d69ed0c1

  @override
  State<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  final List<WithdrawOption> _withdrawOptions = const [
    WithdrawOption(
      name: 'Bank BCA',
      adminFee: 'Biaya admin Rp2.000',
      logoAssetPath: 'asset/elogo1.png',
    ),
    WithdrawOption(
      name: 'Bank Mandiri',
      adminFee: 'Biaya admin Rp2.000',
      logoAssetPath: 'asset/elogo2.png',
    ),
    WithdrawOption(
      name: 'Peramat Bank',
      adminFee: 'Biaya admin Rp2.000',
      logoAssetPath: 'asset/elogo4.png',
    ),
    WithdrawOption(
      name: 'Bank BNI',
      adminFee: 'Biaya admin Rp2.000',
      logoAssetPath: 'asset/elogo5.png',
    ),
    WithdrawOption(
      name: 'Dana',
      adminFee: 'Biaya admin Rp2.000',
      logoAssetPath: 'asset/elogo3.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Withdraw', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Metode penarikan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _withdrawOptions.length,
              itemBuilder: (context, index) {
                final option = _withdrawOptions[index];
                return _buildWithdrawOptionTile(option);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawOptionTile(WithdrawOption option) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: Image.asset(
            option.logoAssetPath,
            width: 40,
            height: 40,
            errorBuilder: (context, error, stackTrace) {
              return CircleAvatar(
                backgroundColor: Colors.grey[200],
                child: const Icon(Icons.account_balance, color: Colors.grey),
              );
            },
          ),
          title: Text(
            option.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
          ),
          subtitle: Text(
            option.adminFee,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey,
            size: 18,
          ),
<<<<<<< HEAD
          // FIX: Mengubah onTap menjadi async dan menggunakan await
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => CairPage(
                      bankName: option.name,
                      phoneNumber: widget.phoneNumber,
                    ),
              ),
            );
            // Memicu refresh jika CairPage mengembalikan true (transaksi sukses)
            if (result == true) {
              Navigator.pop(context, true);
            }
=======
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CairPage(bankName: option.name),
              ),
            );
>>>>>>> 539719d8a23c2642640c9ed5b5cd4648d69ed0c1
          },
        ),
        Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey[200]),
      ],
    );
  }
}
