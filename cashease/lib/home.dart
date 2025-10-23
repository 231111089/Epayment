// lib/home.dart
import 'package:flutter/material.dart';
import 'package:tugas/kirim_uang.dart';
import 'package:tugas/minta_uang.dart';
import 'package:tugas/settings.dart';
import 'profile.dart';
import 'inbox.dart';
import 'history.dart';
import 'pocket.dart';
import 'qris.dart';
import 'withdraw.dart';
import 'taxes.dart';
import 'loan.dart';
import 'creditcard.dart';
import 'beneficiary.dart';
import 'topup.dart';
import 'package:intl/intl.dart';
import 'transfer.dart';
import 'database_helper.dart';

class Home extends StatefulWidget {
  final String phoneNumber;

  const Home({super.key, required this.phoneNumber});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  List<Widget> get _pages => [
    HomePageContent(
      phoneNumber: widget.phoneNumber,
      onBalanceChanged: _refreshPage,
    ),
    const History(),
    const QrisPage(),
    const Pocket(),
    const ProfilePage(),
  ];

  void _refreshPage() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildNavigationDrawer(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildNavigationDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.deepPurpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'C',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'CashEase',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '${widget.phoneNumber}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.home,
            title: 'Home',
            onTap: () async {
              Navigator.pop(context);
              setState(() => _selectedIndex = 0);
            },
          ),
          _buildDrawerItem(
            icon: Icons.person,
            title: 'Profile',
            onTap: () async {
              Navigator.pop(context);
              setState(() => _selectedIndex = 4);
            },
          ),
          _buildDrawerItem(
            icon: Icons.account_balance_wallet,
            title: 'My Pocket',
            onTap: () async {
              Navigator.pop(context);
              setState(() => _selectedIndex = 3);
            },
          ),
          _buildDrawerItem(
            icon: Icons.history,
            title: 'Transaction History',
            onTap: () async {
              Navigator.pop(context);
              setState(() => _selectedIndex = 1);
            },
          ),
          const Divider(),
          _buildDrawerSection('Services'),
          _buildDrawerItem(
            icon: Icons.attach_money,
            title: 'Send Money',
            onTap: () async {
              Navigator.pop(context);
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          KirimUangPage(phoneNumber: widget.phoneNumber),
                ),
              );
              if (result == true) _refreshPage();
            },
          ),
          _buildDrawerItem(
            icon: Icons.request_page,
            title: 'Request Money',
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BagiUangPage()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.qr_code_scanner,
            title: 'QR Scanner',
            onTap: () async {
              Navigator.pop(context);
              setState(() => _selectedIndex = 2);
            },
          ),
          _buildDrawerItem(
            icon: Icons.atm,
            title: 'Withdraw',
            onTap: () async {
              Navigator.pop(context);
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WithdrawPage()),
              );
              if (result == true) _refreshPage();
            },
          ),
          const Divider(),
          _buildDrawerSection('Financial'),
          _buildDrawerItem(
            icon: Icons.receipt_long,
            title: 'Taxes',
            onTap: () async {
              Navigator.pop(context);
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TaxesPage()),
              );
              if (result == true) _refreshPage();
            },
          ),
          _buildDrawerItem(
            icon: Icons.account_balance,
            title: 'Loans',
            onTap: () async {
              Navigator.pop(context);
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoanPage()),
              );
              if (result == true) _refreshPage();
            },
          ),
          _buildDrawerItem(
            icon: Icons.savings,
            title: 'Savings',
            onTap: () async {},
          ),
          const Divider(),
          _buildDrawerSection('Utilities'),
          _buildDrawerItem(
            icon: Icons.receipt,
            title: 'Bill Payments',
            onTap: () async {},
          ),
          _buildDrawerItem(
            icon: Icons.phone_android,
            title: 'Mobile Prepaid',
            onTap: () async {},
          ),
          _buildDrawerItem(
            icon: Icons.mail,
            title: 'Inbox',
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Inbox()),
              );
            },
          ),
          const Divider(),
          _buildDrawerSection('Support'),
          _buildDrawerItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () async {},
          ),
          _buildDrawerItem(
            icon: Icons.settings,
            title: 'Settings',
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.logout,
            title: 'Logout',
            onTap: () async {
              Navigator.pop(context);
              _showLogoutDialog(context);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required Future<void> Function() onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        const BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: "History",
        ),
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.qr_code_scanner,
              color: Colors.white,
              size: 20,
            ),
          ),
          label: "",
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          label: "Pocket",
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.person), label: "Me"),
      ],
    );
  }
}

class HomePageContent extends StatelessWidget {
  final String phoneNumber;
  final VoidCallback onBalanceChanged;

  const HomePageContent({
    super.key,
    required this.phoneNumber,
    required this.onBalanceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return HomeHeaderBody(
      phoneNumber: phoneNumber,
      onBalanceChanged: onBalanceChanged,
    );
  }
}

class HomeHeaderBody extends StatefulWidget {
  final String phoneNumber;
  final VoidCallback onBalanceChanged;

  const HomeHeaderBody({
    super.key,
    required this.phoneNumber,
    required this.onBalanceChanged,
  });

  @override
  State<HomeHeaderBody> createState() => _HomeHeaderBodyState();
}

class _HomeHeaderBodyState extends State<HomeHeaderBody> {
  bool _isAmountVisible = true;
  int _currentBalance = 0;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  // --- PERBAIKAN: JIKA HANYA SALDO BERUBAH, TIDAK PERLU REBUILD WIDGET TREE
  // Hapus didUpdateWidget jika sebelumnya ada, karena kita menggunakan FutureBuilder di build()
  // dan _refreshBalance akan memanggil setState.

  Future<void> _loadBalance() async {
    // Kita panggil setState di HomeState (parent), bukan di sini,
    // karena memanggil setState di sini akan menyebabkan error didUpdateWidget
    // jika data berubah di tempat lain dan widget ini mencoba membangun ulang.
    setState(() => _isLoading = true);
    final balance = await _dbHelper.getUserBalance(widget.phoneNumber);
    setState(() {
      _currentBalance = balance;
      _isLoading = false;
    });
  }

  Future<void> _refreshBalance() async {
    await _loadBalance();
    widget.onBalanceChanged();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Tampilkan saldo saat ini (0) dan lakukan fetch
      // return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Column(
      children: [
        _buildPurpleHeader(),
        Expanded(child: SingleChildScrollView(child: _buildMenuGrid(context))),
      ],
    );
  }

  Widget _buildPurpleHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: const BoxDecoration(color: Colors.deepPurple),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Builder(
                      builder: (scaffoldContext) {
                        return GestureDetector(
                          onTap:
                              () => Scaffold.of(scaffoldContext).openDrawer(),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(
                                (0.2 * 255).toInt(),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.menu,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'C',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'CashEase',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Inbox()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.blue[400],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.mail,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // PERBAIKAN: Tampilkan saldo dari state lokal yang di-refresh
                Text(
                  _isAmountVisible
                      ? 'Rp. ${NumberFormat('#,###', 'id_ID').format(_currentBalance)}'
                      : '••••••••••••',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap:
                      () =>
                          setState(() => _isAmountVisible = !_isAmountVisible),
                  child: Icon(
                    _isAmountVisible ? Icons.lock_open : Icons.lock_outline,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _buildHeaderButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildHeaderButton(Icons.qr_code_scanner, 'Pindai', () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QrisPage()),
          );
        }),
        _buildHeaderButton(Icons.add, 'Isi Saldo', () async {
          final added = await Navigator.push<int>(
            context,
            MaterialPageRoute(
              builder:
                  (_) => TopUpPage(
                    currentBalance: _currentBalance,
                    phoneNumber: widget.phoneNumber,
                  ),
            ),
          );
          if (added != null && added > 0) {
            await _dbHelper.addBalance(
              widget.phoneNumber,
              added,
              description: 'Top Up Saldo',
            );
            await _refreshBalance();
          }
        }),
        _buildHeaderButton(Icons.attach_money, 'Kirim', () async {
          // PERBAIKAN UTAMA: Tangkap hasil dari TransferPage
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => TransferPage(phoneNumber: widget.phoneNumber),
            ),
          );
          // Jika result adalah true, saldo telah berubah
          if (result == true) {
            await _refreshBalance();
          }
        }),
        _buildHeaderButton(Icons.request_page, 'Minta', () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BagiUangPage()),
          );
        }),
      ],
    );
  }

  Widget _buildHeaderButton(
    IconData icon,
    String text,
    Future<void> Function() onTap,
  ) {
    return GestureDetector(
      onTap: () async => await onTap(),
      child: Column(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withAlpha((0.6 * 255).toInt()),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 5),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  void _showTaxesLoanDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Choose Option',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TaxesPage()),
                  );
                  if (result == true) {
                    await _refreshBalance();
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.deepPurple.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.deepPurple,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.receipt_long,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Taxes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'Pay your tax obligations',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.deepPurple,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoanPage()),
                  );
                  if (result == true) {
                    await _refreshBalance();
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.account_balance,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Loan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'Manage your loan payments',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.blue,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        'icon': Icons.account_balance,
        'label': 'Transfer',
        'onTap': () async {
          // PERBAIKAN: Tangkap hasil dari TransferPage
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => TransferPage(phoneNumber: widget.phoneNumber),
            ),
          );
          if (result == true) {
            await _refreshBalance();
          }
        },
      },
      {
        'icon': Icons.credit_card,
        'label': 'Credit Card',
        'onTap': () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreditCardPaymentPage()),
          );
          if (result == true) {
            await _refreshBalance();
          }
        },
      },
      {
        'icon': Icons.account_box,
        'label': 'Beneficiary',
        'onTap': () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BeneficiaryPage()),
          );
        },
      },
      {'icon': Icons.receipt, 'label': 'Bills', 'onTap': () async {}},
      {
        'icon': Icons.attach_money,
        'label': 'Taxes/Loan',
        'onTap': () async => _showTaxesLoanDrawer(context),
      },
      {
        'icon': Icons.phone_android,
        'label': 'Top-up',
        'onTap': () async {
          final added = await Navigator.push<int>(
            context,
            MaterialPageRoute(
              builder:
                  (_) => TopUpPage(
                    currentBalance: _currentBalance,
                    phoneNumber: widget.phoneNumber,
                  ),
            ),
          );
          if (added != null && added > 0) {
            await _dbHelper.addBalance(
              widget.phoneNumber,
              added,
              description: 'Top Up Saldo',
            );
            await _refreshBalance();
          }
        },
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: GridView.builder(
        itemCount: menuItems.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return GestureDetector(
            onTap: item['onTap'],
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(item['icon'], color: Colors.deepPurple, size: 30),
                ),
                const SizedBox(height: 8),
                Text(
                  item['label'],
                  style: const TextStyle(fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
